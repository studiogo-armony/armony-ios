//
//  RestAPIMiddleware.swift
//  Armony
//
//  Created by Koray Yıldız on 16.02.2022.
//

import Alamofire
import Foundation

/// Alamofire RequestInterceptor that handles authentication, request adaptation, and token refresh.
/// 
/// This middleware automatically adds required headers to all API requests and handles
/// token expiration by refreshing the access token and retrying failed requests.
/// It also manages region-specific headers and timezone information.
/// 
/// ## Key Features:
/// - **Request Adaptation**: Adds client type, region, timezone, and authentication headers
/// - **Token Refresh**: Automatically refreshes expired tokens and retries requests
/// - **Request Queuing**: Queues requests during token refresh to prevent race conditions
/// - **White-listed Endpoints**: Certain auth endpoints are excluded from retry logic
/// 
/// ## Usage:
/// ```swift
/// // Configure Alamofire session with middleware
/// let middleware = RestAPIMiddleware(authenticator: .shared)
/// let session = Session(interceptor: middleware)
/// 
/// // All requests through this session will automatically:
/// // - Include authentication headers
/// // - Handle token refresh on expiration
/// // - Retry failed requests after token refresh
/// ```
final class RestAPIMiddleware: RequestInterceptor {

    /// List of endpoints that should not be retried after token expiration.
    /// These are typically authentication endpoints that don't require a valid token.
    private let whiteListForRetry = [
        "/auth/signin",
        "/auth/signup",
        "auth/reset-password",
        "/auth/refresh"
    ]

    /// Current timezone for request headers
    private let timeZone: TimeZone = .autoupdatingCurrent
    
    /// Current locale for request headers
    private let locale: Locale = .autoupdatingCurrent

    /// Type alias for request retry completion handlers
    public typealias RequestRetryCompletion = (RetryResult) -> Void
    
    /// Called when the refresh token is rejected; must call `completion` once the user has logged in or registered
    typealias SessionExpiredHandler = (_ completion: @escaping VoidCallback) -> Void

    /// Queue of requests waiting for token refresh (or the login it falls back to) to complete
    private var waitingRequests: [RequestRetryCompletion]

    /// `true` from the first 401 until the refresh succeeds or the login it falls back to completes.
    /// Further 401s in that window wait instead of starting another refresh or login.
    private var isRefreshing = false

    /// `retryCount` of each request whose 401 already started a token refresh.
    /// Alamofire asks the retrier a second time for the same attempt when the response serializer
    /// rethrows the validation error; that call must not refresh (and present login) again.
    private var refreshedAttempts = [UUID: Int]()

    /// Guards `waitingRequests`, `isRefreshing` and `refreshedAttempts`: Alamofire calls `retry` on its own queues
    /// while the refresh finishes on the main queue
    private let lock = NSLock()

    /// REST service instance for making token refresh requests
    private lazy var tokenRestService: RestService = tokenServiceFactory()

    /// Creates `tokenRestService` on the first token refresh
    private let tokenServiceFactory: () -> RestService

    /// Authentication service for managing tokens and user state
    private let authenticator: AuthenticationProviding

    /// Source of the user's selected region
    private let defaults: Defaults

    /// Records token expiration events
    private let logger: ErrorLogging

    /// Presents login after the session can't be refreshed
    private let sessionExpiredHandler: SessionExpiredHandler

    /// Initializes the middleware; defaults match the production setup
    /// - Parameters:
    ///   - authenticator: The authentication service to use for token management
    ///   - defaults: Source of the region header
    ///   - logger: Receives token expiration events
    ///   - tokenServiceFactory: Creates the service used for `/auth/refresh`
    ///   - sessionExpiredHandler: Asks the user to log in again when the refresh token is rejected
    init(authenticator: AuthenticationProviding = AuthenticationService.shared,
         defaults: Defaults = .shared,
         logger: ErrorLogging = FirebaseCrashlyticsLogger.shared,
         tokenServiceFactory: @escaping () -> RestService = { RestService(backend: .factory()) },
         sessionExpiredHandler: @escaping SessionExpiredHandler = RestAPIMiddleware.presentLogin) {
        self.authenticator = authenticator
        self.defaults = defaults
        self.logger = logger
        self.tokenServiceFactory = tokenServiceFactory
        self.sessionExpiredHandler = sessionExpiredHandler
        waitingRequests = [RequestRetryCompletion]()
    }

    /// Default `SessionExpiredHandler`: presents login and continues after login or registration
    static func presentLogin(completion: @escaping VoidCallback) {
        LoginCoordinator().start(loginCompletion: completion, registrationCompletion: completion)
    }
    
