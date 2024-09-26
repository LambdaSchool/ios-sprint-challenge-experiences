//
//  CameraPreviewView.swift
//  Experiences
//
//  Created by Lotanna Igwe-Odunze on 2/24/19.
//  Copyright © 2019 Sugabelly LLC. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewView: UIView {
    
    override class var layerClass: AnyClass {
        //Replaces the layer property with AVCaptureVideoPreviewLayer property
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer }
    //Force casting because I know it's there since I added it.
}
