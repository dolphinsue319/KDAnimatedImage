//
//  KDVideoGenerator.swift
//
//  Created by Dolphinsu on 2021/9/25.
//

import Foundation
import AVFoundation
import UIKit
import CoreGraphics
import VideoToolbox

@available(iOS 13.0, *)
@objcMembers public class KDVideoGenerator: NSObject {
    
    private let pixelFormatType:OSType = kCVPixelFormatType_32BGRA
    let mediaDataRequestQueue = DispatchQueue(label: #function)
    
    /// You give me image paths, I create video file for you.
    /// - Parameters:
    ///   - fileName: The output video file name.
    ///   - imagePaths: Source image paths.
    ///   - duration: The output video duration. This must less or equal to imagePaths.count.
    ///   - completion: videoPath not be nil if video created, or I will give you the error message.
    public func write(to fileName: String, source imagePaths:[String], duration: TimeInterval, completion: @escaping (_ videoURL: URL?, _ errorMessage: String?)->()) {
        guard let url = imagePaths.first else {
            completion(nil, "imagePaths should not be empty")
            return
        }
        guard let image = UIImage(contentsOfFile: url) else {
            completion(nil, "content of imagePaths.first should be image data")
            return
        }
        guard var movieURL = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).last else {
            completion(nil, "movieURL creation failed")
            return
        }
        let outputPath = fileName.hasSuffix(".mov") ? fileName : "\(fileName).mov"
        movieURL.appendPathComponent("KDAnimatedImage/\(outputPath)")
        print("video output url: \(movieURL)")
        
        try? FileManager.default.removeItem(at: movieURL)
        
        guard let assetWriter = try? AVAssetWriter( outputURL: movieURL, fileType: AVFileType.mov) else {
            completion(nil, "AVAssetWriter creation failed")
            return
        }
        
        assetWriter.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        let outputSettings = [
            AVVideoCodecKey: AVVideoCodecType.hevcWithAlpha,
            AVVideoWidthKey: image.size.width,
            AVVideoHeightKey: image.size.height,
            AVVideoCompressionPropertiesKey:
                [kVTCompressionPropertyKey_TargetQualityForAlpha: 1]
            ] as [String: Any]
        let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
        videoWriterInput.expectsMediaDataInRealTime = false
        
        let pixelBufferAttributes = [
            kCVPixelBufferPixelFormatTypeKey: pixelFormatType,
            kCVPixelBufferWidthKey: image.size.width,
            kCVPixelBufferHeightKey: image.size.height] as [String: Any]
        
        let videoAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoWriterInput,
            sourcePixelBufferAttributes: pixelBufferAttributes)
        
        if (!assetWriter.canAdd(videoWriterInput)) {
            let message = "assetWriter can not add videoWriterInput"
            assertionFailure(message)
            completion(nil, message)
            return
        }
        assetWriter.add(videoWriterInput)
        
        if !assetWriter.startWriting() {
            let message = "assetWriter can not startWriting, assetWriter.status: \(assetWriter.status.rawValue), assetWriter.error: \(assetWriter.error?.localizedDescription ?? "")"
            assertionFailure(message)
            completion(nil, message)
            return
        }
        assetWriter.startSession(atSourceTime: .zero)
        var pathIndex = 0
        let timescale = max(Int32(TimeInterval(imagePaths.count) / duration), 1)
        let frameTime = CMTimeMake(value: 1, timescale: timescale)
        var time: CMTime = CMTime.zero
        
        // Start Writing
        print("Transfer images to video start at: \(Date())")
        
        videoWriterInput.requestMediaDataWhenReady(on: mediaDataRequestQueue) {
            
            while true {
                
                if (pathIndex >= imagePaths.count) {
                    break
                }
                
                if (!videoWriterInput.isReadyForMoreMediaData) {
                    continue
                }
                
                if (pathIndex > 0) {
                    let value = pathIndex - 1
                    let lastTime = CMTimeMake(value: Int64(value), timescale: frameTime.timescale)
                    time = CMTimeAdd(lastTime, frameTime)
                }
                let dataURL = URL(fileURLWithPath: imagePaths[pathIndex])
                guard let data = try? Data(contentsOf: dataURL) else {
                    pathIndex += 1
                    continue
                }
                let image = UIImage(data: data)
                if (image == nil) {
                    pathIndex += 1
                    continue
                }
                if let pixelBuffer = self.newPixelBufferFrom(image: image!) {
                    videoAdaptor.append(pixelBuffer, withPresentationTime: time)
                }
                pathIndex += 1
            }
            
            assetWriter.inputs.forEach { $0.markAsFinished() }
            
            assetWriter.finishWriting {
                print("Tranfer images to video ended: \(Date())")
                completion(movieURL, nil)
            }
        }
    }
    
    private func newPixelBufferFrom(image: UIImage) -> CVPixelBuffer? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), pixelFormatType, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        guard let pixelBuffer = pixelBuffer else {
            return nil
        }
        

        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let bitmapInfo = KDCGImageHelper.bitmapInfo(pixelFormatType: pixelFormatType, hasAlpha: KDCGImageHelper.isImageContainsAlpha(imageRef: cgImage)) else {
            return nil
        }
        guard let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let writer = object as? AVAssetWriter else {
            return
        }
        if let error = writer.error as NSError? {
            print(error.description)
//            assertionFailure(error.description)
        }
    }
}

