//
//  BaseWebViewController.swift
//  Gank
//
//  Created by AHuaner on 2016/12/20.
//  Copyright © 2016年 CoderAhuan. All rights reserved.
//

import UIKit
import WebKit

class BaseWebViewController: BaseViewController {
    
    var urlString: String?
    
    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: kScreen_W, height: kScreen_H))
        webView.isMultipleTouchEnabled = true
        webView.autoresizesSubviews = true
        webView.scrollView.alwaysBounceVertical = true
        return webView
    }()
    
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColorTextBlue
        progressView.trackTintColor = UIColor.white
        progressView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreen_W, height: 2)
        progressView.alpha = 0.0
        return progressView
    }()
    
    fileprivate lazy var loadingView: AHLoadingView = {
        let loadingView = AHLoadingView(frame: CGRect(x: 0, y: 0, width: kScreen_W, height: kScreen_H))
        return loadingView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        loadWithURLString(urlString)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.navigationDelegate = nil
    }
    
    fileprivate func setupUI() {
        view.addSubview(webView)
        view.addSubview(loadingView)
        view.addSubview(progressView)
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.navigationDelegate = self
        popClosure = { [unowned self] in
            self.didBackButtonClick()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.alpha = 1.0
            let animated = CGFloat(webView.estimatedProgress) > CGFloat(self.progressView.progress)
            progressView.setProgress(Float(webView.estimatedProgress), animated: animated)
            
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.5, animations: { 
                    self.progressView.alpha = 0.0
                }, completion: { (_) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func loadWithURLString(_ urlString: String?) {
        guard let urlString = urlString else { return }
        guard let url = URL(string: urlString) else { return }
        
        self.webView.load(URLRequest(url: url))
    }
    
    func didBackButtonClick() {
        if self.webView.canGoBack {
            self.webView.goBack()
            setupLeftBarButtonItems(shouldShow: true)
        } else {
            webViewPop()
            setupLeftBarButtonItems(shouldShow: false)
        }
    }
    
    func setupLeftBarButtonItems(shouldShow: Bool) {
        if shouldShow {
            let backImage = UIImage(named: "nav_back")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            let backBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
            backBtn.setImage(backImage, for: .normal)
            backBtn.addTarget(self, action: #selector(didBackButtonClick), for: .touchUpInside)
            let backItem = UIBarButtonItem(customView: backBtn)
            
            let spaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
            spaceItem.width = 25
            
            let closeImage = UIImage(named: "icon_close_second")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            let closeBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
            closeBtn.setImage(closeImage, for: .normal)
            closeBtn.addTarget(self, action: #selector(webViewPop), for: .touchUpInside)
            let closeItem = UIBarButtonItem(customView: closeBtn)
            
            navigationItem.leftBarButtonItems = [backItem, spaceItem, closeItem]
        }
    }
    
    func webViewPop() {
        guard let navigationController = self.navigationController else { return }
        navigationController.popViewController(animated: true)
    }
}

extension BaseWebViewController: WKNavigationDelegate {
    /// 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.title = "详细内容"
    }
    
    /// 开始获取到网页内容时返回
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        loadingView.isHidden = true
    }
}

