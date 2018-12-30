//
//  VisionViewController.swift
//  My_Accounting_Book
//
//  Created by Chi Zhang on 2018/12/22.
//  Copyright © 2018年 Team_927. All rights reserved.
//

import Photos
import UIKit
import Vision
import TesseractOCR

class VisionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, G8TesseractDelegate {
    // *** Change ***
    var myImg: UIImage = UIImage(named: "IMG_0405.jpg")!
    
    // Switches to toggle types of Vision requests ON/OFF
    @IBOutlet weak var rectSwitch: UISwitch!
    @IBOutlet weak var faceSwitch: UISwitch!
    @IBOutlet weak var textSwitch: UISwitch!
    @IBOutlet weak var barcodeSwitch: UISwitch!
    
    @IBOutlet weak var imageView: UIImageView!
    
    // Layer into which to draw bounding box paths.
    var pathLayer: CALayer?
    
    // Image parameters for reuse throughout app
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
    
    // Background is black, so display status bar in white.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tapping the image view brings up the photo picker.
        let photoTap = UITapGestureRecognizer(target: self, action: #selector(promptPhoto))
        self.view.addGestureRecognizer(photoTap)
        
        // Prompt user for a photo shortly after launch
        perform(#selector(promptPhoto), with: nil, afterDelay: 0.1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if imageView.image == nil {
            promptPhoto()
        }
    }
    
    @objc
    func promptPhoto() {
        
        let prompt = UIAlertController(title: "Choose a Photo",
                                       message: "Please choose a photo.",
                                       preferredStyle: .actionSheet)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        func presentCamera(_ _: UIAlertAction) {
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true)
        }
        
        let cameraAction = UIAlertAction(title: "Camera",
                                         style: .default,
                                         handler: presentCamera)
        
        func presentLibrary(_ _: UIAlertAction) {
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library",
                                          style: .default,
                                          handler: presentLibrary)
        
        func presentAlbums(_ _: UIAlertAction) {
            imagePicker.sourceType = .savedPhotosAlbum
            self.present(imagePicker, animated: true)
        }
        
        let albumsAction = UIAlertAction(title: "Saved Albums",
                                         style: .default,
                                         handler: presentAlbums)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        prompt.addAction(cameraAction)
        prompt.addAction(libraryAction)
        prompt.addAction(albumsAction)
        prompt.addAction(cancelAction)
        
