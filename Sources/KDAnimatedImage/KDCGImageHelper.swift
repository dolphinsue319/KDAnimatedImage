//
//  KDCGImageHelper.swift
//  KDAnimatedImage
//
//  Created by Dolphinsu on 2021/9/25.
//

import Foundation
import CoreGraphics
import CoreVideo


class KDCGImageHelper {
    
    class func isImageContainsAlpha(imageRef: CGImage) -> Bool {
        let alphaInfo = imageRef.alphaInfo
        return !(alphaInfo == CGImageAlphaInfo.none ||
                 alphaInfo == CGImageAlphaInfo.noneSkipFirst ||
                 alphaInfo == CGImageAlphaInfo.noneSkipLast)
    }
    
    class func bitmapInfo(pixelFormatType: OSType, hasAlpha: Bool) -> UInt32? {
        
        var bitmapInfo: UInt32?
        
        switch pixelFormatType {
        case kCVPixelFormatType_32BGRA:
            bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
            if (!hasAlpha) {
                bitmapInfo = CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
            }
        case kCVPixelFormatType_32ARGB:
            bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        default:
            print("\(#function), format not supported: \(pixelFormatType)")
            break
        }
        
        return bitmapInfo
    }
    
}
