//
//  StartRunView.swift
//  Gomu
//
//  Created by Asad on 09/05/25.
//

import SwiftUI

struct MainRunView: View {
    @StateObject var runViewModel: RunViewModel
    @State var goal: Int = 0
    
    var body: some View {
        ZStack{
            Color("primary")
                .ignoresSafeArea()
            VStack{
                InformationText(
                    label: "Time",
                    data: runViewModel.formatTime(runViewModel.currentRun.duration),
                    fontSize: 24, vertical: false)
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
                } else {
                    Text("\(String(format: "%.2f", runViewModel.currentRun.distance)) km")
                        .font(.title2)
                        .bold(true)
                }
                HStack{
                    InformationText(label: "bpm", data: runViewModel.currentRun.avgBpm.formatted(), fontSize: 24)
                    InformationText(label: "Pace", data: runViewModel.currentRun.averagePace, fontSize: 24)
                }
            }
        }
    }
}

#Preview {
    MainRunView(runViewModel: RunViewModel())
}
