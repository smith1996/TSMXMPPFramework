//
//  ManagerAudio.swift
//  TSMXMPPFramework
//
//  Created by Smith Huamani on 18/04/18.
//  Copyright © 2018 demos. All rights reserved.
//

import Foundation
import AVFoundation

public typealias CompletionBlock = (Bool, String) -> Void

public class TSMAudio {

    private var audioRecorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    
    public init() {
        player = AVAudioPlayer()
    }

    public func enablePermissionsAudio(completion : @escaping CompletionBlock, dispatchAsync: Bool) {
        
        let audioRecordingSession = AVAudioSession.sharedInstance()
        
        do {
            try audioRecordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try audioRecordingSession.setActive(true)
            
            audioRecordingSession.requestRecordPermission({ (allowed) in
                if dispatchAsync == true {
                    
                    DispatchQueue.main.async {
                        guard allowed == true else {
                            completion(false, "Se rechazo los permisos de Audio")
                            return
                        }
                        completion(true, "Se acepto los permisos de Audio")
                    }
                }else {
                    DispatchQueue.main.sync {
                        guard allowed == true else {
                            completion(false, "Se rechazo los permisos de Audio")
                            return
                        }
                        completion(true, "Se acepto los permisos de Audio")
                    }
                }
            })
        } catch let error {
            completion(false, error.localizedDescription)
            finishRecording()
        }
    }

    public func startRecording(fileName: String) {
        
        let audioFilename = searchDocumentsDirectory(pathFile: fileName)

        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44100,
                        AVNumberOfChannelsKey: 2,
                        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()

        } catch let error {
            finishRecording()
            print(error.localizedDescription)
        }
    }

    public func searchDocumentsDirectory(pathFile: String) -> URL {

        let saveTempo = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileUrl = saveTempo.appendingPathComponent(pathFile)
        return fileUrl
    }

    public func finishRecording()  {
        audioRecorder?.stop()
        audioRecorder = nil
    }

    public func playAudio(url: URL) {

        do {
            let dataUrl = try Data(contentsOf: url)
            let sound = try AVAudioPlayer(data: dataUrl)
            player = sound

            sound.prepareToPlay()
            sound.play()
            sound.volume = 2.0
            
        } catch let error{
            print("Error loading file audio TSM: ", error.localizedDescription)
        }
    }


}
