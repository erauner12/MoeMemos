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

@Observable
class MemosViewModel {
    @ObservationIgnored
    @Injected(\.accountManager) private var accountManager
    var prioritizePinnedMemos: Bool = false
    @ObservationIgnored
    var service: RemoteService { get throws { try accountManager.mustCurrentService } }

    init() {
        prioritizePinnedMemos = UserDefaults.standard.bool(forKey: "prioritizePinnedMemos")
    }

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
    func togglePrioritizePinnedMemos() {
        prioritizePinnedMemos.toggle()
        UserDefaults.standard.set(prioritizePinnedMemos, forKey: "prioritizePinnedMemos")
    }

    @MainActor
    func deleteMemo(remoteId: String) async throws {
        _ = try await service.deleteMemo(remoteId: remoteId)
        memoList = memoList.filter({ memo in
            memo.remoteId != remoteId
        })
    }
}
