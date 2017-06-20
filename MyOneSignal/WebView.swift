//
//  WebView.swift
//  MyOneSignal
//
//  Created by Lai Zih Ci on 2017/6/16.
//  Copyright © 2017年 ZihCi. All rights reserved.
//

import UIKit

class WebView: UIViewController {
    
    var receivedURL: String?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if receivedURL != nil {
            loadURL(url: receivedURL!)
        }
    }
    
    func loadURL(url: Any) {
        
        guard let URL = URL(string: url as! String)
            
            else { return }
        
        webView.loadRequest(URLRequest(url: URL))
    }
}
