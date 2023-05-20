//
//  ContentView_ObjectDetectionOnly.swift
//  ObjectDetection
//
//  Created by Sharan Thakur on 20/05/23.
//

import Vision
import SwiftUI
import AVFoundation

struct ContentView_ObjectDetectionOnly: View {
    private var session = AVCaptureSession()
    private var dataOutput = AVCaptureVideoDataOutput()
    private var config = MLModelConfiguration()
    private var objectDetectionModel: VNCoreMLModel
    private var speechModel = SpeechModel()
    
    // Binding
    @State private var name = "Object Name"
    @State private var accuracy = "Accuracy 0%"
    
    init() {
        // Pass the configuration in to the initializer.
        do {
            let resnet = try Resnet50(configuration: config)
            
            // Use the model if init was successful.
            self.objectDetectionModel = try VNCoreMLModel(for: resnet.model)
        } catch {
            // Handle the error if any.
            fatalError(error.localizedDescription)
        }
        session.beginConfiguration()
        
        // Get the capture device
        DEVICE : if let frontCameraDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) {
            // Set the capture device
            do {
                try! session.addInput(AVCaptureDeviceInput(device: frontCameraDevice))
            }
        }
        
        // END Setting configuration properties
        session.commitConfiguration()
    
        startSessionAsync()
    }
    
    var body: some View {
        VStack {
            ZStack {
                Viewfinder(
                    session: self.session,
                    dataOutput: self.dataOutput,
                    captureOutput: self.captureOutput
                )
            }
            VStack {
                Text(name)
                Text(accuracy)
            }.padding()
        }.onDisappear {
            speechModel.stopSpeech()
        }.navigationTitle("Realtime Object Detection")
    }
    
    private func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let requests = [objectDetection()]
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform(requests)
    }
    
    private func objectDetection() -> VNCoreMLRequest {
        let request = VNCoreMLRequest(model: self.objectDetectionModel) { (finishedReq, err) in
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.max(by: {
                v1, v2 in
                v1.confidence < v2.confidence
            }) else { return }
            
            let name: String = firstObservation.identifier
            let acc: Int = Int(firstObservation.confidence * 100)
            
            self.name = "DetectedObjectName: \(name)"
            self.accuracy = "Accuracy: \(acc)%"
            
            self.speechModel.textToSpeech(textToSpeak: name)
        }
        
        return request
    }
    
    private func startSessionAsync() {
        DispatchQueue.global(qos: .background).async {
            // Start the AVCapture session
            self.session.startRunning()
        }
    }
}
