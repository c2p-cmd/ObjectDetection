//
//  Views.swift
//  ObjectDetection
//
//  Created by Sharan Thakur on 26/04/23.
//

import Foundation
import UIKit
import AVFoundation
import SwiftUI

struct Viewfinder: UIViewRepresentable {
    var session: AVCaptureSession
    var dataOutput: AVCaptureVideoDataOutput
    var captureOutput: (AVCaptureOutput, CMSampleBuffer, AVCaptureConnection) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let legacyView = LegacyViewfinder()
        legacyView.captureOutputCompletion = captureOutput
        
        dataOutput.setSampleBufferDelegate(legacyView.self, queue: DispatchQueue(label: "videoQueue"))
        session.addOutput(dataOutput)
        
        PREVIEW: if let previewLayer = legacyView.layer as? AVCaptureVideoPreviewLayer {
            previewLayer.session = session
        }
        return legacyView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // TODO: Stay tuned
    }
    
    typealias UIViewType = UIView
}

class LegacyViewfinder: UIView, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureOutputCompletion: ((AVCaptureOutput, CMSampleBuffer, AVCaptureConnection) -> Void)?
    
    // We need to set a type for our layer
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.captureOutputCompletion?(output, sampleBuffer, connection)
    }
}
