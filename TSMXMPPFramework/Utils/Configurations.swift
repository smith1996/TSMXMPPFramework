//
//  Configurations.swift
//  TSMXMPPFramework
//
//  Created by Smith Huamani Hilario on 4/13/18.
//  Copyright © 2018 demos. All rights reserved.
//

import Foundation

struct Configurations {

    static let sharedInstance = Configurations()

    var identityPoolId: String = {

        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            var myDict: Dictionary<String,AnyObject>
            myDict = NSDictionary(contentsOfFile: path) as! Dictionary<String, AnyObject>
            let aws = myDict["AWSS3"] as! Dictionary<String, AnyObject>
            let identityPoolId = aws["IdentityPoolId"] as! String
            print("------------------------------------")
            print("IdentityPoolId: " + identityPoolId)
            return identityPoolId
        }
        return "us-west-2:c0f33c9f-dd56-4bd1-a210-6329d5864fd1"
    }()

    var bucket: String = {

        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            var myDict: Dictionary<String,AnyObject>
            myDict = NSDictionary(contentsOfFile: path) as! Dictionary<String, AnyObject>
            let aws = myDict["AWSS3"] as! Dictionary<String, AnyObject>
            let bucket = aws["Bucket"] as! String
            print("------------------------------------")
            print("Bucket: " + bucket)
            return bucket
        }
        return "awstaxibucket01"
    }()

    var urlAmazonWS: String = {

        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            var myDict: Dictionary<String,AnyObject>
            myDict = NSDictionary(contentsOfFile: path) as! Dictionary<String, AnyObject>
            let aws = myDict["AWSS3"] as! Dictionary<String, AnyObject>
            let urlAmazonWS = aws["Url AmazonWS"] as! String
            print("Url AmazonWS: " + urlAmazonWS)
            return urlAmazonWS
        }
        return "https://awstaxibucket01.s3.amazonaws.com/"
    }()
}

