//
//  ObjectDetectionApp.swift
//  ObjectDetection
//
//  Created by Sharan Thakur on 26/04/23.
//

import SwiftUI

@main
struct ObjectDetectionApp: App {
    var body: some Scene {
        WindowGroup {
            ChooseView()
        }
    }
}

struct ChooseView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Go To View")
                    .font(.largeTitle)
                    .monospaced()
                NavigationLink("Realtime", destination: {
                    ContentView()
                }).font(.title).monospaced()
                NavigationLink("Non-Realtime", destination: {
                    ContentView_ImagePicker()
                }).font(.title).monospaced()
            }
        }
    }
}

struct App_Previews: PreviewProvider {
    static var previews: some View {
        ChooseView()
    }
}
