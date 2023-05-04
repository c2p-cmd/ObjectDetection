//
//  ViewFinder.swift
//  ObjectDetection
//
//  Created by Sharan Thakur on 04/05/23.
//

import SwiftUI
import AVFoundation
import UIKit

struct Viewfinder: UIViewRepresentable {
    var session: AVCaptureSession
    var dataOutput: AVCaptureVideoDataOutput
    var captureOutput: (AVCaptureOutput, CMSampleBuffer, AVCaptureConnection) -> Void
    
    func makeUIView(context: Context) -> LegacyViewfinder {
        let legacyView = LegacyViewfinder()
        legacyView.captureOutputCompletion = captureOutput
        
        dataOutput.setSampleBufferDelegate(legacyView.self, queue: DispatchQueue(label: "videoQueue"))
        session.addOutput(dataOutput)
        if let previewLayer = legacyView.layer as? AVCaptureVideoPreviewLayer {
            previewLayer.session = session
        }
        return legacyView
    }
    
    func updateUIView(_ uiView: LegacyViewfinder, context: Context) {
        // TODO:
    }
    
    typealias UIViewType = LegacyViewfinder
}

class LegacyViewfinder: UIView, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureOutputCompletion: ((AVCaptureOutput, CMSampleBuffer, AVCaptureConnection) -> Void)?
    
    // We need to set a type for our layer
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    
    // Inherited from 
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.captureOutputCompletion?(output, sampleBuffer, connection)
    }
}
