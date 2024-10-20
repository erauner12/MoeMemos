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
    @State private var showingTimeFilterSheet = false
    @State private var showingDateFilterSheet = false
    @State private var showingCustomDatePicker = false
    @Environment(AccountViewModel.self) var userState: AccountViewModel
    @EnvironmentObject private var memosViewModel: MemosViewModel
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingTimeFilterSheet = true }) {
                        Label("Time Filter", systemImage: "clock")
                    }
                    Button(action: { showingDateFilterSheet = true }) {
                        Label("Date Filter", systemImage: "calendar")
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $showingTimeFilterSheet) {
            TimeFilterView(selectedTimeFilter: $memosViewModel.selectedTimeFilter)
        }
        .sheet(isPresented: $showingDateFilterSheet) {
            DateFilterView(selectedDateFilter: $memosViewModel.selectedDateFilter)
        }
        .sheet(isPresented: $showingCustomDatePicker) {
            CustomDatePickerView(startDate: $memosViewModel.customStartDate, endDate: $memosViewModel.customEndDate)
        }
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
        .onChange(of: memosViewModel.memoList) { _ in
            updateFilteredMemoList()
        }
        .onChange(of: tag) { _ in
            updateFilteredMemoList()
        }
        .onChange(of: searchString) { _ in
            updateFilteredMemoList()
        }
        .onChange(of: memosViewModel.selectedTimeFilter) { _ in
            updateFilteredMemoList()
        }
        .onChange(of: memosViewModel.selectedPinFilter) { _ in
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
        filteredMemoList = memosViewModel.filteredMemos(tag: tag).filter { memo in
            searchString.isEmpty || memo.content.localizedCaseInsensitiveContains(searchString)
        }
    }
}

struct TimeFilterView: View {
    @Binding var selectedTimeFilter: MemoTimeFilter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List(MemoTimeFilter.allCases) { filter in
                Button(action: {
                    selectedTimeFilter = filter
                    dismiss()
                }) {
                    HStack {
                        Text(filter.displayName)
                        Spacer()
                        if filter == selectedTimeFilter {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .navigationTitle("Select Time Filter")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct DateFilterView: View {
    @Binding var selectedDateFilter: MemoDateFilter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List(MemoDateFilter.allCases) { filter in
                Button(action: {
                    selectedDateFilter = filter
                    dismiss()
                }) {
                    HStack {
                        Text(filter.displayName)
                        Spacer()
                        if filter == selectedDateFilter {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .navigationTitle("Select Date Filter")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct CustomDatePickerView: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Start Date", selection: Binding(
                    get: { startDate ?? Date() },
                    set: { startDate = $0 }
                ), displayedComponents: .date)
                DatePicker("End Date", selection: Binding(
                    get: { endDate ?? Date() },
                    set: { endDate = $0 }
                ), displayedComponents: .date)
            }
            .navigationTitle("Custom Date Range")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}