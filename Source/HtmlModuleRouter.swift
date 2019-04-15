//
//  HtmlModuleRouter.swift
//  HtmlModule
//
//  Created by Anton Boyarkin on 12/04/2019.
//

import Foundation
import AppBuilderCore
import AppBuilderCoreUI

import WebKit

public enum HtmlModuleRoute: Route {
    case root
}

public class HtmlModuleRouter: BaseRouter<HtmlModuleRoute> {
    var module: HtmlModule?
    init(with module: HtmlModule) {
        self.module = module
    }
    
    public override func prepareTransition(for route: HtmlModuleRoute) -> RouteTransition {
        return RouteTransition(module: HtmlController(data: module?.data), isRoot: false, isAnimated: true, showNavigationBar: true, showTabBar: false)
    }
    
    public override func rootTransition() -> RouteTransition {
        return self.prepareTransition(for: .root)
    }
}

class HtmlController: BaseViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    private var data: DataModel?
    
    private var activityIndicator: UIActivityIndicatorView?
    
    public convenience init(data: DataModel?) {
        self.init()
        self.data = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadView()
        
        if let title = self.data?.title {
            self.title = title
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.color = UIColor.darkGray
        self.view.addSubview(activityIndicator)
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        self.view.addConstraint(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        self.view.addConstraint(verticalConstraint)
        
        self.activityIndicator = activityIndicator
        
        if let content = self.data?.content {
            //Show content
            webView.loadHTMLString(content, baseURL: nil)
        } else if let src = self.data?.src, let url = URL(string: src) {
            // Show from url
            activityIndicator.startAnimating()
            
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        } else if let code = self.data?.code {
            
        }
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator?.stopAnimating()
    }
}
