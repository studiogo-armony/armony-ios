//
//  Constants.swift
//  Armony
//
//  Created by Koray Yildiz on 18.04.22.
//

import Foundation

public struct Common {

    static let instrumentEmojis = [
        "🎹", "🎸", "🎤", "🥁", "🎷"
    ]
    
    // MARK: - Durations
    public struct Durations {
        public struct BottomPopUp {
            public static var dismiss: Double = 0.25
            public static var present: Double = 0.25
        }
    }
    
    // MARK: - Tab
    public enum Tab: Int {
        case home = 0
        case createAdvert = 1
        case account = 2
        
        public var index: Int {
            return rawValue
        }
        
        public var tabBarColor: AppTheme.Color {
            switch self {
            case .home:
                return .blue
                
            case .createAdvert:
                return .pink
                
            case .account:
                return .purple
            }
        }
    }
}
