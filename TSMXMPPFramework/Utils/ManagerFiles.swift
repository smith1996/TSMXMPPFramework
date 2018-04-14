//
//  ManagerFiles.swift
//  TSMXMPPFramework
//
//  Created by Smith Huamani Hilario on 4/13/18.
//  Copyright © 2018 demos. All rights reserved.
//

import Foundation
import AWSS3

struct ManagerFiles {

    static var sharedInstance = ManagerFiles()

    private var folder = "xmppDemoLib/"

    func uploadingFiles(arrayUrlPath: [URL]) -> [TSMFile] {

        var arrayFiles = [TSMFile]()

        AWSServiceManager.default().defaultServiceConfiguration = ManagerAWSS3.sharedInstances.serviceConfiguration()

        for itemURL in arrayUrlPath {

            let S3Client = AWSS3.default()
            let putObjectRequest = AWSS3PutObjectRequest()
            putObjectRequest?.acl = .publicRead
            putObjectRequest?.bucket = Configurations.sharedInstance.bucket
            putObjectRequest?.key = folder + itemURL.lastPathComponent
            putObjectRequest?.body = itemURL

            do {
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: itemURL.path)
                let fileSizeNumber = fileAttributes[FileAttributeKey.size] as! NSNumber
                putObjectRequest?.contentLength = NSNumber(value: fileSizeNumber.int64Value)
            } catch let error {
                print("Error upload file 😡😡😡: " + error.localizedDescription)
            }

            S3Client.putObject(putObjectRequest!)
            let urlAWSS3 = Configurations.sharedInstance.urlAmazonWS + folder + itemURL.lastPathComponent

            let tsmFile = TSMFile(id: UUID().uuidString, nameFile: itemURL.lastPathComponent, mimeType: itemURL.pathExtension, url: urlAWSS3)

            arrayFiles.append(tsmFile)
        }

        return arrayFiles
    }


}
