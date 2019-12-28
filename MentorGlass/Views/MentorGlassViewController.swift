//
//  ViewController.swift
//  MentorGlass
//
//  Created by Ren Matsushita on 2019/12/26.
//  Copyright © 2019 Ren Matsushita. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreML
import SafariServices
import RxSwift
import RxCocoa

final class MentorGlassViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet private weak var cameraView: UIView!
    @IBOutlet private weak var resultLabel: UILabel!
    
    private var ciImage: CIImage?
    private var captureLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet private weak var mentorView: UIView!
    @IBOutlet private weak var mentorNameLabel: UILabel!
    @IBOutlet private weak var mentorCorseLabel: UILabel!
    @IBOutlet private weak var mentorUniversityLabel: UILabel!
    @IBOutlet private weak var mentorDescLabel: UILabel!
    @IBOutlet private weak var destinationFacebookButton: UIButton!
    
    
    private let disposeBag: DisposeBag = DisposeBag()
    private var currentMentor: Mentor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCamera()
        configureMentorView()
        
        destinationFacebookButton.rx.tap
            .subscribe(onNext: { _ in
                guard let _currentMentor: Mentor = self.currentMentor else { return }
                let safariViewController = SFSafariViewController(url: _currentMentor.facebookURL)
                self.present(safariViewController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        captureLayer?.frame = view.bounds
    }
    
    func setupCamera() {
        let session = AVCaptureSession()
        captureLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraView.layer.insertSublayer(captureLayer!, at: 0)
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera"))
        session.addInput(input)
        session.addOutput(output)
        session.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if connection.videoOrientation != .portrait {
            connection.videoOrientation = .portrait
            return
        }
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        ciImage = CIImage(cvImageBuffer: buffer)
        faceDetection(buffer)
    }
    
    func faceDetection(_ buffer: CVImageBuffer) {
        let request = VNDetectFaceRectanglesRequest { (request, error) in
            guard let results = request.results as? [VNFaceObservation] else { return }
            if let image = self.ciImage, let result = results.first {
                let face = self.getFaceCGImage(image: image, face: result)
                if let cg = face {
                    self.scanImage(cgImage: cg)
                }
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, options: [:])
        try? handler.perform([request])
    }
    
    func getFaceCGImage(image: CIImage, face: VNFaceObservation) -> CGImage? {
        let imageSize = image.extent.size
        
        let box = face.boundingBox.scaledForCropping(to: imageSize)
        guard image.extent.contains(box) else {
            return nil
        }
        
        let size = CGFloat(300.0)
        
        let transform = CGAffineTransform(
            scaleX: size / box.size.width,
            y: size / box.size.height
        )
        let faceImage = image.cropped(to: box).transformed(by: transform)
        
        let ctx = CIContext()
        guard let cgImage = ctx.createCGImage(faceImage, from: faceImage.extent) else {
            assertionFailure()
            return nil
        }
        return cgImage
    }
    
    func scanImage(cgImage: CGImage) {
        let image = CIImage(cgImage: cgImage)
        
        guard let model = try? VNCoreMLModel(for: MentorGlass5().model) else { return }
    
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else { return }
            guard let mostConfidentResult = results.first else { return }
            
            DispatchQueue.main.async {
                print(mostConfidentResult.hasPrecisionRecallCurve)
                print(mostConfidentResult.hasMinimumPrecision(0.8, forRecall: 0.8))
                let mentor = self.searchMentor(id: mostConfidentResult.identifier)
                self.updateMentorView(mentor: mentor)
            }
        }
        let requestHandler = VNImageRequestHandler(ciImage: image, options: [:])
        try? requestHandler.perform([request])
    }
    
    func configureMentorView() {
        mentorView.isHidden = true
        mentorView.alpha = 0.9
        
        destinationFacebookButton.layer.cornerRadius = 4
        destinationFacebookButton.clipsToBounds = true
    }
    
    func updateMentorView(mentor: Mentor) {
        currentMentor = mentor
        mentorView.isHidden = false
        mentorNameLabel.text = mentor.name
        mentorCorseLabel.text = mentor.corse
        mentorUniversityLabel.text = mentor.university
        mentorDescLabel.text = mentor.description
    }
    
    func searchMentor(id: String) -> Mentor{
        return Mentors.search(id: id)
    }
}
