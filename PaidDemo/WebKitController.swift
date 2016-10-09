//
//  WebKitController.swift
//  PaidDemo
//
//  Created by Eran Guttentag on 5/4/16.
//  Copyright © 2016 obqa. All rights reserved.
//

import UIKit
import WebKit
import OutbrainSDK

class WebKitController: UIViewController {
    let webKit = OBWKWebview()

    override func loadView() {
        view = webKit
        webKit.allowsBackForwardNavigationGestures = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
