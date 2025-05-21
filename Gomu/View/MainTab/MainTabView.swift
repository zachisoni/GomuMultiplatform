//
//  MainTabView.swift
//  Gomu
//
//  Created by Franco Antonio Pranata on 25/03/25.
//

//
//import SwiftUI
//import SwiftData
//
//struct MainTabView: View {
//    @Environment(\.modelContext) private var modelContext
//    @State private var selectedTab = 1
//    @StateObject private var viewModel: RunViewModel
//
//    init() {
//        _viewModel = StateObject(wrappedValue: RunViewModel())
//    }
//    var body: some View {
//        ZStack {
//            Color("primary").ignoresSafeArea(.all)
//
//            VStack {
//                Spacer()
//                if selectedTab == 0 {
//                    HomeView()
//                } else if selectedTab == 1 {
//                    RunView(viewModel: viewModel, selectedTab: $selectedTab)
//                } else if selectedTab == 2 {
//                    ReportView(viewModel: viewModel)
//                }
//                Spacer()
//            }
//
//            VStack {
//                Spacer()
//                CustomTabBar(selectedTab: $selectedTab)
//            }
//            .edgesIgnoringSafeArea(.bottom)
//        }.onAppear {
//            viewModel.setContext(modelContext)
//        }
//    }
//}
//
//struct CustomTabBar: View {
//    @Binding var selectedTab: Int
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 25)
//                .fill(Color("primary"))
//                .frame(height: 75)
//
//            HStack {
//                Button(action: { selectedTab = 0 }) {
//                    Image(systemName: "house.fill")
//                        .font(.title)
//                        .foregroundColor(selectedTab == 0 ? Color("white") : Color("secondary"))
//                }
//
//                Spacer()
//
//                Button(action: { selectedTab = 1 }) {
//                    Image(systemName: "figure.run")
//                        .font(.title)
//                        .foregroundColor(Color("white"))
//                        .padding()
//                        .background(Color("secondary"))
//                        .clipShape(Circle())
//                }
//                .offset(y: -20)
//
//                Spacer()
//
//                Button(action: { selectedTab = 2 }) {
//                    Image(systemName: "chart.bar.fill")
//                        .font(.title)
//                        .foregroundColor(selectedTab == 2 ? Color("white") : Color("secondary"))
//                }
//            }
//            .padding(.horizontal, 60)
//        }
//    }
//}
//
//#Preview {
//    MainTabView()
//        .modelContainer(try! ModelContainer(for: RunModel.self))
//}

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: RunViewModel
    @State private var selectedTab = 1 // 1 = RunView sebagai default
    @State private var path = NavigationPath()
    @State private var isRunning = false
    
    @State private var isShowingSettings = false
    @State private var isShowingProfile = false

    
    init() {
        _viewModel = StateObject(wrappedValue: RunViewModel())
        #if os(iOS)
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(named: "primary")
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor(named: "secondary")
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named: "secondary") ?? .gray]
        itemAppearance.selected.iconColor = UIColor(named: "secondary")
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(named: "secondary") ?? .gray]
        
        tabBarAppearance.stackedLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        #endif
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                RunView(viewModel: viewModel, path: $path, selectedTab: $selectedTab)
                    .tabItem {
                        Label("Run", systemImage: "figure.run")
                    }
                    .tag(1)
                
                ReportView(viewModel: viewModel)
                    .tabItem {
                        Label("Activity", systemImage: "chart.bar.fill")
                    }
                    .tag(2)
            }
            .onAppear {
                viewModel.setContext(modelContext)
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "startRun":
                    StartRunView(viewModel: viewModel, selectedTab: $selectedTab, path: $path)
                case "stopRun":
                    StopRunView(viewModel: viewModel, selectedTab: $selectedTab, path: $path)
                default:
                    let _  = print("Error: No Route named: \(destination)")
                }
            }
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
            .fullScreenCover(isPresented: $isShowingSettings) {
                SettingsView()
            }
            .fullScreenCover(isPresented: $isShowingProfile) {
                ProfileView()
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(try! ModelContainer(for: RunModel.self))
}
