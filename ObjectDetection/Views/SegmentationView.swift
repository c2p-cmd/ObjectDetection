//
//  SegmentationView.swift
//  ObjectDetection
//
//  Created by Sharan Thakur on 04/05/23.
//

import Foundation
import UIKit
import SwiftUI

struct SegmentedDrawingView: UIViewRepresentable {
    func updateUIView(_ uiView: DrawingSegmentationView, context: Context) {
        uiView.segmentationmap = self.segmentationMap
    }
    
    @Binding var segmentationMap: SegmentationResultMLMultiArray?
    
    typealias UIViewType = DrawingSegmentationView
    
    func makeUIView(context: Context) -> DrawingSegmentationView {
        let img: DrawingSegmentationView = DrawingSegmentationView()
        img.backgroundColor = .clear
        img.contentMode = .scaleToFill
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }
}

class DrawingSegmentationView: UIView {
    private var blackWhiteColor: [Int32 : UIColor] = [
        7: UIColor(red: 1, green: 0, blue: 0, alpha: 1),
        0: UIColor(red: 0, green: 1, blue: 0, alpha: 1),
        15: UIColor(white: 0.5, alpha: 1)
    ]
    
    func segmentationColor(with index: Int32) -> UIColor {
        if let color = blackWhiteColor[index] {
            return color
        } else {
            let color = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            blackWhiteColor[index] = color
            return color
        }
    }
    
    var segmentationmap: SegmentationResultMLMultiArray? = nil {
        didSet {
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        if let ctx = UIGraphicsGetCurrentContext() {
            
            ctx.clear(rect);
            
            guard let segmentationmap = self.segmentationmap else { return }
            
            let size = self.bounds.size
            let segmentationmapWidthSize = segmentationmap.segmentationmapWidthSize
            let segmentationmapHeightSize = segmentationmap.segmentationmapHeightSize
            let w = size.width / CGFloat(segmentationmapWidthSize)
            let h = size.height / CGFloat(segmentationmapHeightSize)
            
            for j in 0..<segmentationmapHeightSize {
                for i in 0..<segmentationmapWidthSize {
                    let value = segmentationmap[j, i].int32Value
                    
                    let rect: CGRect = CGRect(x: CGFloat(i) * w, y: CGFloat(j) * h, width: w, height: h)
                    
                    print(value)
                    let color: UIColor = segmentationColor(with: value)
                    
                    color.setFill()
                    UIRectFill(rect)
                }
            }
        }
    }
}
