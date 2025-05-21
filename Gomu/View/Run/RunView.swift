//
//  RunView.swift
//  Gomu
//
//  Created by Franco Antonio Pranata on 25/03/25.
//


import SwiftUI
import SwiftData

public struct RunView: View {
    @ObservedObject var viewModel: RunViewModel
    @State private var isShowingSettings = false
    @State private var isShowingProfile = false
//    @Binding var isRunning: Bool
    @StateObject private var chatViewModel = ChatViewModel()
    @Binding var path: NavigationPath
    
    @Binding var selectedTab: Int
    
    private func triggerMediumHaptic(){
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
    
    public var body: some View {
        ZStack {
            Color("primary")
                .ignoresSafeArea(.all)
            
            VStack {
                Spacer(minLength: 0)
                
                VStack {
                    Image("ChatBallon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .overlay(
                            GeometryReader { geometry in
                                Text(chatViewModel.currentMessage)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(3)
                                    .foregroundColor(Color("message"))
                                    .frame(width: 230, height: 110)
                                    .position(x: 127, y: 104)
                            }
                        )
                    
                    Image("Gomu")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                }
                VStack {
                    Stepper(value: $viewModel.currentRun.goal, in: 0...100) {
                        Text(viewModel.currentRun.goal > 0 ? "Goal: \(viewModel.currentRun.goal) km" : "No Goal")
                            .font(.headline)
                            .foregroundStyle(Color("white"))
                    }
                    .foregroundStyle(Color("white"))
                    Button(action: {
                        print("Start button tapped")
                        triggerMediumHaptic()
//                        viewModel.isRunning = true
                        viewModel.startRun()
                        path.append("startRun")
                    }) {
                        Text("Start")
                            .font(.system(.title2, design: .rounded))
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .padding()
                            .frame(width: 180, height: 50)
                            .background(Color("secondary"))
                            .cornerRadius(25)
                    }
                }.padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.bottom, 80)
        }
        .onDisappear {
            chatViewModel.stopAudio()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
}


#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTab = 1
        @State private var path = NavigationPath()
        
        var body: some View {
            do {
                let container = try ModelContainer(for: RunModel.self)
                return AnyView(
                    RunView(
                        viewModel: RunViewModel(context: container.mainContext), path: $path, selectedTab: $selectedTab
                    )
                    .modelContainer(container)
                )
            } catch {
                return AnyView(Text("Preview Error: \(error.localizedDescription)"))
            }
        }
    }
    
    return PreviewWrapper()
}

