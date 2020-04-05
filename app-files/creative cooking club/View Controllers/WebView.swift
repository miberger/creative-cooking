//  creative Cooking Club
//

import UIKit
import WebKit

class WebViewController2: UIViewController , WKNavigationDelegate{

var webView : WKWebView!

override func viewDidLoad() {
    super.viewDidLoad()
    
    // loading URL :
    let ccclub = "http://ischool.berkeley.edu/home/eddie.zhu/public_html/index.html"
    let url = NSURL(string: ccclub)
    let request = NSURLRequest(url: url! as URL)
    
    // init and load request in webview.
    webView = WKWebView(frame: self.view.frame)
    webView.navigationDelegate = self
    webView.load(request as URLRequest)
    self.view.addSubview(webView)
    self.view.sendSubviewToBack(webView)
}

override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}

//MARK:- WKNavigationDelegate

func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation:
WKNavigation!, withError error: Error) {
    print(error.localizedDescription)
}
func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation:
WKNavigation!) {
    print("Strat to load")
}
func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    print("finish to load")
}

}
