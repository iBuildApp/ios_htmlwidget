//
//  HTMLWidget.swift
//  HTMLWidget
//
//  Created by Anton Boyarkin on 11/04/2019.
//  Copyright © 2019 iBuildApp. All rights reserved.
//

import UIKit
import AppBuilderCore
import AppBuilderCoreUI

import XMLMapper

public class HtmlModule: BaseModule, ModuleType {
    public var moduleRouter: AnyRouter { return router }
    
    private var router: HtmlModuleRouter = HtmlModuleRouter()
    private var config: WidgetModel?
    
    public override class func canHandle(config: WidgetModel) -> Bool {
        if config.type == "html" {
            return true
        }
        return false
    }
    
    public required init() {
        print("\(type(of: self)).\(#function)")
    }
    
    public func setConfig(_ model: WidgetModel) {
        self.config = model
        if let data = model.data, let dataModel = DataModel(map: data) {
            print("Parsed: \(dataModel)")
        } else {
            print("Error parsing!")
        }
    }
}

struct DataModel: Codable, XMLMappable {
    public var title: String?
    public var src: String?
    public var content: String?
    public var plugins: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case src = "@src"
        case content = "content"
        case plugins
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
    }
}
