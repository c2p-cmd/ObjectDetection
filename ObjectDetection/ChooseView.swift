//
//  ChooseView.swift
//  ObjectDetection
//
//  Created by Sharan Thakur on 20/05/23.
//

import SwiftUI

struct ChooseView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Go To View")
                    .font(.largeTitle)
                    .bold()
                    .monospaced()
                
                Spacer()
                
                NavigationLink("Realtime") {
                    ContentView()
                }
                .font(.title)
                .monospaced()
                
                Spacer()
                
                NavigationLink("Realtime Only Object Detection") {
                    ContentView_ObjectDetectionOnly()
                }
                .font(.title)
                .monospaced()
                
                Spacer()
                
                NavigationLink("Non-Realtime") {
                    ContentView_ImagePicker()
                }
                .font(.title)
                .monospaced()
                Spacer()
            }.padding(.vertical, 33)
        }
    }
}
