//
//  CardScannerUIView.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-10-10.
//

import Foundation
import AVKit
import Vision
import UIKit
import Dispatch

class CardScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var patient: Patient
    var dictLen12 = [String:Int]() //For ID
    var nameDict = [String:Int]() //For name
    var count = 0
    let captureSession = AVCaptureSession()
    
    init(patient: Patient) {
        self.patient = patient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        captureSession.startRunning()


    }
    
    override func viewDidAppear(_ animated: Bool) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        let dataOut = AVCaptureVideoDataOutput()
        dataOut.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOut)
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if "" != patient.name && "" != patient.dateOfBirth && "" != patient.ohipID && "" != patient.ohipExp {
            //Check for invalid name
            if patient.name.contains("Ontario") || patient.name.contains("Health") || patient.name.contains("Santé") {
                patient.name = ""
            } else {
                DispatchQueue.main.async {
                    self.captureSession.stopRunning()
                    self.dismiss(animated: true)
                }
                
            }
        } else {
            if count >= 150 {
                DispatchQueue.main.async {
                    self.patient.ohipID = "XXXX"
                    self.captureSession.stopRunning()
                    self.dismiss(animated: true)
                }
            }
        }
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciimage = CIImage(cvPixelBuffer: pixelBuffer)
        let handler = VNImageRequestHandler(ciImage: ciimage, options: [:])
    
        var textArr = [String]()
        //Request
        let request = VNRecognizeTextRequest { request, error in
            guard let results = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                      return
                  }
            for result in results {
                let observation = result
                for cand in observation.topCandidates(1) {
                    let s = cand.string
                    if s.count == 21 && " - " == s[4...6] && " - " == s[10...12] && self.patient.ohipID == "" {
                        self.checkIfIsId(s)
                    }
                    if s.count == 29 && " - " == s[4...6] && " - " == s[9...11] && " - " == s[19...21] && " - " == s[24...26] && self.patient.ohipExp == "" {
                        self.checkIfIsOhipExp(s)
                    }
                        
                    if s.count == 14 && " - " == s[4...6] && " - " == s[9...11] && self.patient.dateOfBirth == "" {
                        self.checkIfIsDob(s)
                    }
                    if self.patient.dateOfBirth == "" && self.patient.ohipExp == "" && self.patient.ohipID == "" {
                        self.count += 1
                    }
                    textArr.append(s)
                }
            }
            if self.patient.name == "" && textArr.count >= 3 && !self.haveNum(textArr[2]) && self.haveChar(textArr[2]){
                self.checkIfIsName(textArr[2].replacingOccurrences(of: "/", with: "I"))
            }
            
        }
        //Process Request
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    func checkIfIsOhipExp(_ text: String) {
        if dictLen12[text] != nil && dictLen12[text] == 3 {
            patient.ohipExp = text
            return
        }
        if dictLen12[text] != nil {
            dictLen12[text] = dictLen12[text]! + 1
        } else {
            dictLen12[text] = 1
        }
        return
    }
    func checkIfIsId(_ text: String) {
        if dictLen12[text] != nil && dictLen12[text] == 3 {
            patient.ohipID = text
            return
        }
        if dictLen12[text] != nil {
            dictLen12[text] = dictLen12[text]! + 1
        } else {
            dictLen12[text] = 1
        }
        return
    }
    func checkIfIsName(_ text: String) {
        if nameDict[text] != nil && nameDict[text] == 3 {
            patient.name = text
            return
        }
        if nameDict[text] != nil {
            nameDict[text] = nameDict[text]! + 1
        } else {
            nameDict[text] = 1
        }
        return
    }
    func checkIfIsDob(_ text: String) {
        if dictLen12[text] != nil && dictLen12[text] == 3 {
            patient.dateOfBirth = text
            return
        }
        if dictLen12[text] != nil {
            dictLen12[text] = dictLen12[text]! + 1
        } else {
            dictLen12[text] = 1
        }
        return
    }
    func haveNum(_ text: String) -> Bool{
        let deci = CharacterSet.decimalDigits
        if text.rangeOfCharacter(from: deci) != nil {
            return true
        } else {
            return false
        }
    }
    
    func haveChar(_ text: String) -> Bool{
        let char = CharacterSet.letters
        if text.rangeOfCharacter(from: char) != nil {
            return true
        } else {
            return false
        }
    }
}



extension String {
    subscript(_ i: Int) -> String {
        let idx1 = index(startIndex, offsetBy: i)
        let idx2 = index(idx1, offsetBy: 1)
        return String(self[idx1..<idx2])
    }

    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[start ..< end])
    }

    subscript (r: CountableClosedRange<Int>) -> String {
//        print(self)
        let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
        let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        return String(self[startIndex...endIndex])
    }
}
