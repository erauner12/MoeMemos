//
//  MoeMemosApp.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/9/3.
//

import SwiftUI
import Account
import Models
import Factory

@main
struct MoeMemosApp: App {
    @Injected(\.appInfo) private var appInfo
    @Injected(\.accountViewModel) private var userState
    @Injected(\.accountManager) private var accountManager

    @State private var memosViewModel = MemosViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(memosViewModel: memosViewModel)
                .environment(userState)
                .environment(accountManager)
                .environment(appInfo)
                .environmentObject(memosViewModel)
        }
    }
}