//
//  RunSummary.swift
//  Gomu
//
//  Created by Asad on 14/05/25.
//

import SwiftUI

struct RunSummary: View {
    @State var locationManager: LocationManager = LocationManager()
    @ObservedObject var runViewModel: RunViewModel
    
    var body: some View {
        ZStack{
            Color("primary").ignoresSafeArea(edges: .all)
            ScrollView {
                Text("\(runViewModel.currentRun.timestamp.formatted())")
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                HStack{
                    // Distance
                    Text("\(String(format: "%.2f", runViewModel.currentRun.distance)) /")
                        .font(.title)
                        .bold(true)
                    // Goal
                    Text("\(runViewModel.currentRun.goal) km")
                        .font(.title2)
                        .fontWeight(.semibold)
                }.padding(.vertical, 4)
                HStack{
                    Text("Time")
                        .font(.caption)
                    Spacer()
                    // Time
                    Text(runViewModel.formatTime(runViewModel.currentRun.duration))
                        .font(.callout)
                        .fontWeight(.semibold)
                }
                HStack{
                    Text("Pace")
                        .font(.caption)
                    Spacer()
                    // Pace
                    Text(runViewModel.currentRun.averagePace)
                        .font(.callout)
                        .fontWeight(.semibold)
                }
                HStack{
                    Text("bpm")
                        .font(.caption)
                    Spacer()
                    // bpm
                    Text(runViewModel.currentRun.avgBpm.formatted())
                        .font(.callout)
                        .fontWeight(.semibold)
                }
                HStack{
                    Text("Steps")
                        .font(.caption)
                    Spacer()
                    // Steps
                    Text(runViewModel.currentRun.steps.formatted())
                        .font(.callout)
                        .fontWeight(.semibold)
                }
                HStack{
                    Text("Calories")
                        .font(.caption)
                    Spacer()
                    // Calories
                    Text(runViewModel.currentRun.calories.formatted())
                        .font(.callout)
                        .fontWeight(.semibold)
                }
                VStack{
                    Text("Track")
                        .font(.caption)
                    MapView(locationManager: locationManager)
                        .frame(height: 150)
                        .clipShape(.rect)
                }.padding(6)
            }
            .padding(.horizontal, 12)
        }
        .navigationTitle(Text("Run Summary"))
        .onDisappear {
            runViewModel.resetWorkout()
        }
    }
}


#Preview {
    RunSummary(runViewModel: RunViewModel())
}
