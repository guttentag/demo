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

    @IBOutlet weak var uuidTextField: UITextField!
    @IBOutlet weak var uuidSwitch: UISwitch!
    @IBOutlet weak var recsTable: UITableView!
    @IBOutlet weak var staticLink: UIButton!
    @IBOutlet weak var browserSegment: UISegmentedControl!
    
    var recs: [OBRecommendation] = [OBRecommendation]()
    var refreshControll: UIRefreshControl!
    let request: OBRequest = OBRequest.init(url: "http://deliden1.blogspot.com/", widgetID: "SDK_1")
    
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
        var newUrl = uuidSwitch.isOn ? appendQueryParameter(url) : url
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
                break
//                let vc = WebKitController()
//                vc.webKit.load(URLRequest(url: newUrl!))
//                self.navigationController?.pushViewController(vc, animated: true)
            case 2:
                let vc = SFSafariViewController(url: newUrl!)
                present(vc, animated: true, completion: nil)
            case 4:
                newUrl = URL(string: (newUrl?.absoluteString)!.replacingOccurrences(of: "http", with: "googlechrome"))
                fallthrough
            case 3:
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
//        let url = URL(string: String("http://ridr-10004-prod-nydc1.nydc1.outbrain.com:8080/network/redir?did=1153328668&pc_id=67180922&req_id=AA55BB765MN&origSrc=5456876&shouldOpenInExternalBrowser=true&oieb=true&uuid=Gutte12a-ea30-4a98-a414-b395ba1-hgju&installationType=ios_sdk"))
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
        let rec = recs[(indexPath as NSIndexPath).row]
        print("rec data \(rec.isPaidLink) \(rec.shouldOpenInSafariViewController)")
        cell!.textLabel?.text = rec.content
        if rec.isPaidLink {
            if rec.shouldOpenInSafariViewController{
                cell!.textLabel?.textColor = UIColor.cyan
            } else {
                cell!.textLabel?.textColor = UIColor.purple
            }
        } else {
            cell!.textLabel?.textColor = UIColor.brown
        }
        cell!.detailTextLabel?.text = rec.source!
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
    
//    func showAlertView(title: String?, message: String?) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//        alertController.addAction(okAction)
//        self.present(alertController, animated: true, completion: nil)
//        
//        
//        let delayTime = dispatch_time_t.
//        dispatch_after(delayTime, dispatch_get_main_queue()) {
//            print("Bye. Lovvy")
//            alertController.dismissViewControllerAnimated(true, completion: nil)
//        }
//    }
}