        self.present(prompt, animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    
    /// - Tag: PreprocessImage
    func scaleAndOrient(image: UIImage) -> UIImage {
        
        // Set a default value for limiting image size.
        let maxResolution: CGFloat = 640
        
        guard let cgImage = image.cgImage else {
            print("UIImage has no CGImage backing it!")
            return image
        }
        
        // Compute parameters for transform.
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        var transform = CGAffineTransform.identity
        
        var bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        if width > maxResolution ||
            height > maxResolution {
            let ratio = width / height
            if width > height {
                bounds.size.width = maxResolution
                bounds.size.height = round(maxResolution / ratio)
            } else {
                bounds.size.width = round(maxResolution * ratio)
                bounds.size.height = maxResolution
            }
        }
        
        let scaleRatio = bounds.size.width / width
        let orientation = image.imageOrientation
        switch orientation {
        case .up:
            transform = .identity
        case .down:
            transform = CGAffineTransform(translationX: width, y: height).rotated(by: .pi)
        case .left:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: 0, y: width).rotated(by: 3.0 * .pi / 2.0)
        case .right:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: height, y: 0).rotated(by: .pi / 2.0)
        case .upMirrored:
            transform = CGAffineTransform(translationX: width, y: 0).scaledBy(x: -1, y: 1)
        case .downMirrored:
            transform = CGAffineTransform(translationX: 0, y: height).scaledBy(x: 1, y: -1)
        case .leftMirrored:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: height, y: width).scaledBy(x: -1, y: 1).rotated(by: 3.0 * .pi / 2.0)
        case .rightMirrored:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(scaleX: -1, y: 1).rotated(by: .pi / 2.0)
        }
        
        return UIGraphicsImageRenderer(size: bounds.size).image { rendererContext in
            let context = rendererContext.cgContext
            
            if orientation == .right || orientation == .left {
                context.scaleBy(x: -scaleRatio, y: scaleRatio)
                context.translateBy(x: -height, y: 0)
            } else {
                context.scaleBy(x: scaleRatio, y: -scaleRatio)
                context.translateBy(x: 0, y: -height)
            }
            context.concatenate(transform)
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
    }
    
    func presentAlert(_ title: String, error: NSError) {
        // Always present alert on main thread.
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: error.localizedDescription,
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default) { _ in
                                            // Do nothing -- simply dismiss alert.
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss picker, returning to original root viewController.
        dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController,
                                        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Extract chosen image.
        let originalImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        // *** Change ***
        myImg = originalImage
        
        // Display image on screen.
        show(originalImage)
        
        // Convert from UIImageOrientation to CGImagePropertyOrientation.
        let cgOrientation = CGImagePropertyOrientation(originalImage.imageOrientation)
        
        // Fire off request based on URL of chosen photo.
        guard let cgImage = originalImage.cgImage else {
            return
        }
        performVisionRequest(image: cgImage,
                             orientation: cgOrientation)
        
        // Dismiss the picker to return to original view controller.
        dismiss(animated: true, completion: nil)
    }
    
    func show(_ image: UIImage) {
        
        // Remove previous paths & image
        pathLayer?.removeFromSuperlayer()
        pathLayer = nil
        imageView.image = nil
        
        // Account for image orientation by transforming view.
        let correctedImage = scaleAndOrient(image: image)
        
        // Place photo inside imageView.
        imageView.image = correctedImage
        
        // Transform image to fit screen.
        guard let cgImage = correctedImage.cgImage else {
            print("Trying to show an image not backed by CGImage!")
            return
        }
        
        let fullImageWidth = CGFloat(cgImage.width)
        let fullImageHeight = CGFloat(cgImage.height)
        
        let imageFrame = imageView.frame
        let widthRatio = fullImageWidth / imageFrame.width
        let heightRatio = fullImageHeight / imageFrame.height
        
        // ScaleAspectFit: The image will be scaled down according to the stricter dimension.
        let scaleDownRatio = max(widthRatio, heightRatio)
        
        // Cache image dimensions to reference when drawing CALayer paths.
        imageWidth = fullImageWidth / scaleDownRatio
        imageHeight = fullImageHeight / scaleDownRatio
        
        // Prepare pathLayer to hold Vision results.
        let xLayer = (imageFrame.width - imageWidth) / 2
        let yLayer = imageView.frame.minY + (imageFrame.height - imageHeight) / 2
        let drawingLayer = CALayer()
        drawingLayer.bounds = CGRect(x: xLayer, y: yLayer, width: imageWidth, height: imageHeight)
        drawingLayer.anchorPoint = CGPoint.zero
        drawingLayer.position = CGPoint(x: xLayer, y: yLayer)
        drawingLayer.opacity = 0.5
        pathLayer = drawingLayer
        self.view.layer.addSublayer(pathLayer!)
    }
    
    // MARK: - Vision
    
    /// - Tag: PerformRequests
    fileprivate func performVisionRequest(image: CGImage, orientation: CGImagePropertyOrientation) {
        
        // Fetch desired requests based on switch status.
        let requests = createVisionRequests()
        // Create a request handler.
        let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                        orientation: orientation,
                                                        options: [:])
        
        // Send the requests to the request handler.
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                self.presentAlert("Image Request Failed", error: error)
                return
            }
        }
    }
    
    /// - Tag: CreateRequests
    fileprivate func createVisionRequests() -> [VNRequest] {
        
        // Create an array to collect all desired requests.
        var requests: [VNRequest] = []
        
        // Create & include a request if and only if switch is ON.
        if self.rectSwitch.isOn {
            requests.append(self.rectangleDetectionRequest)
        }
        if self.faceSwitch.isOn {
            // Break rectangle & face landmark detection into 2 stages to have more fluid feedback in UI.
            requests.append(self.faceDetectionRequest)
            requests.append(self.faceLandmarkRequest)
        }
        if self.textSwitch.isOn {
            requests.append(self.textDetectionRequest)
        }
        if self.barcodeSwitch.isOn {
            requests.append(self.barcodeDetectionRequest)
        }
        
        // Return grouped requests as a single array.
        return requests
    }
    
    fileprivate func handleDetectedRectangles(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            self.presentAlert("Rectangle Detection Error", error: nsError)
            return
        }
        // Since handlers are executing on a background thread, explicitly send draw calls to the main thread.
        DispatchQueue.main.async {
            guard let drawLayer = self.pathLayer,
                let results = request?.results as? [VNRectangleObservation] else {
                    return
            }
            self.draw(rectangles: results, onImageWithBounds: drawLayer.bounds)
            drawLayer.setNeedsDisplay()
        }
    }
    
    fileprivate func handleDetectedFaces(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            self.presentAlert("Face Detection Error", error: nsError)
            return
        }
        // Perform drawing on the main thread.
        DispatchQueue.main.async {
            guard let drawLayer = self.pathLayer,
                let results = request?.results as? [VNFaceObservation] else {
                    return
            }
            self.draw(faces: results, onImageWithBounds: drawLayer.bounds)
            drawLayer.setNeedsDisplay()
        }
    }
    
    fileprivate func handleDetectedFaceLandmarks(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            self.presentAlert("Face Landmark Detection Error", error: nsError)
            return
        }
        // Perform drawing on the main thread.
        DispatchQueue.main.async {
            guard let drawLayer = self.pathLayer,
                let results = request?.results as? [VNFaceObservation] else {
                    return
            }
            self.drawFeatures(onFaces: results, onImageWithBounds: drawLayer.bounds)
            drawLayer.setNeedsDisplay()
        }
    }
    
    fileprivate func handleDetectedText(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            self.presentAlert("Text Detection Error", error: nsError)
            return
        }
        // Perform drawing on the main thread.
        DispatchQueue.main.async {
            guard let drawLayer = self.pathLayer,
                let results = request?.results as? [VNTextObservation] else {
                    return
            }
            self.draw(text: results, onImageWithBounds: drawLayer.bounds)
            drawLayer.setNeedsDisplay()
        }
    }
    
    fileprivate func handleDetectedBarcodes(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            self.presentAlert("Barcode Detection Error", error: nsError)
            return
        }
        // Perform drawing on the main thread.
        DispatchQueue.main.async {
            guard let drawLayer = self.pathLayer,
                let results = request?.results as? [VNBarcodeObservation] else {
                    return
            }
            self.draw(barcodes: results, onImageWithBounds: drawLayer.bounds)
            drawLayer.setNeedsDisplay()
        }
    }
    
    /// - Tag: ConfigureCompletionHandler
    lazy var rectangleDetectionRequest: VNDetectRectanglesRequest = {
        let rectDetectRequest = VNDetectRectanglesRequest(completionHandler: self.handleDetectedRectangles)
        // Customize & configure the request to detect only certain rectangles.
        rectDetectRequest.maximumObservations = 8 // Vision currently supports up to 16.
        rectDetectRequest.minimumConfidence = 0.6 // Be confident.
        rectDetectRequest.minimumAspectRatio = 0.3 // height / width
        return rectDetectRequest
    }()
    
    lazy var faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.handleDetectedFaces)
    lazy var faceLandmarkRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleDetectedFaceLandmarks)
    
    lazy var textDetectionRequest: VNDetectTextRectanglesRequest = {
        let textDetectRequest = VNDetectTextRectanglesRequest(completionHandler: self.handleDetectedText)
        // Tell Vision to report bounding box around each character.
        textDetectRequest.reportCharacterBoxes = true
        return textDetectRequest
    }()
    
    lazy var barcodeDetectionRequest: VNDetectBarcodesRequest = {
        let barcodeDetectRequest = VNDetectBarcodesRequest(completionHandler: self.handleDetectedBarcodes)
        // Restrict detection to most common symbologies.
        barcodeDetectRequest.symbologies = [.QR, .Aztec, .UPCE]
        return barcodeDetectRequest
    }()
    
    // MARK: - Path-Drawing
    
    fileprivate func boundingBox(forRegionOfInterest: CGRect, withinImageBounds bounds: CGRect) -> CGRect {
        
        let imageWidth = bounds.width
        let imageHeight = bounds.height
        
        // Begin with input rect.
        var rect = forRegionOfInterest
        
        // Reposition origin.
        rect.origin.x *= imageWidth
        rect.origin.x += bounds.origin.x
        rect.origin.y = (1 - rect.origin.y) * imageHeight + bounds.origin.y
        
        // Rescale normalized coordinates.
        rect.size.width *= imageWidth
        rect.size.height *= imageHeight
        
        return rect
    }
    
    fileprivate func shapeLayer(color: UIColor, frame: CGRect) -> CAShapeLayer {
        // Create a new layer.
        let layer = CAShapeLayer()
        
        // Configure layer's appearance.
        layer.fillColor = nil // No fill to show boxed object
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.borderWidth = 2
        
        // Vary the line color according to input.
        layer.borderColor = color.cgColor
        
        // Locate the layer.
        layer.anchorPoint = .zero
        layer.frame = frame
        layer.masksToBounds = true
        
        // Transform the layer to have same coordinate system as the imageView underneath it.
        layer.transform = CATransform3DMakeScale(1, -1, 1)
        
        return layer
    }
    
    // Rectangles are BLUE.
    fileprivate func draw(rectangles: [VNRectangleObservation], onImageWithBounds bounds: CGRect) {
        CATransaction.begin()
        for observation in rectangles {
            let rectBox = boundingBox(forRegionOfInterest: observation.boundingBox, withinImageBounds: bounds)
            let rectLayer = shapeLayer(color: .blue, frame: rectBox)
            
            // Add to pathLayer on top of image.
            pathLayer?.addSublayer(rectLayer)
        }
        CATransaction.commit()
    }
    
    // Faces are YELLOW.
    /// - Tag: DrawBoundingBox
    fileprivate func draw(faces: [VNFaceObservation], onImageWithBounds bounds: CGRect) {
        CATransaction.begin()
        for observation in faces {
            let faceBox = boundingBox(forRegionOfInterest: observation.boundingBox, withinImageBounds: bounds)
            let faceLayer = shapeLayer(color: .yellow, frame: faceBox)
            
            // Add to pathLayer on top of image.
            pathLayer?.addSublayer(faceLayer)
        }
        CATransaction.commit()
    }
    
    // Facial landmarks are GREEN.
    fileprivate func drawFeatures(onFaces faces: [VNFaceObservation], onImageWithBounds bounds: CGRect) {
        CATransaction.begin()
        for faceObservation in faces {
            let faceBounds = boundingBox(forRegionOfInterest: faceObservation.boundingBox, withinImageBounds: bounds)
            guard let landmarks = faceObservation.landmarks else {
                continue
            }
            
            // Iterate through landmarks detected on the current face.
            let landmarkLayer = CAShapeLayer()
            let landmarkPath = CGMutablePath()
            let affineTransform = CGAffineTransform(scaleX: faceBounds.size.width, y: faceBounds.size.height)
            
            // Treat eyebrows and lines as open-ended regions when drawing paths.
            let openLandmarkRegions: [VNFaceLandmarkRegion2D?] = [
                landmarks.leftEyebrow,
                landmarks.rightEyebrow,
                landmarks.faceContour,
                landmarks.noseCrest,
                landmarks.medianLine
            ]
            
            // Draw eyes, lips, and nose as closed regions.
            let closedLandmarkRegions = [
                landmarks.leftEye,
                landmarks.rightEye,
                landmarks.outerLips,
                landmarks.innerLips,
                landmarks.nose
                ].compactMap { $0 } // Filter out missing regions.
            
            // Draw paths for the open regions.
            for openLandmarkRegion in openLandmarkRegions where openLandmarkRegion != nil {
                landmarkPath.addPoints(in: openLandmarkRegion!,
                                       applying: affineTransform,
                                       closingWhenComplete: false)
            }
            
            // Draw paths for the closed regions.
            for closedLandmarkRegion in closedLandmarkRegions {
                landmarkPath.addPoints(in: closedLandmarkRegion,
                                       applying: affineTransform,
                                       closingWhenComplete: true)
            }
            
            // Format the path's appearance: color, thickness, shadow.
            landmarkLayer.path = landmarkPath
            landmarkLayer.lineWidth = 2
            landmarkLayer.strokeColor = UIColor.green.cgColor
            landmarkLayer.fillColor = nil
            landmarkLayer.shadowOpacity = 0.75
            landmarkLayer.shadowRadius = 4
            
            // Locate the path in the parent coordinate system.
            landmarkLayer.anchorPoint = .zero
            landmarkLayer.frame = faceBounds
            landmarkLayer.transform = CATransform3DMakeScale(1, -1, 1)
            
            // Add to pathLayer on top of image.
            pathLayer?.addSublayer(landmarkLayer)
        }
        CATransaction.commit()
    }
    
    // Lines of text are RED.  Individual characters are PURPLE.
    fileprivate func draw(text: [VNTextObservation], onImageWithBounds bounds: CGRect) {
        CATransaction.begin()
        for wordObservation in text {
            let wordBox = boundingBox(forRegionOfInterest: wordObservation.boundingBox, withinImageBounds: bounds)
            let wordLayer = shapeLayer(color: .red, frame: wordBox)
            
            // Add to pathLayer on top of image.
            pathLayer?.addSublayer(wordLayer)
            
            // Iterate through each character within the word and draw its box.
            guard let charBoxes = wordObservation.characterBoxes else {
                continue
            }
            for charObservation in charBoxes {
                let charBox = boundingBox(forRegionOfInterest: charObservation.boundingBox, withinImageBounds: bounds)
                let charLayer = shapeLayer(color: .purple, frame: charBox)
                charLayer.borderWidth = 1
                
                // Add to pathLayer on top of image.
                pathLayer?.addSublayer(charLayer)
            }
        }
        CATransaction.commit()
        print(text.count)
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.delegate = self
            for word in text {
                //tesseract.image = cropImage(img: myImg, normalisedRect: normalise(box: word))!.g8_blackAndWhite()
                let cropped = cropImage(img: myImg, normalisedRect: normalise(box: word))
                let croppedBinary = OpenCVWrapper.imageProcessing(cropped!)
                tesseract.image = croppedBinary
                tesseract.recognize()
                
                let ed = extractDate(str: tesseract.recognizedText!)
                if ed.count > 0 {
                    print("*****************\(ed[0])")
                }
                
                print(tesseract.recognizedText!)
                
            }
        }
        //croppedImg.image = cropImage(img: myImg, normalisedRect: normalise(box: text[text.count - 4]))!.g8_blackAndWhite()
    }
    
    // Barcodes are ORANGE.
    fileprivate func draw(barcodes: [VNBarcodeObservation], onImageWithBounds bounds: CGRect) {
        CATransaction.begin()
        for observation in barcodes {
            let barcodeBox = boundingBox(forRegionOfInterest: observation.boundingBox, withinImageBounds: bounds)
            let barcodeLayer = shapeLayer(color: .orange, frame: barcodeBox)
            
            // Add to pathLayer on top of image.
            pathLayer?.addSublayer(barcodeLayer)
        }
        CATransaction.commit()
    }
    
    @IBOutlet weak var croppedImg: UIImageView!
    
    private func normalise(box: VNTextObservation) -> CGRect {
        return CGRect(
            x: box.boundingBox.origin.x,
            y: 1 - box.boundingBox.origin.y - box.boundingBox.height,
            width: box.boundingBox.size.width,
            height: box.boundingBox.size.height
        )
    }
    
    private func cropImage(img: UIImage, normalisedRect: CGRect) -> UIImage? {
        let image = img.fixOrientation()
        
        let x = normalisedRect.origin.x * image.size.width
        let y = normalisedRect.origin.y * image.size.height
        let width = normalisedRect.width * image.size.width
        let height = normalisedRect.height * image.size.height
        
        let rect = CGRect(x: x, y: y, width: width, height: height).scaleUp(scaleUp: 0.08)
        
        print(rect.midX, rect.midY)
        
        guard let cropped = image.cgImage?.cropping(to: rect) else {
            return nil
        }
        
        let croppedImage = UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
        
        return croppedImage
    }
    
    // *** Info extraction ***
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    private func extractDate(str: String) -> [String] {
        // "yyyy-MM-dd"
        let regex1 = "[1-9][0-9][0-9][0-9]((\\s)*)-((\\s)*)((01)|(02)|(03)|(04)|(05)|(06)|(07)|(08)|(09)|(10)|(11)|(12))((\\s)*)-((\\s)*)[0-3][0-9]"
        // "MM-dd-yyyy"
        let regex2 = "((01)|(02)|(03)|(04)|(05)|(06)|(07)|(08)|(09)|(10)|(11)|(12))((\\s)*)-((\\s)*)[0-3][0-9]((\\s)*)-((\\s)*)[1-9][0-9][0-9][0-9]"
        // "yyyy/MM/dd"
        let regex3 = "[1-9][0-9][0-9][0-9]((\\s)*)\\/((\\s)*)((01)|(02)|(03)|(04)|(05)|(06)|(07)|(08)|(09)|(10)|(11)|(12))((\\s)*)\\/((\\s)*)[0-3][0-9]"
        // "MM/dd/yyyy"
        let regex4 = "((01)|(02)|(03)|(04)|(05)|(06)|(07)|(08)|(09)|(10)|(11)|(12))((\\s)*)\\/((\\s)*)[0-3][0-9]((\\s)*)\\/((\\s)*)[1-9][0-9][0-9][0-9]"
        
        let matched1 = matches(for: regex1, in: str)
        if matched1.count > 0 {
            return matched1
        }
        let matched2 = matches(for: regex2, in: str)
        if matched2.count > 0 {
            return matched2
        }
        let matched3 = matches(for: regex3, in: str)
        if matched3.count > 0 {
            return matched3
        }
        let matched4 = matches(for: regex4, in: str)
        if matched4.count > 0 {
            return matched4
        }
        
        return []
    }
    
    func blackAndWhite(image: UIImage, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            // get information about image
            
            let imageref = image.cgImage!
            let width = imageref.width
            let height = imageref.height
            
            // create new bitmap context
            
            let bitsPerComponent = 8
            let bytesPerPixel = 4
            let bytesPerRow = width * bytesPerPixel
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = Pixel.bitmapInfo
            let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)!
            
            // draw image to context
            
            let rect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
            context.draw(imageref, in: rect)
            
            // manipulate binary data
            
            guard let buffer = context.data else {
                print("unable to get context data")
                completion(nil)
                return
            }
            
            let pixels = buffer.bindMemory(to: Pixel.self, capacity: width * height)
            
            DispatchQueue.concurrentPerform(iterations: height) { row in
                for col in 0 ..< width {
                    let offset = Int(row * width + col)
                    
                    let red = Float(pixels[offset].red)
                    let green = Float(pixels[offset].green)
                    let blue = Float(pixels[offset].blue)
                    let alpha = pixels[offset].alpha
                    let luminance = UInt8(0.2126 * red + 0.7152 * green + 0.0722 * blue)
                    pixels[offset] = Pixel(red: luminance, green: luminance, blue: luminance, alpha: alpha)
                }
            }
            
            // return the image
            
            let outputImage = context.makeImage()!
            completion(UIImage(cgImage: outputImage, scale: image.scale, orientation: image.imageOrientation))
        }
    }
    
    struct Pixel: Equatable {
        private var rgba: UInt32
        
        var red: UInt8 {
            return UInt8((rgba >> 24) & 255)
        }
        
        var green: UInt8 {
            return UInt8((rgba >> 16) & 255)
        }
        
        var blue: UInt8 {
            return UInt8((rgba >> 8) & 255)
        }
        
        var alpha: UInt8 {
            return UInt8((rgba >> 0) & 255)
        }
        
        init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
            rgba = (UInt32(red) << 24) | (UInt32(green) << 16) | (UInt32(blue) << 8) | (UInt32(alpha) << 0)
        }
        
        static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        
        static func ==(lhs: Pixel, rhs: Pixel) -> Bool {
            return lhs.rgba == rhs.rgba
        }
    }
}

private extension CGMutablePath {
    // Helper function to add lines to a path.
    func addPoints(in landmarkRegion: VNFaceLandmarkRegion2D,
                   applying affineTransform: CGAffineTransform,
                   closingWhenComplete closePath: Bool) {
        let pointCount = landmarkRegion.pointCount
        
        // Draw line if and only if path contains multiple points.
        guard pointCount > 1 else {
            return
        }
        self.addLines(between: landmarkRegion.normalizedPoints, transform: affineTransform)
        
        if closePath {
            self.closeSubpath()
        }
    }
}
