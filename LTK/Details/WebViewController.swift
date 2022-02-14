//
//  WebViewController.swift
//  LTK
//
//  Created by Laura Artiles on 2/6/22.
//

import WebKit

class WebViewController: UIViewController, WKUIDelegate {
  private lazy var webView: WKWebView = {
    let webConfiguration = WKWebViewConfiguration()
    let webView = WKWebView(frame: .zero, configuration: webConfiguration)
    webView.uiDelegate = self
    return webView
  }()
  
  private let productUrl: URL
  
  init(productUrl: URL) {
    self.productUrl = productUrl
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
     super.viewDidLoad()
     let myRequest = URLRequest(url: productUrl)
     webView.load(myRequest)
  }
  
  override func loadView() {
     view = webView
  }
}
