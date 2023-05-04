//
//  ContentView.swift
//  ObjectDetection
//
//  Created by Sharan Thakur on 26/04/23.
//

import SwiftUI
import Vision
import AVKit
import VideoToolbox

struct ContentView: View {
    private var session = AVCaptureSession()
    private var config = MLModelConfiguration()
    private var dataOutput = AVCaptureVideoDataOutput()
    private var objectDetectionModel: VNCoreMLModel
    private var imageSegmentationModel: VNCoreMLModel
    
    @State private var segmentationMap: SegmentationResultMLMultiArray?
    @State private var name = "Object Name"
    @State private var accuracy = "Accuracy 0%"
    
    init() {
        // Pass the configuration in to the initializer.
        do {
            let resnet = try Resnet50(configuration: config)
            let deepLab = try DeepLabV3(configuration: config)
            
            // Use the model if init was successful.
            self.objectDetectionModel = try VNCoreMLModel(for: resnet.model)
            self.imageSegmentationModel = try VNCoreMLModel(for: deepLab.model)
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
                Viewfinder(session: self.session, dataOutput: self.dataOutput, captureOutput: self.captureOutput)
                SegmentedDrawingView(segmentationMap: $segmentationMap)
            }
            VStack {
                Text(name)
                Text(accuracy)
            }.padding()
        }
    }
    
    private func startSessionAsync() {
        DispatchQueue.global(qos: .background).async {
            // Start the AVCapture session
            self.session.startRunning()
        }
    }
    
    private func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let requests = [objectDetection(), imageSegmentation()]
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform(requests)
    }
    
    private func imageSegmentation() -> VNCoreMLRequest {
        let request = VNCoreMLRequest(model: self.imageSegmentationModel, completionHandler: { finishedReq, err in
            if let observations = finishedReq.results as? [VNCoreMLFeatureValueObservation],
               let segmentationmap = observations.first?.featureValue.multiArrayValue {
                let result = SegmentationResultMLMultiArray(mlMultiArray: segmentationmap)
                self.segmentationMap = result
            }
        })
        
        request.imageCropAndScaleOption = .scaleFill
        
        return request
    }
    
    private func objectDetection() -> VNCoreMLRequest {
        let request = VNCoreMLRequest(model: self.objectDetectionModel) { (finishedReq, err) in
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            
            let name: String = firstObservation.identifier
            let acc: Int = Int(firstObservation.confidence * 100)
            
            self.name = name
            self.accuracy = "Accuracy: \(acc)%"
        }
        
        return request
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
