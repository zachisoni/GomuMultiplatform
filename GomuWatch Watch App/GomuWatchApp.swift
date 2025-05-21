//
//  GomuWatchApp.swift
//  GomuWatch Watch App
//
//  Created by Asad on 07/05/25.
//

import SwiftUI

@main
struct GomuWatch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            WatchHomeView(runViewModel: RunViewModel())
        }
    }
}
