//
//  RecElement.swift
//  PaidDemo
//
//  Created by Eran Guttentag on 5/16/16.
//  Copyright © 2016 obqa. All rights reserved.
//

import Foundation

class RecElement : NSObject{
    let content: String
    let source: String
    let sourceURL: NSURL
    let paidLink: Bool
    
    init(_content: String, _source: String, _url: String, isPaid: Bool){
        self.content = _content
        self.source = _source
        self.sourceURL = NSURL(string: _url)!
        self.paidLink = isPaid
    }
    
    override var description: String {
        return "\(self.paidLink ? "paid" : "organic"), \(content) BY \(source))"
    }
}
