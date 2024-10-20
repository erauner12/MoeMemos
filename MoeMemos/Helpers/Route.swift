//
//  Route.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/10/30.
//

import SwiftUI
import Models
import Env
import Account
import Foundation

extension Route {
    @MainActor @ViewBuilder
    func destination() -> some View {
        switch self {
        case .memos:
            MemosList(tag: nil)
        case .resources:
            Resources()
        case .archived:
            ArchivedMemosList()
        case .tag(let tag):
            MemosList(tag: tag)
        case .settings:
            Settings()
        case .explore:
            Explore()
        case .memosAccount(let accountKey):
            MemosAccountView(accountKey: accountKey)
        }
    }
}

func createDraftsUrl(text: String, action: String? = nil) -> URL? {
    var urlComponents = URLComponents(string: "drafts://create")
    urlComponents?.queryItems = [URLQueryItem(name: "text", value: text)]
    
    if let action = action {
        urlComponents?.queryItems?.append(URLQueryItem(name: "action", value: action))
    }
    
    return urlComponents?.url
}
