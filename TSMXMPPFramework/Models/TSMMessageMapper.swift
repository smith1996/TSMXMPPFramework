//
//  TSMMessageMapper.swift
//  TSMXMPPFramework
//
//  Created by Smith Huamani Hilario on 4/13/18.
//  Copyright © 2018 demos. All rights reserved.
//

import Foundation

public struct TSMMessageMapper {

    static let instances = TSMMessageMapper()

    func transferMessage(tsmMessage: TSMMessage) -> Message {
        return Message(id: tsmMessage.id, text: tsmMessage.text, time: tsmMessage.time, files: transformFiles(arrayTSMmessage: tsmMessage.files!))
    }

    func transformFiles(arrayTSMmessage: [TSMFile]) -> [File] {
        var arrayFile = [File]()

        guard arrayTSMmessage.count != 0 else {
            arrayFile = []
            return arrayFile
        }

        let file = arrayTSMmessage.map { (data) -> File in
            return File(id: data.id, nameFile: data.nameFile, mimeType: data.mimeType, url: data.url)
        }
        arrayFile = file

        return arrayFile
    }

    func transformFilesUser(arrayFiles: [URL]) -> [TSMFile] {
        var arrayFile = [TSMFile]()

        guard arrayFiles.count != 0 else {
            arrayFile = []
            return arrayFile
        }

        let fileUrl = arrayFiles.map { (data) -> TSMFile in
            return TSMFile(id: UUID().uuidString, nameFile: data.lastPathComponent, mimeType: data.pathExtension, url: data.absoluteString)
        }

        arrayFile = fileUrl
        return arrayFile
    }

}

