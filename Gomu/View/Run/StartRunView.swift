//
//  RunView.swift
//  Gomu
//
//  Created by Franco Antonio Pranata on 25/03/25.
//

import SwiftUI
import SwiftData


public struct StartRunView: View {
    @ObservedObject var viewModel: RunViewModel
//    @State private var isPaused: Bool = false
    @Binding var selectedTab: Int
//    @Binding var isRunning: Bool
    @Binding var path: NavigationPath
    @ObservedObject var soundManager = SoundRunManager.shared

    private func triggerMediumHaptic(){
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
    
    public var body: some View {
        ZStack{
            Color("primary")
                .ignoresSafeArea(.all)
            VStack{
                Spacer()
                Image("BackgroundRun")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all)
            }
            
            VStack{
                VStack{
                    InformationText(label: "kilometers", data: String(format: "%.2f", viewModel.currentRun.distance))
                    HStack{
                        InformationText(label: "Time", data: viewModel.formatTime(viewModel.currentRun.duration))
                        InformationText(label: "Avg. Pace", data: viewModel.currentRun.averagePace)
                    }
                }
                .padding()
                
                Spacer()
                
                VStack{
                    ZStack{
                        Image("ChatBallon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 160)
                        
                        Text(soundManager.currentMessage)
//                        Text("Bruh, you're literally unstoppable right now.")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                            .lineLimit(3)
                            .foregroundColor(Color("message"))
//                            .background(Color.blue)
                            .frame(width: 250, height: 160)
//                            .padding(.bottom, 20)
                            .position(x: 198, y: 60)

                    }
//                    .overlay(
//                        GeometryReader { geometry in
//                            Text(chatViewModel.currentMessage)
//                                .font(.headline)
//                                .fontWeight(.semibold)
//                                .multilineTextAlignment(.center)
//                                .minimumScaleFactor(0.5)
//                                .lineLimit(3)
//                                .foregroundColor(Color("message"))
//                                .frame(width: 230, height: 110)
//                                .position(x: 127, y: 104)
//                        }
//                    )
                    
                    Image("Gomu")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
                
                Button(action: {
                    print("pause")
                    triggerMediumHaptic()
                    viewModel.pauseRun()
//                    isPaused = true
//                    self.viewModel.isRunning = false
                    path.append("stopRun")
                }){
                    Image(systemName: "pause")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(30)
                        .foregroundColor(.white)
                        .background(Color("secondary"))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 20)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            print("StartRunView muncul")
        }

        .onDisappear {
            print("StartRunView hilang")
        }
        
    }
    
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTab = 1
        @State private var path = NavigationPath()

        var body: some View {
            StartRunView(viewModel: RunViewModel(), selectedTab: $selectedTab, path: $path
//                         , isRunning: .constant(true)
            )
                .modelContainer(try! ModelContainer(for: RunModel.self))
        }
    }
    
    return PreviewWrapper()
}
