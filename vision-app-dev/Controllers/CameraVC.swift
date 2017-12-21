//
//  ViewController.swift
//  vision-app-dev
//
//  Created by Николай Маторин on 21.12.2017.
//  Copyright © 2017 Николай Маторин. All rights reserved.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // Outlets
    @IBOutlet weak var captureImgView: UIImageView!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var identificationLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var cameraView: UIView!
    
    // Variables
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        cameraView.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        let backCamera = AVCaptureDevice.default(for: .video)
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            cameraOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(cameraOutput) {
                captureSession.addOutput(cameraOutput!)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            previewLayer.connection?.videoOrientation = .portrait
            
            cameraView.layer.addSublayer(previewLayer!)
            captureSession.startRunning()
        } catch {
            debugPrint(error)
        }
    }
    
    @objc func didTapCameraView() {
        let settings = AVCapturePhotoSettings()
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
            return
        }
        photoData = photo.fileDataRepresentation()
        if let photoData = photoData {
             captureImgView.image = UIImage(data: photoData)
        }
    }
}

