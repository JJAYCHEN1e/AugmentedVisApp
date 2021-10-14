//
//  SwiftUIARView.swift
//  SwiftUIARView
//
//  Created by Sarang Borude on 4/10/20.
//  Copyright © 2020 Sarang Borude. All rights reserved.
//

import SwiftUI

struct SwiftUIARCardView: View {
    @State private var textToShow = "Hello AR"
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .edgesIgnoringSafeArea(.all)
            
			ZStack {
				VStack {
					Text(textToShow)
						.foregroundColor(.white)
						.bold().font(.title)
					
					Button(action: {
						self.textToShow = "Button Tapped!"
					}) {
						ZStack {
							RoundedRectangle(cornerRadius: 15)
								.fill(Color.white)
								.frame(width: 150, height: 50)
							Text("Tap Me")
						}
					}
				}
				
				
				
				Path { path in
					path.move(to: .init(x: 100, y: 0))
					path.addLine(to: .init(x: 960, y: 1080))
//					path.addLine(to: .init(x: 100, y: 1920))
//					path.addLine(to: .init(x: 300, y: 400))
//					path.addLine(to: .init(x: 500, y: 1920))
//					path.addLine(to: .init(x: 600, y: 300))
//					path.addLine(to: .init(x: 1920, y: 1920))
					path.addLine(to: .init(x: 1920, y: 0))
					path.addLine(to: .init(x: 100, y: 0))
				}
				.fill(Color.blue.opacity(0.2))
				.onTapGesture {
					print("Tapped")
				}
			}
        }
		.simultaneousGesture(
			TapGesture().onEnded {
				print("Tapped Globally.")
			}
		)
    }
}

struct SwiftUIARCardView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIARCardView()
    }
}
