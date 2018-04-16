//
//  TSMMesage.swift
//  TSMXMPPFramework
//
//  Created by Smith Huamani Hilario on 4/13/18.
//  Copyright © 2018 demos. All rights reserved.
//

import Foundation

public struct TSMMessage: Codable {
    let id: String
    let text: String
    let time: String
    let files: [TSMFile]?
}
