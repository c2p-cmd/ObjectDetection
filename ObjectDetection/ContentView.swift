//
//  ContentView.swift
//  ObjectDetection
//
//  Created by Sharan Thakur on 26/04/23.
//

import SwiftUI
import Vision
import AVKit

struct ContentView: View {
    var session = AVCaptureSession()
    var config = MLModelConfiguration()
    var dataOutput = AVCaptureVideoDataOutput()
    var model: MLModel
    
    init() {
        // Pass the configuration in to the initializer.
        do {
            let resnet = try Resnet50(configuration: config)
            // Use the model if init was successful.
            self.model = resnet.model
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
        
        // Start the AVCapture session
        session.startRunning()
    }
    
    @State private var name = "Object Name"
    @State private var accuracy = "Accuracy 0%"
    
    var body: some View {
        return VStack {
            Viewfinder(session: self.session, dataOutput: self.dataOutput, captureOutput: captureOutput)
            VStack {
                Text(name)
                Text(accuracy)
            }.padding()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
            guard let firstObservation = results.first else {return}
            
            let name: String = firstObservation.identifier
            let acc: Int = Int(firstObservation.confidence * 100)
            
            DispatchQueue.main.async {
                self.name = name
                self.accuracy = "Accuracy: \(acc)%"
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
