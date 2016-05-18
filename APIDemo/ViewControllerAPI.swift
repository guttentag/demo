//
//  ViewController.swift
//  APIDemo
//
//  Created by Eran Guttentag on 5/16/16.
//  Copyright © 2016 obqa. All rights reserved.
//

import UIKit
import SafariServices

class ViewControllerAPI: UIViewController {

    var uuid: String!
    var recs: [RecElement]!
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var browserSegment: UISegmentedControl!
    @IBOutlet weak var parameterSwitch: UISwitch!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var urlBtn: UIButton!
    @IBOutlet weak var recsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        generateID(uuidLabel)
        urlBtn.setTitle("http://static-test.outbrain.com/gutte/blog/german5.html", forState: .Normal)
        recs = [RecElement]()
        
        self.refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewControllerAPI.loadRecs), forControlEvents: UIControlEvents.ValueChanged)
        recsTable.addSubview(refreshControl)
        recsTable.dataSource = self
        recsTable.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadRecs(){
        recs.removeAll()
        recsTable.reloadData()
        let url = NSURL(string: "http://odb.outbrain.com/utils/get?key=NANOWDGT01&api_user_id=\(uuid)&url=http://static-test.outbrain.com/gutte/blog/german1.html&format=vjnc&testMode=true&widgetJSId=SDK_2&idx=0")
        let request = NSURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            if error == nil && (response as! NSHTTPURLResponse).statusCode == 200 {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                    //NSLog("\(json.description)")
                    let docs = json["response"]!!["documents"]!!["doc"] as! NSArray
                    for doc in docs {
                        let title = doc["content"] as! String
                        let source = doc["source_display_name"] as! String
                        let url = doc["url"] as! String
                        let rec = RecElement(_content: title, _source: source, _url: url, isPaid: Bool(doc["pc_id"] != nil))
                        self.recs.append(rec)
                    }
                }
                catch let er as NSError? {
                    NSLog("wrong \(er?.description)")
                }
            }
            self.refreshControl.endRefreshing()
            self.recsTable.reloadData()
        })
        task.resume()
    }

    
    @IBAction func generateID(sender: AnyObject) {
        uuid = generateID()
        uuidLabel.text = uuid
    }
    
    func generateID()->String{
        var chars: [Character] = [Character].init(count: 36, repeatedValue: "0")
        for i in 0...35 {
            switch i {
            case 8, 12, 16, 20:
                chars[i] = "-"
            default:
                let rand = arc4random_uniform(40) + 10
                let digit = String(rand, radix: 16, uppercase: true)
                chars[i] = digit.characters.first!
            }
        }
        return String(chars)
    }
    
    @IBAction func openLink(sender: UIButton) {
        let url = NSURL(string: sender.titleLabel!.text!)
        openBrowser(url!)
    }
    
    func openBrowser(url: NSURL){
        let newUrl = parameterSwitch.on ? appendQueryParameter(url) : url
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
        NSLog("\(url)\n\(newUrl)")
        return newUrl
    }
}

extension ViewControllerAPI: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url = recs[indexPath.row].sourceURL
        openBrowser(url)
    }
}

extension ViewControllerAPI: UITableViewDataSource {
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


