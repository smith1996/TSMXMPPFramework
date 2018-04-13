//
//  TSMMesage.swift
//  TSMXMPPFramework
//
//  Created by Smith Huamani Hilario on 4/13/18.
//  Copyright © 2018 demos. All rights reserved.
//

import Foundation

internal struct TSMMessage: Codable {

    let id: String
    let text: String
    let time: String
    let files: [TSMFile]?

    //    enum CodingKeys: String, CodingKey {
    //        case id
    //        case text
    //        case time
    //        case files
    //    }
    //
    //    func encode(to enconder: Encoder) throws {
    //
    //        do {
    //            var container = enconder.container(keyedBy: CodingKeys.self)
    //            try container.encode(id, forKey: .id)
    //            try container.encode(text, forKey: .text)
    //            try container.encode(time, forKey: .time)
    //            try container.encode(files, forKey: .files)
    //
    //        } catch {
    //            print(error)
    //        }
    //
    //    }

}
