//
//  HtmlModuleRouter.swift
//  HtmlModule
//
//  Created by Anton Boyarkin on 12/04/2019.
//

import Foundation
import IBACore
import IBACoreUI

public enum HtmlModuleRoute: Route {
    case root
}

public class HtmlModuleRouter: BaseRouter<HtmlModuleRoute> {
    var module: HtmlModule?
    init(with module: HtmlModule) {
        self.module = module
    }
    
    public override func generateRootViewController() -> BaseViewControllerType {
        return HtmlViewController(type: module?.config?.type, data: module?.data)
    }
    
    public override func prepareTransition(for route: HtmlModuleRoute) -> RouteTransition {
        return RouteTransition(module: generateRootViewController(), isAnimated: true)
    }
    
    public override func rootTransition() -> RouteTransition {
        return self.prepareTransition(for: .root)
    }
}
