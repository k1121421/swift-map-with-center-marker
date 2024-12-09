//
//  ContentView.swift
//  SwiftMapWithCenterMarker
//
//  Created by Keita Nakashima on 2024/12/09.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var mapViewModel = MapViewModel()
    
    var body: some View {
        
        ZStack {
            GoogleMapView()
                .environmentObject(mapViewModel)
            
            Marker(isPressed: mapViewModel.isTouchingMap)
                .offset(y :-30)
        }
        .ignoresSafeArea()

    }
}

struct Marker: View {
    var isPressed: Bool
    
    @State private var circleOffset: CGFloat = 0
    @State private var circleSize: CGFloat = 13
    @State private var lineOffset: CGFloat = 20
    
    var body: some View {
        
        ZStack {
            
            Ellipse()
                .fill(Color.gray.opacity(0.7))
                .frame(width:9, height: 5)
                .offset(y: 35)
            
            Ellipse()
                .fill(Color.black)
                .frame(width:7, height: 3)
                .offset(y: 36)
            
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.blue)
                .frame(width: 3, height: 30)
                .offset(y: lineOffset)
            
            Circle()
                .fill(Color.blue)
                .frame(width: 32)
                .offset(y: circleOffset)
            
            Circle()
                .fill(Color.white)
                .frame(width: circleSize)
                .offset(y: circleOffset)
            
        }
        .padding()
        .onChange(of: isPressed) {
            handleAnimation(pressed: isPressed)
        }
        
    }
    
    private func handleAnimation(pressed: Bool) {
        if pressed {
            withAnimation(.easeOut(duration: 0.06)) {
                circleOffset = -10
                circleSize = 7
                lineOffset = 10
            }
        } else {
            withAnimation(.easeOut(duration: 0.0)) {
                circleOffset = -10
                circleSize = 7
                lineOffset = 10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    circleOffset = 5
                    circleSize = 16
                    lineOffset = 20
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    circleOffset = 0
                    circleSize = 13
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
