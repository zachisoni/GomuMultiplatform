//
//  InformationText.swift
//  Gomu
//
//  Created by Asad on 26/03/25.
//
import SwiftUI

public struct InformationText: View{
    var label: String
    var data: String
    var fontSize: CGFloat = 48
    var vertical: Bool = true
    var padVertical: CGFloat = 20
    var padHorizontal: CGFloat = 20
    public var body: some View {
        
        if vertical{
            VStack{
                Text(label)
                    .font(.system(.headline,design:.rounded))
                Text(data)
                    .font(.system(size: fontSize, design: .rounded))
                    .bold()
            }
            .foregroundColor(.white)
            .padding(.vertical, padVertical)
            .padding(.horizontal, padHorizontal)
        } else {
            HStack{
                Text(label)
                    .font(.system(.headline,design:.rounded))
                Spacer()
                Text(data)
                    .font(.system(size: fontSize, design: .rounded))
                    .bold()
            }
            .foregroundColor(.white)
            .padding(.vertical, padVertical)
            .padding(.horizontal, padHorizontal)
        }
    }
}
