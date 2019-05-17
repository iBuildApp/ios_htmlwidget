//
//  HtmlViewController.swift
//  HtmlModule
//
//  Created by Anton Boyarkin on 16/04/2019.
//

import Foundation
import IBACore
import IBACoreUI
import WebKit
import XMLMapper

class HtmlViewController: BaseViewController {
    // MARK: - Private properties
    /// Widget type indentifier
    private var type: String?
    
    /// Widger config data
    private var data: DataModel?
    
    // WebView
    private var webView: WKWebView!
    
    /// Progress view reflecting the current loading progress of the web view.
    private let progressView = UIProgressView(progressViewStyle: .default)
    
    /// The observation object for the progress of the web view (we only receive notifications until it is deallocated).
    private var estimatedProgressObserver: NSKeyValueObservation?
    
    /// Activity indicator showing loading status
    private var activityIndicator: UIActivityIndicatorView?
    
    /// Back button for Webview nafigation
    private var backButton: UIBarButtonItem?
    /// Forward button for Webview nafigation
    private var forwardButton: UIBarButtonItem?
    
    /// Show web navigetion toolbar on second link redirect
    private var showToolbarOnNextPage = true
    
    // MARK: - Controller life cycle methods
    public convenience init(type: String?, data: DataModel?) {
        self.init()
        self.type = type
        self.data = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let title = self.data?.title {
            self.title = title
        }
        
        if let plugins = self.data?.plugins {
            let wrapper = "<plugins>\(plugins)</plugins>"
            let scripts = XMLMapper<ScriptsWrapperModel>().map(XMLString: wrapper)
            self.createWebView(with: scripts?.scripts)
        } else {
            self.createWebView(with: nil)
        }
        
        self.setupTootbar()
        self.createActivityIndicator()
        self.setupProgressView()
        self.setupEstimatedProgressObserver()
        self.showContent()
    }
    
    // MARK: - Private methods
    // MARK: - UI creation methods
    private func createWebView(with scripts: [ScriptModel]?) {
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
        
        // fix for google form: don't change webview settings when user clicks on links
        if type == "googleform" {
            self.showToolbarOnNextPage = false
        }
    }
    
    private func setupTootbar() {
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: webView, action: #selector(webView.goBack))
        let forwardButton = UIBarButtonItem(title: "Forward", style: .plain, target: webView, action: #selector(webView.goForward))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [backButton, flexibleSpace, refresh, flexibleSpace, forwardButton]
        
        self.backButton = backButton
        self.forwardButton = forwardButton
        
        self.backButton?.isEnabled = webView.canGoBack
        self.forwardButton?.isEnabled = webView.canGoForward
        
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    private func createActivityIndicator() {
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
    }
    
    private func showContent() {
        if let content = self.data?.content {
            //Show content
            var baseUrl: URL?
            if content.contains("www.powr.io/powr.js") {
                baseUrl = URL(string: "http://www.powr.io")
            }
            webView.loadHTMLString(content, baseURL: baseUrl)
        } else if let src = self.data?.src, let url = URL(string: src) {
            // Show from url
            self.activityIndicator?.startAnimating()
            
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        } else if let code = self.data?.code {
            switch self.type {
            case "googleform", "calendar":
                let processed = code.replacingOccurrences(of: "&", with: "&amp;")
                
                let iframe = XMLMapper<IframeModel>().map(XMLString: processed)
                if let src = iframe?.src, let url = URL(string: src) {
                    self.activityIndicator?.startAnimating()
                    
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
    
    private func setupProgressView() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        self.navigationController?.navigationBar.addSubview(progressView)
        
        progressView.isHidden = true
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor),
            
            progressView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2.0)
            ])
    }
    
    private func setupEstimatedProgressObserver() {
        estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            self?.progressView.progress = Float(webView.estimatedProgress)
        }
    }
}

// MARK: - WKNavigationDelegate
extension HtmlViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if progressView.isHidden {
            // Make sure our animation is visible.
            progressView.isHidden = false
        }
        
        UIView.animate(withDuration: 0.33,
                       animations: {
                        self.progressView.alpha = 1.0
        })
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator?.stopAnimating()
        UIView.animate(withDuration: 0.33,
                       animations: {
                        self.progressView.alpha = 0.0
        },
                       completion: { isFinished in
                        // Update `isHidden` flag accordingly:
                        //  - set to `true` in case animation was completly finished.
                        //  - set to `false` in case animation was interrupted, e.g. due to starting of another animation.
                        self.progressView.isHidden = isFinished
        })
        
        // If you have back and forward buttons, then here is the best time to enable it
        backButton?.isEnabled = webView.canGoBack
        forwardButton?.isEnabled = webView.canGoForward
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(String(describing: decisionHandler))")
        
        switch navigationAction.navigationType {
        case .backForward:
            self.progressView.isHidden = true
            self.backButton?.isEnabled = webView.canGoBack
            self.forwardButton?.isEnabled = webView.canGoForward
        case .linkActivated:
            if let url = navigationAction.request.url {
                switch url.scheme {
                case "mailto":
                    let email = url.absoluteString.replacingOccurrences(of: "mailto:", with: "")
                    
                    var subject = ""
                    let showLink = AppManager.manager.appModel()?.design?.isShowLink ?? false
                    if showLink {
                        subject = Localization.Email.Message.sentFrom
                    }
                    
                    if email.isValidEmail() {
                        AppCoreServices.showMailComposer(with: [email], subject: subject, body: "", attachment: nil, for: self)
                    }
                    
                    decisionHandler(.cancel)
                    return
                case "tel":
                    AppCoreServices.callNumber(by: url)
                    decisionHandler(.cancel)
                    return
                case "http", "https", "file":
                    break
                default:
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    decisionHandler(.cancel)
                    return
                }
            }
            
            if navigationAction.targetFrame == nil {
                self.webView?.load(navigationAction.request)
            }
            
            self.navigationController?.setToolbarHidden(!self.showToolbarOnNextPage, animated: true)
        case .formSubmitted:
            if let url = navigationAction.request.url, url.host == "www.paypal.com" {
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

import MessageUI

extension HtmlViewController: MFMailComposeViewControllerDelegate { }
