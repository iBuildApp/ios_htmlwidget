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
    
    private var router: HtmlModuleRouter!
    internal var config: WidgetModel?
    internal var data: DataModel?
    
    public override class func canHandle(config: WidgetModel) -> Bool {
        switch config.type {
        case "html", "facebook", "calendar", "googleform":
            return true
        default:
            return false
        }
    }
    
    public required init() {
        print("\(type(of: self)).\(#function)")
        super.init()
        router = HtmlModuleRouter(with: self)
    }
    
    public func setConfig(_ model: WidgetModel) {
        self.config = model
        if let data = model.data, let dataModel = DataModel(map: data) {
            self.data = dataModel
        } else {
            print("Error parsing!")
        }
    }
}
