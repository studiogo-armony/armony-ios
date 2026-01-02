import Foundation

public protocol URLNavigatable {
    var isAuthenticationRequired: Bool { get }

    static var instance: any URLNavigatable { get }

    static func register(navigator: any URLNavigation)
}
