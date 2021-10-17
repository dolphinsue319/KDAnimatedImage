//
//  KDAnimatedImageHandler.swift
//  KDAnimatedImage
//
//  Created by Dolphinsu on 2021/8/29.
//

import Foundation
import CoreVideo
import ffmpegkit


@objcMembers public class KDAnimatedImageHandler: NSObject {
    
    @available(iOS 13.0, *)
    public func transferWebmToVideo(_ inVideoPath: String, identifier: String, completion: @escaping (_ videoURL: URL?, _ errorMessage: String?)->()) {
        
        self.transferWebmToImages(inVideoPath, identifier: identifier) { imagesPath, errorMessage in
            
            if let path = imagesPath, let duration = self.mediaDuration(identifier: identifier) {
                KDVideoGenerator().write(to: identifier, source: path, duration: duration, completion: completion)
                return
            }
            completion(nil, errorMessage)
        }
    }
    
    public func transferWebmToImages(_ videoPath: String, identifier: String, completion:@escaping (_ imagesPath: [String]?, _ errorMessage: String?)->()) {
        
        guard let mediaInfo = FFprobeKit.getMediaInformation(videoPath).getMediaInformation() else {
            completion(nil, "FFprobeKit.getMediaInformation() failed")
            return
        }
        guard let format = mediaInfo.getFormat() else {
            completion(nil, "mediaInfo.getFormat() failed")
            return
        }
        if (!format.contains("webm")) {
            completion(nil, "the video is not webm format")
            return
        }
        let mediaDuration = TimeInterval(mediaInfo.getDuration())
        print("media duration: \(mediaDuration ?? 0)")
        print("media format: \(format)")
        let allProperties = mediaInfo.getAllProperties()
        guard let streamInfo = mediaInfo.getStreams().first as? StreamInformation else {
            completion(nil, "mediaInfo has no stream")
            return
        }
        guard let outputDirURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("KDAnimatedImage/\(identifier)") else {
            completion(nil, "outpurDirURL failed")
            return
        }
        print("output path: \(outputDirURL.path)")
        do {
            if (FileManager.default.fileExists(atPath: outputDirURL.path, isDirectory: nil)) {
                try FileManager.default.removeItem(at: outputDirURL)
            }
            try FileManager.default.createDirectory(at: outputDirURL, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            let message = "directory creation failed: \(error)"
            completion(nil, message)
            return
        }
        
        let codec = streamInfo.getCodec()
        var command = "-i \(videoPath) \(outputDirURL.path)/%d.png"
        if (codec == "vp9") {
            command = "-c:v libvpx-vp9 -i \(videoPath) \(outputDirURL.path)/%d.png"
        }
        let queue = DispatchQueue(label: "KDAnimatedImageHandlerQueue")
        FFmpegKit.executeAsync(command, withExecuteCallback: { session in
            
            let returnCode = session?.getReturnCode()
            
            DispatchQueue.main.async {
                if (returnCode?.getValue() == 0) {
                    self.userDefaults?.set(mediaDuration, forKey: identifier)
                    completion(self.imagesPath(identifier: identifier), nil)
                }
                else {
                    var message = "media properties: \(allProperties ?? [:])\n"
                    message += "session?.getAllLogsAsString(): \(session?.getAllLogsAsString() ?? "")"
                    completion(nil, message)
                }
            }
            
        }, onDispatchQueue: queue)
    }
    
    public static func mediaInfo(path: String) -> KDMediaInfoModel? {
        guard let session = FFprobeKit.getMediaInformation(path) else {
            return nil
        }
        guard let dict = session.getMediaInformation().getAllProperties() else {
            return nil
        }
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else {
            return nil
        }
        var mInfo: KDMediaInfoModel?
        do {
            mInfo = try JSONDecoder().decode(KDMediaInfoModel.self, from: data)
        }
        catch {
            print("KDMediaInfoModel generation failed with error.localizedDescription: \(error.localizedDescription)")
            print(String(data: data, encoding: .utf8) ?? "")
        }
        return mInfo
    }
    
    public static func isTransparency(path: String) -> Bool {
        guard let mInfo = self.mediaInfo(path: path) else {
            return false
        }
        guard let videoStream = mInfo.streams?.first(where: { s in
            return s.codecType == "video"
        }) else {
            return false
        }
        return videoStream.tags?.isAlpha ?? false
    }
    
    public func mediaDuration(identifier: String) -> TimeInterval? {
        return userDefaults?.value(forKey: identifier) as? TimeInterval
    }
    
    public func imagesPath(identifier: String) -> [String]? {
        guard var dirURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        dirURL = dirURL.appendingPathComponent("KDAnimatedImage/\(identifier)")
        guard var paths = try? FileManager.default.contentsOfDirectory(atPath: dirURL.path) else {
            return nil
        }
        
        paths = paths.filter { path in
            return path.hasSuffix(".png")
        }
        
        paths.sort { lhs, rhs in
            guard let lhsPrefix = lhs.components(separatedBy: ".").first, let rhsPrefix = rhs.components(separatedBy: ".").first else {
                return false
            }
            return Int(lhsPrefix) ?? 0 < Int(rhsPrefix) ?? 0
        }
        
        paths = paths.map { path in
            return dirURL.appendingPathComponent(path).path
        }
        
        return paths.count > 0 ? paths : nil
    }
    
    let userDefaults = UserDefaults(suiteName: "KDAnimatedImageHandler")
}
