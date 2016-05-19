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
    let request: OBRequest = OBRequest.init(URL: "http://static-test.outbrain.com/gutte/blog/german1.html", widgetID: "SDK_2")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.refreshControll = UIRefreshControl()
        refreshControll.addTarget(self, action: #selector(ViewController.loadRecs), forControlEvents: UIControlEvents.ValueChanged)
        recsTable.addSubview(refreshControll)
        recsTable.dataSource = self
        recsTable.delegate = self
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "googlechrome://url.com")!) {
            browserSegment.insertSegmentWithTitle("Chrome", atIndex: browserSegment.numberOfSegments, animated: false)
        }
        
        Outbrain.initializeOutbrainWithPartnerKey("NANOWDGT01")
        Outbrain.setTestMode(true)
        
        staticLink.setTitle("http://static-tes.outbrain.com/gutte/blog/german2.html", forState: .Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func loadRecs() {
        recs.removeAll()
        recsTable.reloadData()
        Outbrain.fetchRecommendationsForRequest(request, withDelegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openLink(sender: UIButton) {
        let url = NSURL(string: sender.titleLabel!.text!)
        openBrowser(url!)
    }

    func openBrowser(url: NSURL){
        var newUrl = parSwitch.on ? appendQueryParameter(url) : url
        if newUrl == nil {
            let alert = UIAlertController(title: "Parameter Append Error", message: "Could not append to \(url.absoluteString)", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Got It !", style: .Cancel, handler: {
                (action: UIAlertAction!) in
                alert.dismissViewControllerAnimated(true, completion: nil)}))
            presentViewController(alert, animated: true, completion: nil)
        } else {
            switch browserSegment.selectedSegmentIndex {
            case 0:
                let vc = WebKitController()
                vc.webKit.loadRequest(NSURLRequest(URL: newUrl!))
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                let vc = SFSafariViewController(URL: newUrl!)
                presentViewController(vc, animated: true, completion: nil)
            case 3:
                newUrl = NSURL(string: (newUrl?.absoluteString)!.stringByReplacingOccurrencesOfString("http", withString: "googlechrome"))
                fallthrough
            case 2:
                UIApplication.sharedApplication().openURL(newUrl!)
            default:
                break
            }
        }
    }
    
    func appendQueryParameter(url: NSURL) -> NSURL?{
        let component = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        let query = NSURLQueryItem(name: "mobileapp", value: "true")
        if component?.queryItems == nil {
            component?.queryItems = [NSURLQueryItem]()
        }
        component?.queryItems?.append(query)
        let newUrl = component?.URL
        return newUrl
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url = recs[indexPath.row].sourceURL
        openBrowser(url)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if (cell == nil) {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
        }
        cell!.textLabel?.text = recs[indexPath.row].content
        cell!.textLabel?.textColor = recs[indexPath.row].paidLink ? UIColor.purpleColor() : UIColor.brownColor()
        cell!.detailTextLabel?.text = recs[indexPath.row].source
        return cell!
    }
}

extension ViewController: OBResponseDelegate {
    func outbrainDidReceiveResponseWithSuccess(response: OBRecommendationResponse!) {
        print("success \(response.recommendations.count)")
        self.recs.insertContentsOf(response.recommendations as! [OBRecommendation], at: 0)
        refreshControll.endRefreshing()
        recsTable.reloadData()
    }
    
    func outbrainResponseDidFail(response: NSError!) {
        print("failed \(response.localizedDescription)")
        refreshControll.endRefreshing()
    }
}

