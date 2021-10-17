//
//  ImagesDemoViewController.swift
//  KDAnimatedImageDemo
//
//  Created by Dolphinsu on 2021/8/29.
//

import UIKit
import KDAnimatedImageFramework

class ImagesDemoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(imageView)
        self.view.addSubview(button)
        
        self.imageView.frame = self.view.bounds
        
        let videoPath = Bundle.main.path(forResource: "vp9_yuva420p", ofType: "webm", inDirectory: nil, forLocalization: nil)!
        
        // Check if the video with alpha channel
        if(!KDAnimatedImageHandler.isTransparency(path: videoPath)) {
            assertionFailure("content of \(videoPath) is not a video with alpha channel.")
            return
        }
        
        let imagesID = "demoImages"
        let handler = KDAnimatedImageHandler()
        handler.transferWebmToImages(videoPath, identifier: imagesID) { imagesPath, errorMessage in
            
            guard let imagesPath = imagesPath else {
                return
            }
            
            var images = [UIImage]()
            for path in imagesPath {
                if let image = UIImage(contentsOfFile: path) {
                    images.append(image)
                }
            }
            
            self.imageView.animationDuration = handler.mediaDuration(identifier: imagesID) ?? 0
            self.imageView.animationImages = images
            self.imageView.image = images.first
            self.imageView.startAnimating()
        }
        
    }
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFit
        return view
    }()
    
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

extension UIColor {
  static func random () -> UIColor {
    return UIColor(
      red: CGFloat.random(in: 0...1),
      green: CGFloat.random(in: 0...1),
      blue: CGFloat.random(in: 0...1),
      alpha: 1.0)
  }
}
