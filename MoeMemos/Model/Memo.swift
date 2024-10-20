//
//  Memo.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/9/4.
//

import Foundation
import SwiftUI
import Models

extension MemoVisibility {
    var title: LocalizedStringKey {
        switch self {
        case .public:
            return "memo.visibility.public"
        case .local:
            return "memo.visibility.protected"
        case .private:
            return "memo.visibility.private"
        case .direct:
            return "memo.visibility.direct"
        case .unlisted:
            return "memo.visibility.unlisted"
        }
    }
    
    var iconName: String {
        switch self {
        case .public:
            return "globe"
        case .local:
            return "house"
        case .private:
            return "lock"
        case .direct:
            return "envelope"
        case .unlisted:
            return "lock.open"
        }
    }
}

extension Memo {
    func renderTime() -> String {
        if Calendar.current.dateComponents([.day], from: createdAt, to: .now).day! > 7 {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .short
            return formatter.string(from: createdAt)
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: createdAt, relativeTo: .now)
    }
}

enum MemoPinFilter: String, CaseIterable, Identifiable {
    case all
    case pinned
    case unpinned
    
    var id: String { self.rawValue }
    
    var displayName: LocalizedStringKey {
        switch self {
        case .all:
            return "memo.pin_filter.all"
        case .pinned:
            return "memo.pin_filter.pinned"
        case .unpinned:
            return "memo.pin_filter.unpinned"
        }
    }
}
