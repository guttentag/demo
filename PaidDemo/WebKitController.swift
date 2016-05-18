//
//  WebKitController.swift
//  PaidDemo
//
//  Created by Eran Guttentag on 5/4/16.
//  Copyright © 2016 obqa. All rights reserved.
//

import UIKit
import WebKit

class WebKitController: UIViewController {
    let webKit = WKWebView()

    override func loadView() {
        view = webKit
        webKit.allowsBackForwardNavigationGestures = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}