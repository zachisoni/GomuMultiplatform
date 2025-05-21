//
//  RunView.swift
//  GomuWatch Watch App
//
//  Created by Asad on 08/05/25.
//

import SwiftUI

struct WatchHomeView: View {
    @StateObject var runViewModel: RunViewModel
    @Environment(\.modelContext) private var modelContext
//    @State var goal: Int = 0
    @State var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color("primary")
                    .ignoresSafeArea(.all)
                VStack {
                    Stepper(value: $runViewModel.currentRun.goal, in: 0...100) {
                        Text(runViewModel.currentRun.goal > 0 ? "Goal: \(runViewModel.currentRun.goal) km" : "No Goal")
                            .font(.headline)
                    }
                    
                    Spacer()
                    Button{
                        print("Start button tapped")
                        runViewModel.startRun()
                        print("Goal: \(runViewModel.currentRun.goal)")
                        //triggerMediumHaptic()
                        //viewModel.isRunning = true
                        //viewModel.startRun()
                        navigationPath.append(WatchRoute.startRunWatch)
                    } label: {
                        Text("Start")
                            .font(.system(.title2, design: .rounded))
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .padding()
                    }
                    .foregroundStyle(Color("secondary"))
                    .frame(width: 180, height: 50)
                    .background(Color("secondary"))
                    .cornerRadius(25)
                    Image("Gomu")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .position(x:40, y:150)
                    Image("ChatBallonWatch")
                        .resizable()
                        .frame(width: 200, height: 100)
                        .overlay(
                            GeometryReader { geometry in
                                Text(/*chatViewModel.currentMessage*/
                                    "Back for another walk?\n Love that energy.")
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.5)
                                .lineLimit(3)
                                .foregroundColor(Color("message"))
                                .frame(width: 200, height: 100)
                                .position(x: 100, y: 40)
                            }
                        )
                    
                }
            }
            .padding(.top, 20)
            .navigationDestination(for: WatchRoute.self) { destination in
                switch destination {
                case .startRunWatch:
                    WatchStartRunView(navigationPath: $navigationPath, runViewModel: runViewModel)
                case .pauseRunWatch:
                    PauseView(navigationPath: $navigationPath, runViewModel: runViewModel)
                case .summaryWatch:
                    RunSummary(runViewModel: runViewModel)
                }
            }
            .onAppear {
                runViewModel.setContext(modelContext)
            }
        }
    }
}

#Preview {
    WatchHomeView(runViewModel: RunViewModel())
}
