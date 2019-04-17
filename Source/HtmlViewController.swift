//
//  HtmlViewController.swift
//  HtmlModule
//
//  Created by Anton Boyarkin on 16/04/2019.
//

import Foundation
import AppBuilderCore
import AppBuilderCoreUI
import WebKit
import XMLMapper

class HtmlViewController: BaseViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    private var type: String?
    private var data: DataModel?
    
    private var activityIndicator: UIActivityIndicatorView?
    
    public convenience init(type: String?, data: DataModel?) {
        self.init()
        self.type = type
        self.data = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let plugins = self.data?.plugins {
            let wrapper = "<plugins>\(plugins)</plugins>"
            let scripts = XMLMapper<ScriptsWrapperModel>().map(XMLString: wrapper)
            self.loadView(with: scripts?.scripts)
        } else {
            self.loadView(with: nil)
        }
        
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
            switch self.type {
            case "googleform", "calendar":
                let processed = code.replacingOccurrences(of: "&", with: "&amp;")
                
                let iframe = XMLMapper<IframeModel>().map(XMLString: processed)
                if let src = iframe?.src, let url = URL(string: src) {
                    activityIndicator.startAnimating()
                    
                    webView.load(URLRequest(url: url))
                }
            default:
                let screenWidth = UIScreen.main.bounds.width
                var screenHeight = UIScreen.main.bounds.height
                var padding: UIEdgeInsets = .zero
                
                if #available(iOS 11.0, *) {
                    let window = UIApplication.shared.keyWindow
                    padding.bottom = window?.safeAreaInsets.bottom ?? 0
                    padding.top = window?.safeAreaInsets.top ?? 0
                }
                screenHeight -= padding.top + padding.bottom
                
                let processed = code.replacingOccurrences(of: "&", with: "&amp;")
                if var iframe = XMLMapper<IframeModel>().map(XMLString: processed) {
                    iframe.scrolling = "no"
                    
                    if iframe.width != nil {
                        iframe.width = "\(screenWidth)"
                    } else {
                        iframe.width = "300"
                    }
                    
                    if iframe.height != nil {
                        iframe.height = "\(screenHeight)"
                    } else {
                        iframe.height = "400"
                    }
                    
                    let content = iframe.toXMLString() ?? ""
                    
                    let htmlString = "<html><meta name=\"viewport\" content=\"width=\(screenWidth)\"/><head></head><body style=\"margin:0; padding:0\"><div>\(content)</div></body></html>"
                    
                    webView.loadHTMLString(htmlString, baseURL: nil)
                }
            }
        }
    }
    
    func loadView(with scripts: [ScriptModel]?) {
        let contentController = WKUserContentController()
        
        if let scripts = scripts {
            for script in scripts {
                if let src = script.src, let type = script.type {
                    let script = """
                    var script = document.createElement('script');
                    script.src = '\(src)';
                    script.type = '\(type)t';
                    document.getElementsByTagName('head')[0].appendChild(script);
                    """
                    let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                    
                    contentController.addUserScript(userScript)
                }
            }
        }
        
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController
        
        webView = WKWebView(frame: CGRect.zero, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        view = webView
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(String(describing: decisionHandler))")
        
        switch navigationAction.navigationType {
        case .formSubmitted:
            if let url = navigationAction.request.url, url.host == "www.paypal.com" {
                print(url.absoluteString)
                
                var link = url.absoluteString
                
                if let httpBody = navigationAction.request.httpBody, let httpBodyString = String(data: httpBody, encoding: String.Encoding.utf8) {
                    link = link.appendingFormat("?%@", httpBodyString)
                    link = link.appending("&bn=ibuildapp_SP")
                }
                
                if let remoteUrl = URL(string: link) {
                    print(remoteUrl.absoluteString)
                    UIApplication.shared.open(remoteUrl, options: [:], completionHandler: nil)
                }
                decisionHandler(.cancel)
                return
            }
        default:
            break
        }
        decisionHandler(.allow)
    }
}
