// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let kDMediaInfoModel = try? newJSONDecoder().decode(KDMediaInfoModel.self, from: jsonData)

import Foundation

// MARK: - KDMediaInfoModel
@objcMembers public class KDMediaInfoModel: NSObject, Codable {
    let format: Format?
    let streams: [Stream]?

    init(format: Format?, streams: [Stream]?) {
        self.format = format
        self.streams = streams
    }
}

// MARK: - Format
@objcMembers class Format: NSObject, Codable {
    let probeScore, nbStreams, nbPrograms: Int?
    let formatName, startTime, filename, duration: String?
    let size, bitRate: String?
    let tags: FormatTags?

    enum CodingKeys: String, CodingKey {
        case probeScore = "probe_score"
        case nbStreams = "nb_streams"
        case nbPrograms = "nb_programs"
        case formatName = "format_name"
        case startTime = "start_time"
        case filename, duration, size
        case bitRate = "bit_rate"
        case tags
    }

    init(probeScore: Int?, nbStreams: Int?, nbPrograms: Int?, formatName: String?, startTime: String?, filename: String?, duration: String?, size: String?, bitRate: String?, tags: FormatTags?) {
        self.probeScore = probeScore
        self.nbStreams = nbStreams
        self.nbPrograms = nbPrograms
        self.formatName = formatName
        self.startTime = startTime
        self.filename = filename
        self.duration = duration
        self.size = size
        self.bitRate = bitRate
        self.tags = tags
    }
}

// MARK: - FormatTags
@objcMembers class FormatTags: NSObject, Codable {
    let encoder: String?

    enum CodingKeys: String, CodingKey {
        case encoder = "ENCODER"
    }

    init(encoder: String?) {
        self.encoder = encoder
    }
}

// MARK: - Stream
@objcMembers class Stream: NSObject, Codable {
    let codecType, codecTimeBase: String?
    let disposition: [String: Int]?
    let profile: String?
    let tags: StreamTags?
    let codedWidth, index: Int?
    let sampleAspectRatio, colorRange, fieldOrder, codecTagString: String?
    let codecTag: String?
    let closedCaptions, startPts: Int?
    let avgFrameRate: String?
    let hasBFrames: Int?
    let codecLongName: String?
    let codedHeight: Int?
    let displayAspectRatio: String?
    let level, refs: Int?
    let pixFmt, timeBase: String?
    let height, width: Int?
    let startTime, rFrameRate, codecName: String?

    enum CodingKeys: String, CodingKey {
        case codecType = "codec_type"
        case codecTimeBase = "codec_time_base"
        case disposition, profile, tags
        case codedWidth = "coded_width"
        case index
        case sampleAspectRatio = "sample_aspect_ratio"
        case colorRange = "color_range"
        case fieldOrder = "field_order"
        case codecTagString = "codec_tag_string"
        case codecTag = "codec_tag"
        case closedCaptions = "closed_captions"
        case startPts = "start_pts"
        case avgFrameRate = "avg_frame_rate"
        case hasBFrames = "has_b_frames"
        case codecLongName = "codec_long_name"
        case codedHeight = "coded_height"
        case displayAspectRatio = "display_aspect_ratio"
        case level, refs
        case pixFmt = "pix_fmt"
        case timeBase = "time_base"
        case height, width
        case startTime = "start_time"
        case rFrameRate = "r_frame_rate"
        case codecName = "codec_name"
    }

    init(codecType: String?, codecTimeBase: String?, disposition: [String: Int]?, profile: String?, tags: StreamTags?, codedWidth: Int?, index: Int?, sampleAspectRatio: String?, colorRange: String?, fieldOrder: String?, codecTagString: String?, codecTag: String?, closedCaptions: Int?, startPts: Int?, avgFrameRate: String?, hasBFrames: Int?, codecLongName: String?, codedHeight: Int?, displayAspectRatio: String?, level: Int?, refs: Int?, pixFmt: String?, timeBase: String?, height: Int?, width: Int?, startTime: String?, rFrameRate: String?, codecName: String?) {
        self.codecType = codecType
        self.codecTimeBase = codecTimeBase
        self.disposition = disposition
        self.profile = profile
        self.tags = tags
        self.codedWidth = codedWidth
        self.index = index
        self.sampleAspectRatio = sampleAspectRatio
        self.colorRange = colorRange
        self.fieldOrder = fieldOrder
        self.codecTagString = codecTagString
        self.codecTag = codecTag
        self.closedCaptions = closedCaptions
        self.startPts = startPts
        self.avgFrameRate = avgFrameRate
        self.hasBFrames = hasBFrames
        self.codecLongName = codecLongName
        self.codedHeight = codedHeight
        self.displayAspectRatio = displayAspectRatio
        self.level = level
        self.refs = refs
        self.pixFmt = pixFmt
        self.timeBase = timeBase
        self.height = height
        self.width = width
        self.startTime = startTime
        self.rFrameRate = rFrameRate
        self.codecName = codecName
    }
}

// MARK: - StreamTags
@objcMembers class StreamTags: NSObject, Codable {
    let encoder, alphaMode, duration: String?
    var isAlpha: Bool {
        get {
            alphaMode == "1"
        }
    }

    enum CodingKeys: String, CodingKey {
        case encoder = "ENCODER"
        case alphaMode = "alpha_mode"
        case duration = "DURATION"
    }

    init(encoder: String?, alphaMode: String?, duration: String?) {
        self.encoder = encoder
        self.alphaMode = alphaMode
        self.duration = duration
    }
}
