//
//  AppInfo.swift
//
//
//  Created by Mudkip on 2023/11/12.
//

import Foundation
import Observation
import StoreKit
import SwiftData
import Factory

@Observable public class AppInfo {
    public static let groupContainerIdentifier = "group.me.erauner.MoeMemos"
    public static let keychainAccessGroupName = "R63D7L5N86.me.erauner.MoeMemos"
    
    public let modelContext: ModelContext
    
    public init() {
        let container = try! ModelContainer(
            for: User.self,
            configurations: .init(groupContainer: .identifier(AppInfo.groupContainerIdentifier))
        )
        modelContext = ModelContext(container)
    }
    
    @ObservationIgnored private lazy var region = SKPaymentQueue.default().storefront?.countryCode
    @ObservationIgnored public lazy var website = region == "CHN" ? URL(string: "https://memos.vintage-wiki.com")! : URL(string: "https://memos.moe")!
    @ObservationIgnored public lazy var privacy = region == "CHN" ? URL(string: "https://memos.vintage-wiki.com/privacy")! : URL(string: "https://memos.moe/privacy")!
    @ObservationIgnored public lazy var registration = region == "CHN" ? "晋ICP备2022000288号-2A" : ""
}

public extension Container {
    var appInfo: Factory<AppInfo> {
        self { AppInfo() }.shared
    }
}
