//
//  TSMMessageMapper.swift
//  TSMXMPPFramework
//
//  Created by Smith Huamani Hilario on 4/13/18.
//  Copyright © 2018 demos. All rights reserved.
//

import Foundation

internal struct TSMMessageMapper {

    static let instances = TSMMessageMapper()

    func transferMessage(tsmMessage: TSMMessage) -> Message {
        return Message(id: tsmMessage.id, text: tsmMessage.text, time: tsmMessage.time, files: transformFiles(arrayTSMmessage: tsmMessage.files!))
    }

    func transformFiles(arrayTSMmessage: [TSMFile]) -> [File] {
        var arrayFile = [File]()
        if arrayTSMmessage.count != 0 {
            for item in arrayTSMmessage {
                let file = File(id: item.id, nameFile: item.nameFile, mimeType: item.mimeType, url: item.url)
                arrayFile.append(file)
            }
        }else {
            arrayFile = []
        }
        return arrayFile
    }

    func transformFilesUser(arrayFiles: [URL]) -> [TSMFile] {
        var arrayFile = [TSMFile]()
        if arrayFiles.count != 0 {
            for item in arrayFiles {
                let file = TSMFile(id: UUID().uuidString, nameFile: item.lastPathComponent, mimeType: item.pathExtension, url: item.absoluteString)
                arrayFile.append(file)
            }
        }else {
            arrayFile = []
        }
        return arrayFile
    }

}

