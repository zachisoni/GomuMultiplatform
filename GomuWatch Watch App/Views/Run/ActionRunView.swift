//
//  PauseRunView.swift
//  Gomu
//
//  Created by Asad on 14/05/25.
//

import SwiftUI

struct ActionRunView: View {
    @Binding var navigationPath: NavigationPath
    @ObservedObject var runViewModel: RunViewModel
    
    var body: some View {
        ZStack {
            Color("primary")
                .ignoresSafeArea()
            VStack{
//                Spacer()
                CircularButton(
                    iconName: "pause",
                ) {
                    print("Pause Pressed")
                    runViewModel.pauseRun()
                    navigationPath.append(WatchRoute.pauseRunWatch)
                }
                .frame(width: 70, height: 70)
//                Spacer()
                Image("Gomu")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                    .position(x:40, y:200)
                Image("ChatBallonWatch")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
//                    .position(x:90)
//                    .padding(10)
                    .overlay(
                        GeometryReader { geometry in
                            Text(/*chatViewModel.currentMessage*/
                                "Back for another walk? \nLove that energy.")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                            .lineLimit(3)
                            .foregroundColor(Color("message"))
//                            .frame(width: 200, height: 100)
                            .position(x:100, y: 60)
                        }
                    )
            }
            .padding(.top, 28)
        }
    }
}

#Preview {
    @Previewable @State var navigationPath = NavigationPath()
    ActionRunView(navigationPath: $navigationPath, runViewModel: RunViewModel())
}
