import Foundation

public struct Deeplink: CustomStringConvertible, ExpressibleByStringLiteral {

    private let path: any URLConvertible

    public init(stringLiteral value: String) {
        self.path = value
    }

    private init(path: any URLConvertible) {
        self.path = path
    }

    public var description: String {
        return path.urlString
    }

    // MARK: - EMPTY
    public static let empty = Deeplink(stringLiteral: .empty)
}

// MARK: - Decodable
extension Deeplink: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        path = try container.decode(String.self)
    }
}


extension Deeplink: Equatable {
    public static func == (lhs: Deeplink, rhs: Deeplink) -> Bool {
        lhs.description == rhs.description
    }
}
