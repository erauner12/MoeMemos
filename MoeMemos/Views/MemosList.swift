//
//  MemosList.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/9/4.
//

import SwiftUI
import Account
import Models

struct MemosList: View {
    let tag: Tag?

    @State private var searchString = ""
    @State private var showingNewPost = false
    @State private var selectedDateFilter: MemoDateFilter = .all
    @State private var selectedTimeFilter: MemoTimeFilter = .all
    @State private var selectedPinFilter: MemoPinFilter = .all
    @State private var hasTaskList = false
    @State private var hasIncompleteTasks = false
    @Environment(AccountManager.self) private var accountManager: AccountManager
    @Environment(AccountViewModel.self) var userState: AccountViewModel
    @Environment(MemosViewModel.self) private var memosViewModel: MemosViewModel
    @State private var filteredMemoList: [Memo] = []

    var body: some View {
        let defaultMemoVisibility = userState.currentUser?.defaultVisibility ?? .private

        ZStack(alignment: .bottomTrailing) {
            memoListView(defaultMemoVisibility: defaultMemoVisibility)
            
            if tag == nil {
                newMemoButton
            }
        }
        .overlay(loadingOverlay)
        .searchable(text: $searchString)
        .navigationTitle(tag?.name ?? NSLocalizedString("memo.memos", comment: "Memos"))
        .sheet(isPresented: $showingNewPost) {
            MemoInput(memo: nil)
        }
        .onAppear(perform: updateFilteredMemoList)
        .refreshable {
            await refreshMemos()
        }
        .onChange(of: memosViewModel.memoList) { _ in updateFilteredMemoList() }
        .onChange(of: tag) { _ in updateFilteredMemoList() }
        .onChange(of: searchString) { _ in updateFilteredMemoList() }
        .onChange(of: selectedTimeFilter) { _ in updateFilteredMemoList() }
        .onChange(of: selectedPinFilter) { _ in updateFilteredMemoList() }
        .onChange(of: selectedDateFilter) { _ in updateFilteredMemoList() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task { await refreshMemosIfNeeded() }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                filterMenu
            }
        }
    }

    private func memoListView(defaultMemoVisibility: MemoVisibility) -> some View {
        List(filteredMemoList, id: \.remoteId) { memo in
            Section {
                MemoCard(memo, defaultMemoVisibility: defaultMemoVisibility)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    private var newMemoButton: some View {
        Button(action: { showingNewPost = true }) {
            Image(systemName: "plus")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.white)
                .padding(17.5)
                .background(Circle())
        }
        .shadow(radius: 1)
        .padding(20)
    }

    private var loadingOverlay: some View {
        Group {
            if memosViewModel.loading && !memosViewModel.inited {
                ProgressView()
            }
        }
    }

    private var filterMenu: some View {
        Menu {
            Picker("Date Filter", selection: $selectedDateFilter) {
                ForEach(MemoDateFilter.allCases) { filter in
                    Text(filter.displayName).tag(filter)
                }
            }
            
            Picker("Time Filter", selection: $selectedTimeFilter) {
                ForEach(MemoTimeFilter.allCases) { filter in
                    Text(filter.displayName).tag(filter)
                }
            }
            
            Picker("Pin Filter", selection: $selectedPinFilter) {
                ForEach(MemoPinFilter.allCases) { filter in
                    Text(filter.displayName).tag(filter)
                }
            }
            Toggle("Has Task List", isOn: $hasTaskList)
            Toggle("Has Incomplete Tasks", isOn: $hasIncompleteTasks)
        } label: {
            Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
        }
    }

    private func updateFilteredMemoList() {
        var filteredMemos = memosViewModel.memoList

        // Apply date filter
        filteredMemos = filterMemosByDate(memos: filteredMemos)
        
        // Apply time filter
        filteredMemos = filterMemosByTime(memos: filteredMemos)
        
        // Apply pin filter
        filteredMemos = filterMemosByPin(memos: filteredMemos)
        
        // Apply tag filter
        filteredMemos = filterMemosByTag(memos: filteredMemos)
        
        // Apply task list filter
        if hasTaskList {
            filteredMemos = filteredMemos.filter { $0.hasTaskList() }
        }
        
        // Apply incomplete tasks filter
        if hasIncompleteTasks {
            filteredMemos = filteredMemos.filter { $0.hasIncompleteTasks() }
        }
        
        // Apply search filter
        if !searchString.isEmpty {
            filteredMemos = filteredMemos.filter { memo in
                memo.content.localizedCaseInsensitiveContains(searchString)
            }
        }
        
        // Sort the filtered memos
        filteredMemos.sort { (memo1, memo2) in
            if memo1.pinned == true && memo2.pinned != true {
                return true
            } else if memo1.pinned != true && memo2.pinned == true {
                return false
            } else {
                return memo1.createdAt > memo2.createdAt
            }
        }
        
        // Assign the final filtered and sorted list
        filteredMemoList = filteredMemos
    }

    private func filterMemosByTime(memos: [Memo]) -> [Memo] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        switch selectedTimeFilter {
        case .all:
            return memos
        case .createdToday:
            return memos.filter { calendar.isDate($0.createdAt, inSameDayAs: today) }
        case .updatedToday:
            return memos.filter { calendar.isDate($0.updatedAt, inSameDayAs: today) }
        case .modifiedToday:
            return memos.filter { calendar.isDate($0.createdAt, inSameDayAs: today) || calendar.isDate($0.updatedAt, inSameDayAs: today) }
        }
    }

    private func filterMemosByPin(memos: [Memo]) -> [Memo] {
        switch selectedPinFilter {
        case .all:
            return memos
        case .pinned:
            return memos.filter { $0.pinned == true }
        case .unpinned:
            return memos.filter { $0.pinned != true }
        }
    }

    private func filterMemosByDate(memos: [Memo]) -> [Memo] {
        let (startDate, endDate) = selectedDateFilter.dateRange()
        return memos.filter { memo in
            if let start = startDate, let end = endDate {
                return memo.createdAt >= start && memo.createdAt < end
            } else if let start = startDate {
                return memo.createdAt >= start
            } else {
                return true
            }
        }
    }

    private func filterMemosByTag(memos: [Memo]) -> [Memo] {
        guard let tag = tag else { return memos }
        return memos.filter { memo in
            let pattern = "#(\\\(tag.name))\\b"
            let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            return regex?.firstMatch(in: memo.content, options: [], range: NSRange(location: 0, length: memo.content.utf16.count)) != nil
        }
    }

    private func refreshMemos() async {
        do {
            try await memosViewModel.loadMemos()
        } catch {
            print(error)
        }
    }

    private func refreshMemosIfNeeded() async {
        if memosViewModel.inited {
            await refreshMemos()
        }
    }
}