//
//  HomeView.swift
//  Gomu
//
//  Created by Franco Antonio Pranata on 25/03/25.
//

import SwiftUI

struct Challenge: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

let challenges: [Challenge] = [
    Challenge(
        imageName: "PerfectWeek",
        title: "Run Streak Revolution: 30 Days Non-Stop Tracking Challenge",
        description: "Track every run in Gomu for 30 consecutive days. No distance requirements—just stay consistent!"
    ),
    Challenge(
        imageName: "KilometerCrusher",
        title: "Climb High: Conquer 100 Floors in 10 Days",
        description: "Take the stairs and track your elevation—100 floors in just 10 days. Your legs will thank you later."
    ),
    Challenge(
        imageName: "StepStarter",
        title: "Speed Sprint Showdown: 5K Under 25 Minutes",
        description: "Challenge yourself to break the 25-minute barrier. Can you sprint your way to victory?"
    ),
    // Tambahkan challenge lainnya di sini
]


public struct HomeView: View {
    @State private var isShowingSettings = false
    @State private var isShowingProfile = false
    
    public var body: some View {
        ZStack {
            Image("AwanHome")
            
            VStack {
                HStack {
                    Text("Weekly Goals")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color("white"))
                        .padding(.leading, 20)
                    Spacer()
                }
                .padding(.top, 15)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("white3"))
                        .frame(height: 175)
                        .padding(.horizontal, 20)
                    
                    VStack {
                        Text("0.00 Km / 10.00 Km")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .bold()
                        
                        Gauge(value: 2.5, in: 0...5){
                        }
                        .frame(width: 300)
                        .tint(Color("secondary"))
                        .overlay(content: {
                            Capsule()
                                .foregroundStyle(Color("secondary"))
                                .opacity(0.2)
                        })
                        .padding(.bottom, 12)
                        
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("secondary"))
                                .frame(width: 120, height: 40)
                            
                            Text("Set goal")
                                .font(.headline)
                                .bold()
                                .foregroundStyle(.white)
                        }
                    }
                }
                
                HStack {
                    Text("Challenge")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color("white"))
                        .padding(.leading, 20)
                    Spacer()
                }
                .padding(.top, 15)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(challenges) { challenge in
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("white3"))
                                
                                HStack(alignment: .top, spacing: 12) {
                                    Image(challenge.imageName)
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(challenge.title)
                                            .font(.headline)
                                            .foregroundColor(.black)
                                            .lineLimit(2)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Text(challenge.description)
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .lineLimit(3)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(width: 300, height: 175)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .padding(.top, 10)
        }
        .background(Color("primary"))
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


#Preview {
    HomeView()
}
