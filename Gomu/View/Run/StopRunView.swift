//
//  RunPauseView.swift
//  Gomu
//
//  Created by Asad on 26/03/25.
//

import SwiftUI
import SwiftData
import MapKit
import Foundation

struct StopRunView: View {
    @State private var navigateToReport = false
    @ObservedObject var viewModel: RunViewModel
//    @Binding var isPaused: Bool
    @Binding var selectedTab: Int
    @Binding var path: NavigationPath
//    @Binding var isRunning: Bool
//    @Environment(\.dismiss) var dismiss
    @State var dialog: String = "Are you want to stop?"

    private func triggerMediumHaptic(){
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
    var body: some View {
        ZStack{
            Color("primary")
                .ignoresSafeArea(.all)
            Image("BackgroundRun")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.all)
            VStack{
                MapView(locationManager: viewModel.locationManager)
                RunDetails(locationManager: viewModel.locationManager, viewModel: viewModel)
                    .ignoresSafeArea()
                
                VStack{
                    Gauge(value: 2.5, in: 0...5){
                    }
                    .tint(Color("secondary"))
                    .overlay(content: {
                        Capsule()
                            .foregroundStyle(Color("secondary"))
                            .opacity(0.2)
                    })
                    .padding()
//                    ActionButtons(isPaused: $isPaused,
//                                  viewModel: viewModel)
                    HStack{
                        // Tombol Stop
                        Button(action:{
                            triggerMediumHaptic()
                            print("Stop")
//                            dismiss()
                            viewModel.stopRun()
                            path = NavigationPath()
                            selectedTab = 2
//                            path.removeLast(path.count)
//                            self.isRunning = false
                        }){
                            Image(systemName: "stop.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(20)
                                .foregroundStyle(Color.white)
                                .background(Color.black)
                                .clipShape(.capsule)
                        }.padding(.horizontal)
                        // Tombol Resume
                        Button(action:{
                            triggerMediumHaptic()
                            print("resume")
//                            self.viewModel.isRunning = false
                            viewModel.resumeRun()
                            path.removeLast()
                        }){
                            Image(systemName: "play.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(20)
                                .foregroundStyle(Color.white)
                                .background(Color("secondary"))
                                .clipShape(.circle)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
                HStack{
                    Image("Gomu")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 284)
                        .position(x:70, y:200)
                    ZStack{
                        Image("ChatBallonSecond")
                            .resizable()
                            .scaledToFit()
                        Text(dialog)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .minimumScaleFactor(0.5)
                            .lineLimit(3)
                            .foregroundColor(Color("message"))
                            .position(x: 125, y: 92)
                    }
                    .frame(width: 250)
                    .position(x:20, y:80)
                }
                Spacer()
            }
        }
        .padding(0)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct RunDetails: View{
//    var runData: RunModel
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var viewModel: RunViewModel
    var body: some View{
        VStack{
            HStack{
                InformationText(label: "Time",
                                data: (
                                    ((viewModel.currentRun.duration >= 60 ? DateComponentsFormatter().string(from: viewModel.currentRun.duration)
                                      : (viewModel.currentRun.duration >= 10 ? "00:\(Int(viewModel.currentRun.duration))" : "00:0\(Int(viewModel.currentRun.duration))" )) ?? "00:00")
                                ),
                                fontSize: 30
                                )
                Spacer()
                InformationText(label: "Avg. Pace", data: viewModel.currentRun.averagePace, fontSize: 30)
                Spacer()
                InformationText(label: "Kilometres",
                                data: String(format: "%.2f", viewModel.currentRun.distance),
                                fontSize: 30)
            }
            HStack{
                InformationText(label: "Elevation", data: String(format: "%.2f",(viewModel.currentRun.elevation)), fontSize: 30)
                Spacer()
//                InformationText(label: "BPM", data:( viewModel.bpm != 0 ?  String(format: "%.2f",viewModel.bpm.formatted()) : "--"), fontSize: 30)
                InformationText(label: "BPM", data: viewModel.currentRun.avgBpm.formatted(), fontSize: 30)
                Spacer()
                InformationText(label: "Calories", data: viewModel.currentRun.calories.formatted(), fontSize: 30)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct MapView: View {
    @ObservedObject var locationManager: LocationManager
    let initPosition = CLLocationCoordinate2D(latitude: -6.1754, longitude: 106.8272)
    var body: some View {
        Map(position: .constant(
            MapCameraPosition.region(
                MKCoordinateRegion(
                    center: locationManager.coordinates.last ?? initPosition,
                    span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                )
            )
        )){
            Annotation(
                "Your Location",
                coordinate: locationManager.coordinates.last ?? initPosition
            ){
                Image(systemName: "figure.walk")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(10)
                    .foregroundStyle(Color.white)
                    .background(Color.red)
                    .clipShape(Circle())
            }
            MapPolyline(coordinates: locationManager.coordinates, contourStyle: .straight)
                .stroke(.blue, lineWidth: 5)
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTab = 1  // Tambahkan State untuk selectedTab
        @State private var path = NavigationPath()

        var body: some View {
            do {
                let container = try ModelContainer(for: RunModel.self)
                return AnyView(
                    StopRunView(
                        viewModel: RunViewModel(context: container.mainContext),
//                        isPaused: .constant(false),
                        selectedTab: $selectedTab, path: $path
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


