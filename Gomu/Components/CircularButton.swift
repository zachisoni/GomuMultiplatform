//
//  CircularButton.swift
//  Gomu
//
//  Created by Asad on 15/05/25.
//
import SwiftUI

struct CircularButton: View {
    var iconName: String
    var background: Color = Color("secondary")
    var borderColor: Color = .black
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .padding(16) // icon padding dalam button
//                .frame(width: 100, height: 70)
                .bold(true)
                .foregroundColor(.white)
//                .background(Color.clear)
//                .background(background)
//                .clipShape(Circle())
//                .overlay(
//                    Circle()
//                        .stroke(borderColor, lineWidth: 3)
//                )
        }
        .background(background)
        .foregroundStyle(background)
        .clipShape(Circle())
//        .background(Color.clear)
//        .clipShape(Circle())
    }
}
