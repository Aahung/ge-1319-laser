//
//  CaptureViewController.swift
//  Laser Processor
//
//  Created by Xinhong LIU on 19/1/2016.
//  Copyright © 2016 ParseCool. All rights reserved.
//

import UIKit
import AVFoundation
import VBFPopFlatButton
import PKHUD

class CaptureViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var captureVideoPreviewLayer:AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    
    var baseImage: UIImage?
    var baseImageTookTime: NSDate?
    var baseImagePixels: [UInt8]?
    var images = [UIImage]()
    var imageTookTimes = [NSDate]()
    var imageCorrelations = [Double]()
    
    var timer: NSTimer?
    let calculationOperationQueue = NSOperationQueue()
    
    // MARK: -viewDid** and outlets
    
    @IBOutlet weak var buttomBarView: UIView!
    var controlButton: VBFPopFlatButton?
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    
    
    override func viewDidLoad() {
        configureVideoCapture()
        addVideoPreviewLayer()
        
        configureButtons()
        
        super.viewDidLoad()
        
        // one job a time, prevent race condition
        calculationOperationQueue.maxConcurrentOperationCount = 1
    }
    
    override func viewWillDisappear(animated: Bool) {
        captureSession.stopRunning()
    }
    
    override func viewDidAppear(animated: Bool) {
        captureSession.startRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - setup views
    
    func configureVideoCapture() {
        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.Back }
        if let captureDevice = devices.first as? AVCaptureDevice  {
            self.captureDevice = captureDevice
            do {
                try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
                try captureDevice.lockForConfiguration()
                captureDevice.focusMode = .ContinuousAutoFocus
                captureDevice.unlockForConfiguration()
            } catch {
                print("Error: \(error)")
                let alertController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            captureSession.sessionPreset = Preference.getPhotoResolutionAsPreset()
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
        }
    }
    
    func addVideoPreviewLayer() {
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            previewLayer.bounds = view.bounds
            previewLayer.position = CGPointMake(view.bounds.midX, view.bounds.midY)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            let cameraPreview = UIView(frame: CGRectMake(0.0, 0.0, view.bounds.size.width, view.bounds.size.height))
            cameraPreview.layer.addSublayer(previewLayer)
            view.addSubview(cameraPreview)
            view.sendSubviewToBack(cameraPreview)
        }
    }
    
    func configureButtons() {
        self.controlButton = VBFPopFlatButton(frame: CGRectMake(0, 0, 40, 40), buttonType: .buttonRightTriangleType, buttonStyle: .buttonRoundedStyle, animateToInitialState: true)
        self.controlButton?.roundBackgroundColor = UIColor.whiteColor()
        self.controlButton?.lineThickness = 3
        self.controlButton?.lineRadius = 1
        self.controlButton?.tintColor = UIColor.blackColor()
        self.controlButton?.addTarget(self, action: "startCapture", forControlEvents: .TouchUpInside)
        self.controlButton?.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [NSLayoutConstraint(item: self.controlButton!, attribute: .CenterX, relatedBy: .Equal, toItem: self.buttomBarView, attribute: .CenterX, multiplier: 1.0, constant: 0.0), NSLayoutConstraint(item: self.controlButton!, attribute: .CenterY, relatedBy: .Equal, toItem: self.buttomBarView, attribute: .CenterY, multiplier: 1.0, constant: 0.0), NSLayoutConstraint(item: self.controlButton!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40), NSLayoutConstraint(item: self.controlButton!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40)]
        
        self.buttomBarView.addSubview(self.controlButton!)
        self.buttomBarView.addConstraints(constraints)
        self.buttomBarView.layoutSubviews()
    }

    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.timer?.invalidate()
        self.timer = nil
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - capture methods
    func updateStatusLabel() {
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            assert(NSThread.isMainThread())
            self.statusLabel.text = "\((self.baseImage == nil ? "0":"base")) + \(self.imageCorrelations.count)/\(self.images.count)"
        })
    }
    
    func capture(isBaseImage: Bool) {
        
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            if !isBaseImage {
                self.controlButton?.animateToType(.buttonDownTriangleType)
            }
        })
        
        assert(NSThread.isMainThread())
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                if error != nil {
                    print("Photo taking error: \(error)")
                    return
                }
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                
                // save image to memory
                let image = UIImage(data: imageData)!
                if isBaseImage {
                    self.baseImage = image
                    self.baseImageTookTime = NSDate()
                } else {
                    self.images.append(image)
                    self.imageTookTimes.append(NSDate())
                }
                
                // change button state and label text
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    if !isBaseImage {
                        self.controlButton?.animateToType(.buttonPausedType)
                    }
                    self.updateStatusLabel()
                })
                
                self.calculationOperationQueue.addOperationWithBlock({ () -> Void in
                    if isBaseImage {
                        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage))
                        let imagePixels = CFDataGetBytePtr(pixelData)
                        let baseImageRow = Int(image.size.width)
                        let baseImageCol = Int(image.size.height)
                        self.baseImagePixels = [UInt8](count: baseImageRow * baseImageCol, repeatedValue: 0)
                        for i in 0...(baseImageRow - 1) {
                            for j in 0...(baseImageCol - 1) {
                                let index = j * baseImageRow + i
                                self.baseImagePixels![index] = imagePixels[index * 4]
                            }
                        }
                    } else {
                        let correlation = self.crossCorrelation(image)
                        print("Correlation: \(correlation)")
                        self.imageCorrelations.append(correlation)
                    }
                    self.updateStatusLabel()
                })
            }
        }
    }
    
    func captureNormalImage() {
        self.capture(false)
    }
    
    func startCapture() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
            return
        }
        
        let countDownTime = Int(ceil(Double(Preference.getBaseImageDelay()) / 1000.0))
        setCountDown(countDownTime) { () -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                
                self.controlButton?.enabled = false
                self.controlButton?.animateToType(.buttonOkType)
                do {
                    try self.captureDevice?.lockForConfiguration()
                    self.captureDevice?.focusMode = .Locked
                    self.captureDevice?.unlockForConfiguration()
                } catch {
                    print("Error: \(error)")
                }
                
                if self.baseImage == nil {
                    self.capture(true)
                }
                self.timer = NSTimer.scheduledTimerWithTimeInterval(Preference.getShootingIntervalAsSeconds(), target: self, selector: "captureNormalImage", userInfo: nil, repeats: true)
                self.controlButton?.enabled = true
                self.controlButton?.animateToType(.buttonPausedType)
                assert(NSThread.isMainThread())
            })
        }
    }

    @IBAction func finishCapture(sender: AnyObject) {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
        if self.images.count != self.imageCorrelations.count {
            let alertController = UIAlertController(title: "Busy", message: "Please wait until processing finishes.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            assert(NSThread.isMainThread())
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        let alertController = UIAlertController(title: "Save Data Set", message: "Data Set Name: ", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            textField.text = "Untitled Data Set \(dateFormatter.stringFromDate(NSDate()))"
            textField.clearButtonMode = .WhileEditing
        }
        alertController.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Saving...")
                PKHUD.sharedHUD.show()
            })
            self.calculationOperationQueue.addOperationWithBlock({ () -> Void in
                DataSetManager().saveDataSet(alertController.textFields![0].text!, baseImage: self.baseImage!, baseImageCreatedTime: self.baseImageTookTime!, images: self.images, imageCorrelations: self.imageCorrelations, imageCreatedTimes: self.imageTookTimes)
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    PKHUD.sharedHUD.hide()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    assert(NSThread.isMainThread())
                })
            })
        }))
        assert(NSThread.isMainThread())
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - calculation method
    func crossCorrelation(image: UIImage) -> Double {
        assert(self.baseImagePixels != nil)
        
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage))
        let imagePixels = CFDataGetBytePtr(pixelData)
        
        let baseImageRow = Int((self.baseImage?.size.width)!)
        let baseImageCol = Int((self.baseImage?.size.height)!)
        let imageRow = Int(image.size.width)
        let imageCol = Int(image.size.height)
        
        assert(baseImageRow == imageRow)
        assert(baseImageCol == imageCol)
        
        // 2d inner product
        // algorithm modified from http://stackoverflow.com/a/6801185/2361752
        var dotProduct: UInt64 = 0
        var baseDotProduct: UInt64 = 0
        var imageDotProduct: UInt64 = 0
        for i in 0...(baseImageRow - 1) {
            for j in 0...(baseImageCol - 1) {
                let index = baseImageRow * j + i
                let index4 = index * 4
                dotProduct += UInt64(self.baseImagePixels![index]) * UInt64(imagePixels[index4])
                baseDotProduct += UInt64(self.baseImagePixels![index]) * UInt64(self.baseImagePixels![index])
                imageDotProduct += UInt64(imagePixels[index4]) * UInt64(imagePixels[index4])
            }
        }
        
        return Double(dotProduct) * Double(dotProduct) / Double(baseDotProduct) / Double(imageDotProduct)
    }
    
    // MARK: - count down
    var countDownTime: Int!
    var countDownHandler: (()->Void)!
    var countDownTimer: NSTimer?
    
    func setCountDown(second: Int, handler: (()->Void)) {
        countDownTime = second
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.countDownLabel.text = "\(self.countDownTime)"
            self.countDownLabel.hidden = false
        }
        countDownHandler = handler
        
        // remove previous count timer if exists
        if countDownTimer != nil {
            countDownTimer?.invalidate()
            countDownTimer = nil
        }
        countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "countDown", userInfo: nil, repeats: false)
    }
    
    func countDown() {
        if countDownTime == 0 {
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                self.countDownLabel.hidden = true
            }
        }
        countDownTime = countDownTime - 1
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.countDownLabel.text = "\(self.countDownTime)"
        }
        if countDownTime == 0 {
            countDownHandler()
        }
        countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "countDown", userInfo: nil, repeats: false)
    }
}
