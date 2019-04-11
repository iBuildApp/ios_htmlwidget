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

public class HtmlModule: BaseModule, ModuleType {
    public override class func canHandle(config: WidgetModel) -> Bool {
        if config.type == "html" {
            return true
        }
        return false
    }
    
    public required init() {
        print("\(type(of: self)).\(#function)")
    }
}
