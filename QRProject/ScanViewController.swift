//
//  ScanViewController.swift
//  QRProject
//
//  Created by Buka Cakrawala on 11/5/16.
//  Copyright © 2016 Buka Cakrawala. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //Message Label, where it stores the message of the QR code
    @IBOutlet weak var messageLabel: UILabel!
    
    //Create a property to coordinate the flow data from AV input to output, and to perform a real time capture
    var captureSession: AVCaptureSession?
    
    //Create a property to record a video, in order to implement video capture
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    //Create a property of a qr code reader
    var qrCodeView: UIView?
    
    override func viewDidLoad() {
        //Grab a device type video from a specific hardware of the phone, in this case we are going to use camera
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            //Get an instance of the device input
            let input = try AVCaptureDeviceInput(device: captureDevice)
            //initialize the capture session property
            captureSession = AVCaptureSession()
            //insert the input into capture session
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            //Set the delegate as self, and use the default dispatch queue for the callbacks
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            view.bringSubview(toFront: messageLabel)

            
            captureSession?.startRunning()
            
            //Initialize QR Code Frame to highlight the QR code.
            qrCodeView = UIView()
            
            qrCodeView?.layer.borderColor = UIColor.green.cgColor
            qrCodeView?.layer.borderWidth = 2
            view.addSubview(qrCodeView!)
            view.bringSubview(toFront: qrCodeView!)
            
            
            
            
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    
    //This function is the delegate method to decode the information in the QR code
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        //Check if the metadata array is empty
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected!"
            return
        }
        
        //Get the metadata object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            //if the found metadata == with the qr code metadata, then update the string in messageLabel.
            let barcodeObj = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeView?.frame =  barcodeObj!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
            }
            
        }
        
    }
    
}
