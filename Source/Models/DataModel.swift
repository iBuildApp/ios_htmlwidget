//
//  DataModel.swift
//  HTMLWidget
//
//  Created by Anton Boyarkin on 16/04/2019.
//

import Foundation

internal struct DataModel: Codable {
    public var title: String?
    public var src: String?
    public var content: String?
    public var plugins: String?
    public var code: String?  // case for google calendar
    public var facebookUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "#title"
        case src = "@src"
        case content = "#content"
        case plugins = "#plugins"
        case code = "#code"
        case facebookUrl = "#fbook_url"
    }
    
    public init?(map: [String: Any]) {
        self.mapping(map: map)
    }
    
    public mutating func mapping(map: [String: Any]) {
        title = map[CodingKeys.title.rawValue] as? String
        if let content = map[CodingKeys.content.rawValue] as? String {
            self.content = content
        } else if let content = map["content"] as? [String: Any] {
            src = content[CodingKeys.src.rawValue] as? String
        }
        plugins = map[CodingKeys.plugins.rawValue] as? String
        code = map[CodingKeys.code.rawValue] as? String
        facebookUrl = map[CodingKeys.facebookUrl.rawValue] as? String
    }
}
