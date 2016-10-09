//
//  ViewController.swift
//  PaidDemo
//
//  Created by Eran Guttentag on 5/3/16.
//  Copyright © 2016 obqa. All rights reserved.
//

import UIKit
import OutbrainSDK
import SafariServices

class ViewController: UIViewController {

    @IBOutlet weak var parSwitch: UISwitch!
    @IBOutlet weak var recsTable: UITableView!
    @IBOutlet weak var staticLink: UIButton!
    @IBOutlet weak var browserSegment: UISegmentedControl!
    
    var recs: [OBRecommendation] = [OBRecommendation]()
    var refreshControll: UIRefreshControl!
    let request: OBRequest = OBRequest.init(url: "http://static-test.outbrain.com/gutte/blog/german1.html", widgetID: "SDK_2")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.refreshControll = UIRefreshControl()
        refreshControll.addTarget(self, action: #selector(ViewController.loadRecs), for: UIControlEvents.valueChanged)
        recsTable.addSubview(refreshControll)
        recsTable.dataSource = self
        recsTable.delegate = self
        
        if UIApplication.shared.canOpenURL(URL(string: "googlechrome://url.com")!) {
            browserSegment.insertSegment(withTitle: "Chrome", at: browserSegment.numberOfSegments, animated: false)
        }
        
        Outbrain.initializeOutbrain(withPartnerKey: "NANOWDGT01")
        Outbrain.setTestMode(true)
        
        staticLink.setTitle("http://static-test.outbrain.com/gutte/blog/german2.html", for: UIControlState())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func loadRecs() {
        recs.removeAll()
        recsTable.reloadData()
        Outbrain.fetchRecommendations(for: request, with: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openLink(_ sender: UIButton) {
        let url = URL(string: sender.titleLabel!.text!)
        openBrowser(url!)
    }

    func openBrowser(_ url: URL){
        var newUrl = parSwitch.isOn ? appendQueryParameter(url) : url
        if newUrl == nil {
            let alert = UIAlertController(title: "Parameter Append Error", message: "Could not append to \(url.absoluteString)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got It !", style: .cancel, handler: {
                (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)}))
            present(alert, animated: true, completion: nil)
        } else {
            switch browserSegment.selectedSegmentIndex {
            case 0:
                let vc = WebKitController()
                vc.webKit.load(URLRequest(url: newUrl!))
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                let vc = SFSafariViewController(url: newUrl!)
                present(vc, animated: true, completion: nil)
            case 3:
                newUrl = URL(string: (newUrl?.absoluteString)!.replacingOccurrences(of: "http", with: "googlechrome"))
                fallthrough
            case 2:
                UIApplication.shared.openURL(newUrl!)
            default:
                break
            }
        }
    }
    
    func appendQueryParameter(_ url: URL) -> URL?{
        var component = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let query = URLQueryItem(name: "mobileapp", value: "true")
        if component?.queryItems == nil {
            component?.queryItems = [URLQueryItem]()
        }
        component?.queryItems?.append(query)
        let newUrl = component?.url
        return newUrl
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = Outbrain.getUrl(recs[(indexPath as NSIndexPath).row])
        openBrowser(url!)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if (cell == nil) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell!.textLabel?.text = recs[(indexPath as NSIndexPath).row].content
        cell!.textLabel?.textColor = recs[(indexPath as NSIndexPath).row].isPaidLink ? UIColor.purple : UIColor.brown
        cell!.detailTextLabel?.text = recs[(indexPath as NSIndexPath).row].source
        return cell!
    }
}

extension ViewController: OBResponseDelegate {
    func outbrainDidReceiveResponse(withSuccess response: OBRecommendationResponse!) {
        print("success \(response.recommendations.count)")
        self.recs.insert(contentsOf: response.recommendations as! [OBRecommendation], at: 0)
        refreshControll.endRefreshing()
        recsTable.reloadData()
    }
    
    func outbrainResponseDidFail(_ response: Error!) {
        print("failed \(response.localizedDescription)")
        refreshControll.endRefreshing()
    }
}

