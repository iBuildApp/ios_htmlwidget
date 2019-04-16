//
//  DataModel.swift
//  HTMLWidget
//
//  Created by Anton Boyarkin on 16/04/2019.
//

import Foundation
import XMLMapper

internal struct DataModel: Codable, XMLMappable {
    public var title: String?
    public var src: String?
    public var content: String?
    public var plugins: String?
    public var code: String?  // case for google calendar
    public var facebookUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case src = "@src"
        case content = "content"
        case plugins
        case code
        case facebookUrl = "fbook_url"
    }
    
    // XML Mapping
    public var nodeName: String! = "data"
    
    public init?(map: XMLMap) {
        self.mapping(map: map)
    }
    
    public mutating func mapping(map: XMLMap) {
        title <- map["title"]
        src <- map.attributes["content.src"]
        content <- map["content"]
        plugins <- map["plugins"]
        code <- map["code"]  // case for google calendar
        facebookUrl <- map["fbook_url"]
    }
}
