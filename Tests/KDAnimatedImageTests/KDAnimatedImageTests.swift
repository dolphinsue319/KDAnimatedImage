//
//  KDAnimatedImageTests.swift
//  KDAnimatedImageTests
//
//  Created by Dolphinsu on 2021/8/28.
//

import XCTest
@testable import KDAnimatedImageFramework

class KDAnimatedImageTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testImagesGeneration() {
        let videoPath = Bundle.init(for: KDAnimatedImageTests.self).path(forResource: "vp9_yuva420p", ofType: "webm", inDirectory: nil, forLocalization: nil)!
        let exp = self.expectation(description: #function)
        KDAnimatedImageHandler().transferWebmToImages(videoPath, identifier: "imagesDemo") { imagesPath, errorMessage in
            XCTAssertNotNil(imagesPath)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
    }
    
    @available(iOS 13.0, *)
    func testVideoTransfer() {
        let videoPath = Bundle.init(for: KDAnimatedImageTests.self).path(forResource: "vp9_yuva420p", ofType: "webm", inDirectory: nil, forLocalization: nil)!
        let exp = self.expectation(description: #function)
        KDAnimatedImageHandler().transferWebmToVideo(videoPath, identifier: "demoVideo") { videoURL, errorMessage in
            XCTAssertNotNil(videoURL)
            XCTAssertNil(errorMessage)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 20)
    }

    func testMediaInfoModelGeneration() throws {
        // https://jsoneditoronline.org/#left=cloud.917a4a1e13a84c13a4d3523b5f1893d0
        let jsonString =
        """
{
  "format" : {
    "probe_score" : 100,
    "nb_streams" : 1,
    "nb_programs" : 0,
    "format_name" : "matroska,webm",
    "start_time" : "0.000000",
    "filename" : "/private/var/containers/Bundle/Application/FD60456B-43A6-4F9A-9C64-25CEC0C2ED26/KDAnimatedImageDemo.app/vp9_yuva420p.webm",
    "duration" : "10.000000",
    "size" : "16333",
    "bit_rate" : "13066",
    "tags" : {
      "ENCODER" : "Lavf58.76.100"
    }
  },
  "streams" : [
    {
      "codec_type" : "video",
      "codec_time_base" : "1/1",
      "disposition" : {
        "timed_thumbnails" : 0,
        "default" : 1,
        "original" : 0,
        "attached_pic" : 0,
        "comment" : 0,
        "forced" : 0,
        "karaoke" : 0,
        "dub" : 0,
        "visual_impaired" : 0,
        "hearing_impaired" : 0,
        "lyrics" : 0,
        "clean_effects" : 0
      },
      "profile" : "0",
      "tags" : {
        "ENCODER" : "Lavc58.134.100 libvpx-vp9",
        "alpha_mode" : "1",
        "DURATION" : "00:00:10.000000000"
      },
      "coded_width" : 480,
      "index" : 0,
      "sample_aspect_ratio" : "1:1",
      "color_range" : "tv",
      "field_order" : "progressive",
      "codec_tag_string" : "[0][0][0][0]",
      "codec_tag" : "0x0000",
      "closed_captions" : 0,
      "start_pts" : 0,
      "avg_frame_rate" : "1/1",
      "has_b_frames" : 0,
      "codec_long_name" : "unknown",
      "coded_height" : 640,
      "display_aspect_ratio" : "3:4",
      "level" : -99,
      "refs" : 1,
      "pix_fmt" : "yuv420p",
      "time_base" : "1/1000",
      "height" : 640,
      "width" : 480,
      "start_time" : "0.000000",
      "r_frame_rate" : "1/1",
      "codec_name" : "vp9"
    }
  ]
}
"""
        let jsonData = jsonString.data(using: .utf8)
        let mediaInfoModel = try! JSONDecoder().decode(KDMediaInfoModel.self, from: jsonData!)
        XCTAssertNotNil(mediaInfoModel)
        XCTAssertNotNil(mediaInfoModel.streams!.first!)
        XCTAssertTrue(mediaInfoModel.streams!.first!.tags!.isAlpha)
    }

}
