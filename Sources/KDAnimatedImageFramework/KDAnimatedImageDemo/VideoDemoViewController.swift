//
//  VideoDemoViewController.swift
//  KDAnimatedImageDemo
//
//  Created by Dolphinsu on 2021/9/26.
//

import UIKit
import AVKit
import KDAnimatedImageFramework

class VideoDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(button)

        let videoPath = Bundle.main.path(forResource: "vp9_yuva420p", ofType: "webm", inDirectory: nil, forLocalization: nil)!
        
        // Check if the video with alpha channel
        if(!KDAnimatedImageHandler.isTransparency(path: videoPath)) {
            assertionFailure("content of \(videoPath) is not a video with alpha channel.")
            return
        }
        
        KDAnimatedImageHandler().transferWebmToVideo(videoPath, identifier: "videoDemo") { videoURL, errorMessage in
            
            if let errorMessage = errorMessage {
                print(errorMessage)
                return
            }
            self.playVideo(url: videoURL!)
        }
    }
    
    func playVideo(url: URL) {
        DispatchQueue.main.async {
            let vp = AVPlayer(url: url)
            let vLayer = AVPlayerLayer(player: vp)
            vLayer.backgroundColor = UIColor.clear.cgColor
            vLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.view.layer.addSublayer(vLayer)
            vp.play()
        }
    }
    
    lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 20, y: 40, width: 100, height: 40)
        button.setTitle("Change Background Color", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(buttonMethod(_:)), for: .touchUpInside)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    @objc func buttonMethod(_ sender: UIButton) {
        
        self.view.backgroundColor = UIColor.random()
    }
}
