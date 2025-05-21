//
//  StartRunView.swift
//  Gomu
//
//  Created by Asad on 09/05/25.
//

import SwiftUI

struct WatchStartRunView: View {
    @Binding var navigationPath: NavigationPath
    @StateObject var runViewModel: RunViewModel
//    @State var goal: Int = 0
    @State var selection: Int = 0
    
    var body: some View {
        TabView(selection: $selection) {
            MainRunView(runViewModel: runViewModel)
                .tag(0)
            ActionRunView(navigationPath: $navigationPath, runViewModel: runViewModel)
                .tag(1)
        }
        .onAppear {
            selection = 0
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    @Previewable @State var navigationPath = NavigationPath()
    WatchStartRunView(navigationPath: $navigationPath, runViewModel: RunViewModel())
}
