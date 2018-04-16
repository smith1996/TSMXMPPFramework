//
//  AWSS3.swift
//  TSMXMPPFramework
//
//  Created by Smith Huamani Hilario on 4/13/18.
//  Copyright © 2018 demos. All rights reserved.
//

import Foundation
import AWSCore
import AWSS3

public struct ManagerAWSS3 {

    static var sharedInstances = ManagerAWSS3()

    private var credentialsProvider: AWSCognitoCredentialsProvider? = nil
    private var configuration: AWSServiceConfiguration? = nil


    mutating func serviceConfiguration() -> AWSServiceConfiguration {

        if credentialsProvider == nil {
            credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USWest2, identityPoolId: Configurations.sharedInstance.identityPoolId)
        }

        if configuration == nil {
            configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        }

        return configuration!
    }

}
