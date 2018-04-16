//
//  Message.swift
//  TSMXMPPFramework
//
//  Created by Smith Huamani Hilario on 4/13/18.
//  Copyright © 2018 demos. All rights reserved.
//

import Foundation

public struct Message {
    public let id: String
    public let text: String
    public let time: String
    public let files: [File]?
}

