//
//  PreviewView.swift
//  SC13-Experiences
//
//  Created by Andrew Dhan on 10/19/18.
//  Copyright © 2018 Andrew Liao. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
