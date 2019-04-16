//
//  IframeModel.swift
//  HTMLWidget
//
//  Created by Anton Boyarkin on 16/04/2019.
//

import Foundation
import XMLMapper

internal struct IframeModel: Codable, XMLMappable {
    public var src: String?
    public var width: String?
    public var height: String?
    public var style: String?
    public var scrolling: String?
    public var frameborder: String?
    public var marginheight: String?
    public var marginwidth: String?
    
    // XML Mapping
    public var nodeName: String! = "iframe"
    
    public init?(map: XMLMap) {
        self.mapping(map: map)
    }
    
    public mutating func mapping(map: XMLMap) {
        src <- map.attributes["src"]
        width <- map.attributes["width"]
        height <- map.attributes["height"]
        style <- map.attributes["style"]
        scrolling <- map.attributes["scrolling"]
        frameborder <- map.attributes["frameborder"]
        marginheight <- map.attributes["marginheight"]
        marginwidth <- map.attributes["marginwidth"]
    }
}
