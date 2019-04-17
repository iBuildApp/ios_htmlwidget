//
//  ScriptModel.swift
//  HTMLWidget
//
//  Created by Anton Boyarkin on 17/04/2019.
//

import Foundation
import XMLMapper

internal struct ScriptsWrapperModel: Codable, XMLMappable {
    public var scripts: [ScriptModel]?
    
    // XML Mapping
    public var nodeName: String! = "plugins"
    
    public init?(map: XMLMap) {
        self.mapping(map: map)
    }
    
    public mutating func mapping(map: XMLMap) {
        scripts <- map["script"]
    }
}

internal struct ScriptModel: Codable, XMLMappable {
    public var src: String?
    public var type: String?
    
    // XML Mapping
    public var nodeName: String! = "script"
    
    public init?(map: XMLMap) {
        self.mapping(map: map)
    }
    
    public mutating func mapping(map: XMLMap) {
        src <- map.attributes["src"]
        type <- map.attributes["type"]
    }
}
