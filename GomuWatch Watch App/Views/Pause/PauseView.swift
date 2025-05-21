//
//  PauseView.swift
//  Gomu
//
//  Created by Asad on 14/05/25.
//

import SwiftUI

struct PauseView: View {
    @Binding var navigationPath: NavigationPath
    @ObservedObject var runViewModel: RunViewModel
    
    var body: some View {
        ZStack{
            Color("primary")
                .ignoresSafeArea(edges: .all)
            VStack{
                HStack{
                    Text("Paused")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Text(runViewModel.formatTime(runViewModel.currentRun.duration))
                        .font(.system(size: 14, weight: .regular))
                }
                .padding(.horizontal)
                ScrollView {
                    Image("ChatBallonPause")
                        .resizable()
                        .frame(width: 200)
                        .scaledToFit()
                        .position(x: 100, y:50)
                        .overlay(
                            GeometryReader { geometry in
                                Text(/*chatViewModel.currentMessage*/
                                    "Are you sure you want to stop?\nYou’ve come this far!")
                                .font(.system(size: 12, weight: .semibold))
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.5)
                                .lineLimit(3)
                                .foregroundColor(Color("message"))
                                .position(x:100, y: 35)
                            }
                        )
                    HStack{
                        // Tombol Stop
                        CircularButton(iconName: "stop.fill", background: Color.black, borderColor: Color.white)
                        {
                            print("stop pressed")
                            runViewModel.stopRun()
                            navigationPath.removeLast()
                            navigationPath.removeLast()
                            navigationPath.append(WatchRoute.summaryWatch)
                        }
                        .frame(width: 70, height: 70)
                        .padding(.horizontal)
                        
                        CircularButton(iconName: "play.fill")
                        {
                            print("resume pressed")
                            runViewModel.resumeRun()
                            navigationPath.removeLast()
                        }
                        .frame(width: 70, height: 70)
                        .padding(.horizontal)
                    }
                        .padding(.horizontal)
                    if runViewModel.currentRun.goal > 0 {
                        Gauge(value: runViewModel.currentRun.distance, in: 0...Double(runViewModel.currentRun.goal)){
                            Text("Distance")
                        } currentValueLabel: {
                            VStack{
                                Text("\(String(format: "%.2f", runViewModel.currentRun.distance))/")
                                    .font(.headline)
                                Text("\( runViewModel.currentRun.goal.formatted()) km")
                            }
                        }
                        .font(.system(size: 64))
                        .gaugeStyle(.accessoryCircularCapacity)
                        .tint(Color("secondary"))
                        .scaleEffect(2)
                        .padding(.vertical, 32)
                    } else {
                        Text("\(String(format: "%.2f", runViewModel.currentRun.distance)) km")
                            .font(.title)
                            .bold(true)
                            .padding(.top, 32)
                    }
                    HStack{
                        InformationText(label: "bpm", data: runViewModel.currentRun.avgBpm.formatted(), fontSize: 24, padVertical: 6)
                        InformationText(label: "Pace", data: runViewModel.currentRun.averagePace, fontSize: 24, padVertical: 6)
                    }
                    HStack{
                        InformationText(label: "Steps", data: runViewModel.currentRun.steps.formatted(), fontSize: 24, padVertical: 6)
                        InformationText(label: "Calories", data: runViewModel.currentRun.calories.formatted(), fontSize: 24, padVertical: 6)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    @Previewable @State var navigationPath = NavigationPath()
    PauseView(navigationPath: $navigationPath, runViewModel: RunViewModel())
}
