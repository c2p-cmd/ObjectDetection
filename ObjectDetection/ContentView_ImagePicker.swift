//
//  ContentView_ImagePicker.swift
//  ObjectDetection
//
//  Created by Sharan Thakur on 20/05/23.
//

import SwiftUI
import CoreML
import Vision

struct ContentView_ImagePicker: View {
    // ML stuff
    private var config = MLModelConfiguration()
    private var objectDetectionModel: VNCoreMLModel
    private var imageSegmentationModel: VNCoreMLModel
    @State private var segmentationMap: SegmentationResultMLMultiArray?
    
    // UI stuff
    @State private var toShowPicker = false
    @State private var uiImage: UIImage
    private let defaultImage = UIImage(systemName: "photo.fill")!
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
        
        uiImage = self.defaultImage
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Pick An Image\nFor Image Segmentation\nObject Detection")
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)
                .monospaced()
            Spacer()
            HStack {
                VStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                    Text("Without")
                }
                VStack {
                    ZStack {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                        SegmentedDrawingView(
                            segmentationMap: $segmentationMap
                        )
                    }.scaledToFit()
                    Text("With")
                }
            }
            VStack {
                Text(name)
                Text(accuracy)
            }.padding()
            Spacer()
            Button("Pick From Gallery", action: buttonAction)
        }
        .padding(.vertical, 50)
        .padding(.horizontal, 20)
        .sheet(isPresented: self.$toShowPicker) {
            ImagePicker(
                uiImage: self.$uiImage,
                completionHandler: onNewImage
            )
        }
    }
    
    private func onNewImage(_ newImage: UIImage) {
        let requests = [imageSegmentation(), objectDetection()]
        
        guard let imageData = newImage.pngData() else {
            return
        }
        
        try! VNImageRequestHandler(data: imageData).perform(requests)
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
            
            guard let firstObservation = results.max(by: { v1, v2 in
                v1.confidence < v2.confidence
            }) else { return }
            
            let name: String = firstObservation.identifier
            let acc: Int = Int(firstObservation.confidence * 100)
            
            self.name = "Object: \(name.capitalized)"
            self.accuracy = "Accuracy: \(acc)%"
        }
        
        return request
    }
    
    private func buttonAction() {
        withAnimation {
            self.toShowPicker.toggle()
        }
    }
}

struct ContentView_ImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        ContentView_ImagePicker()
    }
}
