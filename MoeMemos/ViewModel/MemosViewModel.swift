//
//  MemosViewModel.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/9/5.
//

import Foundation
import Account
import Models
import Factory
import MemosV1Service
import Observation
import SwiftUI

@Observable
@MainActor
class MemosViewModel {
    @ObservationIgnored
    @Injected(\.accountManager) private var accountManager
    @ObservationIgnored
    var service: RemoteService { get throws { try accountManager.mustCurrentService } }

    var memoList: [Memo] = [] {
        didSet {
            matrix = DailyUsageStat.calculateMatrix(memoList: memoList)
        }
    }
    var tags: [Tag] = []
    var nestedTags: [NestedTag] = []
    var matrix: [DailyUsageStat] = DailyUsageStat.initialMatrix
    var inited = false
    var loading = false

    var selectedTimeFilter: MemoTimeFilter = .all
    var selectedDateFilter: MemoDateFilter = .created
    var customStartDate: Date?
    var customEndDate: Date?

    @MainActor
    func getMemo(remoteId: String) async throws -> Memo {
        do {
            let currentService = try service
            guard let memosV1Service = currentService as? MemosV1Service else {
                throw MoeMemosError.unsupportedVersion
            }
            return try await memosV1Service.getMemo(remoteId: remoteId)
        } catch {
            throw error
        }
    }
    
    @MainActor
    func loadMemos() async throws {
        do {
            loading = true
            let response = try await service.listMemos()
            memoList = response
            loading = false
            inited = true
        } catch {
            loading = false
            throw error
        }
    }
    
    @MainActor
    func loadTags() async throws {
        tags = try await service.listTags()
        nestedTags = NestedTag.fromTagList(tags.map { $0.name })
    }
    
    @MainActor
    func createMemo(content: String, visibility: MemoVisibility = .private, resources: [Resource]? = nil, tags: [String]?) async throws {
        let response = try await service.createMemo(content: content, visibility: visibility, resources: resources ?? [], tags: tags)
        memoList.insert(response, at: 0)
        try await loadTags()
    }
    
    @MainActor
    private func updateMemo(_ memo: Memo) {
        for (i, item) in memoList.enumerated() {
            if memo.remoteId != nil && item.remoteId == memo.remoteId {
                memoList[i] = memo
                break
            }
        }
    }
    
    @MainActor
    func updateMemoOrganizer(remoteId: String, pinned: Bool) async throws {
        let response = try await service.updateMemo(remoteId: remoteId, content: nil, resources: nil, visibility: nil, tags: nil, pinned: pinned)
        updateMemo(response)
    }
    
    @MainActor
    func archiveMemo(remoteId: String) async throws {
        try await service.archiveMemo(remoteId: remoteId)
        memoList = memoList.filter({ memo in
            memo.remoteId != remoteId
        })
    }
    
    @MainActor
    func editMemo(remoteId: String, content: String, visibility: MemoVisibility = .private, resources: [Resource]? = nil, tags: [String]?) async throws {
        let response = try await service.updateMemo(remoteId: remoteId, content: content, resources: resources, visibility: visibility, tags: nil, pinned: nil)
        updateMemo(response)
        try await loadTags()
    }
    
    @MainActor
    func deleteTag(name: String) async throws {
        _ = try await service.deleteTag(name: name)
        
        tags.removeAll { tag in
            tag.name == name
        }
        nestedTags = NestedTag.fromTagList(tags.map { $0.name })
    }

    @MainActor
    func deleteMemo(remoteId: String) async throws {
        _ = try await service.deleteMemo(remoteId: remoteId)
        memoList = memoList.filter({ memo in
            memo.remoteId != remoteId
        })
    }
    
    func filteredMemos(tag: Tag?) -> [Memo] {
        let filteredByTag = tag == nil ? memoList : memoList.filter { memo in
            memo.content.contains("#\(tag!.name) ") || memo.content.contains("#\(tag!.name)/")
            || memo.content.contains("#\(tag!.name)\n")
            || memo.content.hasSuffix("#\(tag!.name)")
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        let timeFilteredMemos = filteredByTag.filter { memo in
            let relevantDate: Date
            switch selectedDateFilter {
            case .created:
                relevantDate = memo.createdAt
            case .modified, .updated:
                relevantDate = memo.updatedAt
            }
            
            switch selectedTimeFilter {
            case .all:
                return true
            case .today:
                return calendar.isDateInToday(relevantDate)
            case .yesterday:
                return calendar.isDateInYesterday(relevantDate)
            case .thisWeek:
                return calendar.isDate(relevantDate, equalTo: now, toGranularity: .weekOfYear)
            case .lastWeek:
                let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: calendar.startOfWeek(for: now))!
                let lastWeekEnd = calendar.date(byAdding: .day, value: 6, to: lastWeekStart)!
                return relevantDate >= lastWeekStart && relevantDate <= lastWeekEnd
            case .thisMonth:
                return calendar.isDate(relevantDate, equalTo: now, toGranularity: .month)
            case .lastMonth:
                let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: now)!
                return calendar.isDate(relevantDate, equalTo: lastMonthDate, toGranularity: .month)
            case .last3Days:
                let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!
                return relevantDate >= threeDaysAgo
            case .last7Days:
                let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!
                return relevantDate >= sevenDaysAgo
            case .last30Days:
                let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
                return relevantDate >= thirtyDaysAgo
            case .custom:
                guard let start = customStartDate, let end = customEndDate else { return true }
                return relevantDate >= start && relevantDate <= end
            }
        }
        
        return timeFilteredMemos.sorted { (memo1, memo2) in
            if memo1.pinned == true && memo2.pinned != true {
                return true
            } else if memo1.pinned != true && memo2.pinned == true {
                return false
            } else {
                return memo1.createdAt > memo2.createdAt
            }
        }
    }
}

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components)!
    }
}