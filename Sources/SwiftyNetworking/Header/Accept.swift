//
//  Accept.swift
//  
//
//  Created by Zaid Rahhawi on 2/25/23.
//

import Foundation

public struct Accept: HeaderKey {
    public static let field: String = "Accept"
    public static let defaultValue: MIMEType = .json
}

public enum MIMEType : String, HeaderValue {
    case json = "application/json"
    case xml = "application/xml"
    case urlencoded = "application/x-www-form-urlencoded"
    case text = "text/plain"
    case html = "text/html"
    case css = "text/css"
    case javascript = "text/javascript"
    case gif = "image/gif"
    case png = "image/png"
    case jpeg = "image/jpeg"
    case bmp = "image/bmp"
    case webp = "image/webp"
    case midi = "audio/midi"
    case mpeg = "audio/mpeg"
    case wav = "audio/wav"
    case pdf = "application/pdf"
    
    public var value: String {
        rawValue
    }
}
public extension HeaderValues {
    var accept: Accept.Type {
        Accept.self
    }
}
