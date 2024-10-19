//
//  Navigation.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/10/30.
//

import SwiftUI
import Env
import Observation

struct Navigation: View {
    @Bindable var memosViewModel: MemosViewModel
    @Binding var selection: Route?
    @State private var path = NavigationPath([Route.memos])

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .vision {
            NavigationSplitView(sidebar: {
                Sidebar(memosViewModel: memosViewModel, selection: $selection)
            }) {
                NavigationStack {
                    Group {
                        if let selection = selection {
                            selection.destination()
                        } else {
                            EmptyView()
                        }
                    }.navigationDestination(for: Route.self) { route in
                        route.destination()
                    }
                }
            }
        } else {
            NavigationStack(path: $path) {
                Sidebar(memosViewModel: memosViewModel, selection: $selection)
                    .navigationDestination(for: Route.self) { route in
                        route.destination()
                    }
            }
        }
    }
}
