//
//  HtmlModuleRouter.swift
//  HtmlModule
//
//  Created by Anton Boyarkin on 12/04/2019.
//

import Foundation
import AppBuilderCore
import AppBuilderCoreUI

public enum HtmlModuleRoute: Route {
    case root
}

public class HtmlModuleRouter: BaseRouter<HtmlModuleRoute> {
    public override func prepareTransition(for route: HtmlModuleRoute) -> RouteTransition {
        return RouteTransition(module: HtmlController(name: "HTML Module"), isRoot: false, isAnimated: true, showNavigationBar: true, showTabBar: false)
    }
    
    public override func rootTransition() -> RouteTransition {
        return self.prepareTransition(for: .root)
    }
}

class HtmlController: BaseViewController {
    private var name = ""
    public convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.cyan
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.text = self.name
        self.view.addSubview(label)
        
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        self.view.addConstraint(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        self.view.addConstraint(verticalConstraint)
    }
}
