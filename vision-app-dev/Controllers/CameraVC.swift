//
//  ViewController.swift
//  vision-app-dev
//
//  Created by Николай Маторин on 21.12.2017.
//  Copyright © 2017 Николай Маторин. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

enum FlashState {
    case off, on
}

class CameraVC: UIViewController, AVCapturePhotoCaptureDelegate, AVSpeechSynthesizerDelegate {
    
    // Outlets
    @IBOutlet weak var captureImgView: UIImageView!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var identificationLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    // Variables
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoData: Data?
    var flashControlState: FlashState = .off
    var speechSynthesizer = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        cameraView.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
        speechSynthesizer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        spinner.isHidden = true
        
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
        cameraView.isUserInteractionEnabled = false
        spinner.isHidden = false
        spinner.startAnimating()
        
        let settings = AVCapturePhotoSettings()
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        settings.flashMode = flashControlState == .off ? .off : .on
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func flashBtnPressed(_ sender: Any) {
        switch flashControlState {
        case .on:
            flashControlState = .off
            flashBtn.setTitle("FLASH OFF", for: .normal)
        case .off:
            flashControlState = .on
            flashBtn.setTitle("FLASH ON", for: .normal)
        }
    }
    
    func resultsMethod(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else {
            return
        }
        
        let unkownObjectMessage = "I'm not sure what this is. Please try again"
        
        for classification in results {
            print(classification.identifier)
            
            let identification = classification.identifier
            let confidence = classification.confidence
            
            if confidence < 0.5 {
                identificationLbl.text = unkownObjectMessage
                synthesizeSpeech(fromString: unkownObjectMessage)
                confidenceLbl.text = ""
                break
            } else {
                identificationLbl.text = identification
                confidenceLbl.text = "CONFIDENCE: \(Int(confidence * 100))%"
                let completeSentence = "This looks like a \(identification) and I'm \(confidence) percent sure"
                synthesizeSpeech(fromString: completeSentence)
                break
            }
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
            return
        }
        photoData = photo.fileDataRepresentation()
        if let photoData = photoData {
            captureImgView.image = UIImage(data: photoData)
            do {
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
                let handler = VNImageRequestHandler(data: photoData)
                try handler.perform([request])
            } catch {
                debugPrint(error)
            }
        }
    }
    
    func synthesizeSpeech(fromString string: String) {
        let speechUtterance = AVSpeechUtterance(string: string)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(speechUtterance)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        cameraView.isUserInteractionEnabled = true
        spinner.isHidden = true
        spinner.stopAnimating()
    }
}

