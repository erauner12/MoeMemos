//
//  Memo.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/9/4.
//

import Foundation
import SwiftUI
import Models

enum MemoSortOption: String, CaseIterable, Identifiable {
    case createdAtAsc
    case createdAtDesc
    case updatedAtAsc
    case updatedAtDesc
    
    var id: String { self.rawValue }
    
    var displayName: LocalizedStringKey {
        switch self {
        case .createdAtAsc:
            return "memo.sort.created_at_asc"
        case .createdAtDesc:
            return "memo.sort.created_at_desc"
        case .updatedAtAsc:
            return "memo.sort.updated_at_asc"
        case .updatedAtDesc:
            return "memo.sort.updated_at_desc"
        }
    }
}

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

    func hasTaskList() -> Bool {
        // Use a regular expression to check for task list items
        let taskListRegex = try? NSRegularExpression(pattern: "- \\[(x|\\s)\\]", options: [])
        guard let regex = taskListRegex else {
            return false
        }
        
        let range = NSRange(content.startIndex..<content.endIndex, in: content)
        let matches = regex.matches(in: content, range: range)
        return !matches.isEmpty
    }

    func hasIncompleteTasks() -> Bool {
        // Use a regular expression to check for incomplete task list items
        let incompleteTaskRegex = try? NSRegularExpression(pattern: "- \\[ \\]", options: [])
        guard let regex = incompleteTaskRegex else {
            return false
        }
        
        let range = NSRange(content.startIndex..<content.endIndex, in: content)
        let matches = regex.matches(in: content, range: range)
        return !matches.isEmpty
    }
    
    func incompleteTaskCount() -> Int {
        // Use a regular expression to count the number of incomplete task list items
        let incompleteTaskRegex = try? NSRegularExpression(pattern: "- \\[ \\]", options: [])
        guard let regex = incompleteTaskRegex else {
            return 0
        }
        
        let range = NSRange(content.startIndex..<content.endIndex, in: content)
        let matches = regex.matches(in: content, range: range)
        return matches.count
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

enum PinnedMemoDateFilter: String, CaseIterable, Identifiable {
    case showAll
    case lastThreeDays
    case lastSevenDays
    
    var id: String { self.rawValue }
    
    var displayName: LocalizedStringKey {
        switch self {
        case .showAll:
            return "memo.pinned_date_filter.show_all"
        case .lastThreeDays:
            return "memo.pinned_date_filter.last_three_days"
        case .lastSevenDays:
            return "memo.pinned_date_filter.last_seven_days"
        }
    }
}
