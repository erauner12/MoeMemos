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
    @Environment(AccountManager.self) private var accountManager: AccountManager
    @Environment(AccountViewModel.self) var userState: AccountViewModel
    @Environment(MemosViewModel.self) private var memosViewModel: MemosViewModel
    @State private var filteredMemoList: [Memo] = []
    
    var body: some View {
        let defaultMemoVisibility = userState.currentUser?.defaultVisibility ?? .private
        
        ZStack(alignment: .bottomTrailing) {
            List(filteredMemoList, id: \.remoteId) { memo in
                Section {
                    MemoCard(memo, defaultMemoVisibility: defaultMemoVisibility)
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            if tag == nil {
                Button {
                    showingNewPost = true
                } label: {
                    Circle().overlay {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                    }
                    .shadow(radius: 1)
                    .frame(width: 60, height: 60)
                }
                .padding(20)
            }
        }
        .overlay(content: {
            if memosViewModel.loading && !memosViewModel.inited {
                ProgressView()
            }
        })
        .searchable(text: $searchString)
        .navigationTitle(tag?.name ?? NSLocalizedString("memo.memos", comment: "Memos"))
        .sheet(isPresented: $showingNewPost) {
            MemoInput(memo: nil)
        }
        .onAppear {
            updateFilteredMemoList()
        }
        .refreshable {
            do {
                try await memosViewModel.loadMemos()
            } catch {
                print(error)
            }
        }
        .onChange(of: memosViewModel.memoList) { _, _ in
            updateFilteredMemoList()
        }
        .onChange(of: tag) { _, _ in
            updateFilteredMemoList()
        }
        .onChange(of: searchString) { _, _ in
            updateFilteredMemoList()
        }
        .onChange(of: memosViewModel.selectedTimeFilter) { _, _ in
            updateFilteredMemoList()
        }
        .onChange(of: memosViewModel.selectedPinFilter) { _, _ in
            updateFilteredMemoList()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task {
                if memosViewModel.inited {
                    try await memosViewModel.loadMemos()
                }
            }
        }
    }
    
    private func updateFilteredMemoList() {
        let timeFilteredMemos = memosViewModel.filteredMemos(tag: tag)
        
        if searchString.isEmpty {
            filteredMemoList = timeFilteredMemos
        } else {
            filteredMemoList = timeFilteredMemos.filter { memo in
                memo.content.localizedCaseInsensitiveContains(searchString)
            }
        }
        
        // Sort memos: pinned first, then by creation date
        filteredMemoList.sort { (memo1, memo2) in
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