    /// Adapts outgoing requests by adding required headers.
    /// 
    /// This method is called before each request and adds:
    /// - Client type header (iOS)
    /// - Region header (from user settings or current locale)
    /// - Timezone headers (name and abbreviation)
    /// - Authentication headers (from authenticator service)
    /// 
    /// - Parameters:
    ///   - urlRequest: The original URL request to adapt
    ///   - session: The Alamofire session
    ///   - completion: Completion handler with the adapted request or error
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Swift.Result<URLRequest, Error>) -> Void) {

        var urlRequest = urlRequest
        urlRequest.setValue("IOS", forHTTPHeaderField: "Client-Type")
        
        if defaults[.isRegionActive] {
            if let region: String = defaults[.region], region.isNotEmpty {
                urlRequest.setValue(region, forHTTPHeaderField: "Region")
            }
        }
        else {
            urlRequest.setValue(Locale.current.regionCode, forHTTPHeaderField: "Region")
        }

        if let timeZoneName = timeZone.localizedName(for: .standard, locale: locale) {
            urlRequest.setValue(timeZoneName, forHTTPHeaderField: "Time-Zone-Name")
            urlRequest.setValue(timeZone.abbreviation(), forHTTPHeaderField: "Time-Zone")
        }

        for (key, value) in authenticator.additionalHTTPHeaders where value.isNotEmpty {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        completion(.success(urlRequest))
    }

    /// Handles request retry logic for failed requests.
    /// 
    /// This method is called when a request fails and determines whether to retry.
    /// It specifically handles token expiration by:
    /// - Checking if the request is not in the white-list
    /// - Verifying the response status code indicates token expiration
    /// - Queuing the request for retry after token refresh
    /// - Limiting retry attempts to prevent infinite loops
    /// 
    /// - Parameters:
    ///   - request: The failed request
    ///   - session: The Alamofire session
    ///   - error: The error that caused the failure
    ///   - completion: Completion handler with retry decision
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let requestURLString = request.request?.url?.absoluteString
        let isWhiteListRequest = whiteListForRetry.first(where: { requestURLString.emptyIfNil.contains($0)}).isNil

        if let response = request.response {
            if response.statusCode == NSHTTPURLResponseTokenExpiredStatusCode,
               isWhiteListRequest,
               request.retryCount < 4 {
                guard startsRefreshAttempt(for: request) else {
                    completion(.doNotRetry)
                    return
                }
                guard !wasSentWithOutdatedCredentials(request) else {
                    /// The token changed while this request was in flight: retry with the new one, or give up after logout
                    completion(authenticator.isAuthenticated ? .retry : .doNotRetry)
                    return
                }
                logger.log(exception:
                        .init(name: "RestService",
                              reason: "NSHTTPURLResponseTokenExpiredStatusCode")
                )
                waitForRefresh(completion)
            }
            else {
                completion(.doNotRetry)
            }
        }
        else {
            /// No HTTP response (timeout, connection lost): Alamofire waits for this completion before finishing the request.
            completion(.doNotRetry)
        }
    }

    /// Records that `request` refreshes the token for its current attempt.
    /// - Returns: `false` when this attempt already refreshed, i.e. this is Alamofire's repeated retry call.
    private func startsRefreshAttempt(for request: Request) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        if refreshedAttempts[request.id] == request.retryCount {
            refreshedAttempts[request.id] = nil
            return false
        }
        refreshedAttempts[request.id] = request.retryCount
        return true
    }

    /// Whether `request` carried other auth headers than the authenticator has now, i.e. a refresh or logout
    /// happened after it was sent. Requests sent without a token compare as empty.
    private func wasSentWithOutdatedCredentials(_ request: Request) -> Bool {
        return authenticator.additionalHTTPHeaders.contains { field, currentValue in
            request.request?.value(forHTTPHeaderField: field).emptyIfNil != currentValue
        }
    }

    /// Queues `completion` until the token refresh finishes; the first waiting request starts the refresh.
    private func waitForRefresh(_ completion: @escaping RequestRetryCompletion) {
        lock.lock()
        waitingRequests.append(completion)
        let shouldStartRefresh = !isRefreshing
        isRefreshing = true
        lock.unlock()

        if shouldStartRefresh {
            refreshToken()
        }
    }

    /// Hands `result` to every waiting request and allows the next 401 to refresh again.
    /// Completions run outside the lock, since Alamofire may call `retry` again from them.
    private func completeWaitingRequests(with result: RetryResult) {
        lock.lock()
        let completions = waitingRequests
        waitingRequests.removeAll()
        isRefreshing = false
        lock.unlock()

        completions.forEach { $0(result) }
    }

    /// Refreshes the access token and retries waiting requests.
    /// 
    /// This method:
    /// - Makes a token refresh request using the refresh token
    /// - Updates the authenticator with new tokens on success
    /// - Retries all waiting requests with the new token
    /// - Handles authentication failure by logging out the user
    /// - Manages the waiting requests queue
    private func refreshToken() {
        Task {
            do {
                let request = RefreshTokenRequest(refreshToken: authenticator.refreshToken)
                let response = try await tokenRestService.execute(
                    task: PostRefreshTokenTask(request: request), type: RestObjectResponse<RefreshTokenResponse>.self
                )
                safeSync {
                    authenticator.identify(accessToken: response.data.access, refreshToken: response.data.refresh)
                }
                completeWaitingRequests(with: .retry)
            }
            catch {
                safeSync {
                    authenticator.unauthenticate()
                    sessionExpiredHandler { [weak self] in
                        self?.completeWaitingRequests(with: .doNotRetry)
                    }
                }
            }
        }
    }
}
