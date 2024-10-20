//
//  Sidebar.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/9/4.
//

import SwiftUI
import Account
import Env
import Models

struct Sidebar: View {
    @Bindable var memosViewModel: MemosViewModel
    @Environment(AccountManager.self) private var accountManager: AccountManager
    @Environment(AccountViewModel.self) private var userState: AccountViewModel
    @Binding var selection: Route?

    var body: some View {
        List(selection: UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .vision ? $selection : nil) {
            Stats(memosViewModel: memosViewModel)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(EmptyView())
            
            Section {
                NavigationLink(value: Route.memos) {
                    Label("memo.memos", systemImage: "rectangle.grid.1x2")
                }
                NavigationLink(value: Route.explore) {
                    Label("explore", systemImage: "house")
                }
                NavigationLink(value: Route.resources) {
                    Label("resources", systemImage: "photo.on.rectangle")
                }
                NavigationLink(value: Route.archived) {
                    Label("memo.archived", systemImage: "archivebox")
                }
            } header: {
                Text("moe-memos")
            }
            
            Section {
                Picker("Time Filter", selection: $memosViewModel.selectedTimeFilter) {
                    ForEach(MemoTimeFilter.allCases) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Picker("Pin Filter", selection: $memosViewModel.selectedPinFilter) {
                    ForEach(MemoPinFilter.allCases) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            } header: {
                Text("memo.filters")
            }
            
            Section {
                OutlineGroup(memosViewModel.nestedTags, children: \.children) { item in
                    NavigationLink(value: Route.tag(Tag(name: item.fullName))) {
                        Label(item.name, systemImage: "number")
                    }.contextMenu {
                        Button(role: .destructive) {
                            Task {
                                try await memosViewModel.deleteTag(name: item.fullName)
                            }
                        } label: {
                            Label("memo.delete", systemImage: "trash")
                        }
                    }
                }
            } header: {
                Text("tags")
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .vision {
                Button(action: {
                    selection = .settings
                }) {
                    Image(systemName: "ellipsis.circle")
                }
            } else {
                NavigationLink(value: Route.settings) {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .navigationTitle(userState.currentUser?.nickname ?? NSLocalizedString("memo.memos", comment: "Memos"))
    }
}
