////
////  ReportView.swift
////  Gomu
////
////  Created by Franco Antonio Pranata on 25/03/25.
////
//
//import SwiftUI
//
//public struct ReportView: View {
//    @ObservedObject var viewModel: RunViewModel
//
//    public var body: some View {
//        VStack {
//            Text("Running History")
//                .font(.title)
//                .bold()
//
//            if viewModel.runs.isEmpty {
//                Text("No run history available.")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//            } else {
//                List(viewModel.runs) { run in
//                    VStack(alignment: .leading) {
//                        Text("Duration: \(run.duration, specifier: "%.2f") sec")
//                        Text("Distance: \(run.distance, specifier: "%.2f") km")
//                        Text("Avg Pace: \(run.averagePace)")
//                        Text("Calories: \(run.calories)")
//                        Text("BPM: \(run.bpm)")
//                    }
//                    .padding()
//                }
//            }
//        }
//        .onAppear {
//            viewModel.fetchRuns() // Pastikan data diperbarui saat ReportView dibuka
//        }
//    }
//}
//
//#Preview {
//    ReportView(viewModel: RunViewModel())
//}

import SwiftUI
import SwiftData

public struct ReportView: View {
    @ObservedObject var viewModel: RunViewModel
    @State private var isShowingProfile = false
    @State private var isShowingSettings = false
    
    public var body: some View {
        ZStack{
            Color("primary")
                .ignoresSafeArea()
            VStack {
                if viewModel.runs.isEmpty {
                    Text("No run history available.")
                        .font(.subheadline)
                        .foregroundColor(Color("white"))
                } else {
                    List(viewModel.runs) { run in
                        VStack(alignment: .leading) {
                            Text(run.timestamp.formatted())
                                .foregroundColor(.gray)
                            Text("🕒 Duration: \(run.duration, specifier: "%.2f") sec")
                            Text("📏 Distance: \(run.distance, specifier: "%.2f") km")
                            Text("🏃 Avg Pace: \(run.averagePace)")
                            Text("🔥 Calories: \(run.calories)")
                            Text("❤️ BPM: \(run.avgBpm)")
                        }
                        .padding()
                        .listRowBackground(Color("white2"))
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color("primary"))
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("primary"))
        .onAppear {
            viewModel.fetchRuns()
        }
//        VStack {
//            if viewModel.runs.isEmpty {
//                Text("No run history available.")
//                    .font(.subheadline)
//                    .foregroundColor(Color("white"))
//            } else {
//                List(viewModel.runs) { run in
//                    VStack(alignment: .leading) {
//                        
//                        Text("🕒 Duration: \(run.duration, specifier: "%.2f") sec")
//                        Text("📏 Distance: \(run.distance, specifier: "%.2f") km")
//                        Text("🏃 Avg Pace: \(run.averagePace)")
//                        Text("🔥 Calories: \(run.calories)")
//                        Text("❤️ BPM: \(run.bpm)")
//                    }
//                    .padding()
//                }
//            }
//            
//            Spacer()
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color("primary"))
        //            .onAppear {
        //                viewModel.fetchRuns()
        //            }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    isShowingProfile = true
                }) {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isShowingSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            #endif
        }
        .fullScreenCover(isPresented: $isShowingProfile) {
            ProfileView()
        }
        .fullScreenCover(isPresented: $isShowingSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ReportView(viewModel: RunViewModel())
        .modelContainer(try! ModelContainer(for: RunModel.self))
}
