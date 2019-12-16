//
//  LoginDelegates.swift
//  ChatAutomationTestApp
//
//  Created by MahyarZhiani on 9/25/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import WebKit


extension LoginViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
//    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
//        print("didReceiveServerRedirectForProvisionalNavigation url = \(webView.url?.absoluteString ?? "it's nil")\n")
//    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        let redirectedUrlString = webView.url?.absoluteString
        let myArray = redirectedUrlString?.components(separatedBy: "code=")
        if let array = myArray {
            if array.count > 1 {
                code = array.last!
                getToken()
            }
        }
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("webView didFailProvisionalNavigation erro: \n\(error)")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("webView didFail error: \n\(error)")
    }
    
}
