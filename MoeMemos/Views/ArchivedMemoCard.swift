//
//  ArchivedMemoCard.swift
//  MoeMemos
//
//  Created by Mudkip on 2023/3/26.
//

import SwiftUI
import UniformTypeIdentifiers
import Models

@MainActor
struct ArchivedMemoCard: View {
    let memo: Memo
    let archivedViewModel: ArchivedMemoListViewModel

    @Environment(MemosViewModel.self) private var memosViewModel: MemosViewModel
    @Environment(\.openURL) private var openURL: OpenURLAction   
    @State private var showingDeleteConfirmation = false

    init(_ memo: Memo, archivedViewModel: ArchivedMemoListViewModel) {
        self.memo = memo
        self.archivedViewModel = archivedViewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(memo.renderTime())
                    .font(.footnote)
                    .foregroundColor(.secondary)
                                
                Spacer()
                
                Menu {
                    archivedMenu()
                } label: {
                    Image(systemName: "ellipsis")
                        .padding([.leading, .top, .bottom], 10)
                }
            }
            
            MemoCardContent(memo: memo, toggleTaskItem: nil)
        }
        .padding([.top, .bottom], 5)
        .contextMenu {
            Button {
                UIPasteboard.general.setValue(memo.content, forPasteboardType: UTType.plainText.identifier)
            } label: {
                Label("memo.copy", systemImage: "doc.on.doc")
            }
        }
        .confirmationDialog("memo.delete.confirm", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("memo.action.ok", role: .destructive) {
                Task {
                    guard let remoteId = memo.remoteId else { return }
                    try await archivedViewModel.deleteMemo(remoteId: remoteId)
                }
            }
            Button("memo.action.cancel", role: .cancel) {}
        }
    }
    
    @ViewBuilder
    private func archivedMenu() -> some View {
        Button {
            Task {
                do {
                    guard let remoteId = memo.remoteId else { return }
                    try await archivedViewModel.restoreMemo(remoteId: remoteId)
                    try await memosViewModel.loadMemos()
                } catch {
                    print(error)
                }
            }
        } label: {
            Label("memo.restore", systemImage: "tray.and.arrow.up")
        }
        
        Button {
            UIPasteboard.general.setValue(memo.content, forPasteboardType: UTType.plainText.identifier)
        } label: {
            Label("memo.copy_to_clipboard", systemImage: "doc.on.clipboard")
        }
        
        Button {
            // if let url = URL(string: "\(memosServerURL)/m/\(memo.uid)") {
            if let url = URL(string: "https://workmemos.erauner.synology.me/m/\(memo.remoteId ?? "")") {
                openURL(url)
            }
        } label: {
            Label("memo.open_in_browser", systemImage: "safari")
        }
        
        Button(role: .destructive, action: {
            showingDeleteConfirmation = true
        }, label: {
            Label("memo.delete", systemImage: "trash")
        })
    }
}
