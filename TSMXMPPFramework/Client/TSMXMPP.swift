//
//  TSMXMPP.swift
//  TSMXMPPFramework
//
//  Created by Smith Huamani Hilario on 4/13/18.
//  Copyright © 2018 demos. All rights reserved.
//

import Foundation
import XMPPFramework

public protocol TSMXMPPIncomingMessageDelegate {
    func connect(error: TSMXMPPError?)
    func authenticateFailed(error: TSMXMPPError?)
    func receivedMessage(message: Message)
}

public protocol TSMXMPPOutgoingMessageDelegate {
    func willSendMessage(message: Message)
    func willReceiveSendMessage(message: Message)
    func didFailToSendMessage(error: TSMXMPPError?)
}

public class TSMXMPP: NSObject, TSMXMPPClientDelegate {

    private var hostDomain = ""

    var xmppStream: XMPPStream!
    private var xmppRoster: XMPPRoster!
    private var xmppRosterStorage: XMPPRosterCoreDataStorage!

    var passwordJID: String!
    var isAutoReconnecting: Bool!

    public var xmppIncomingMessageDelegate: TSMXMPPIncomingMessageDelegate!
    public var xmppOutgoingMessageDelegate: TSMXMPPOutgoingMessageDelegate!

    public init(domain: String) {
        xmppStream = XMPPStream()

        xmppStream.hostName = "52.33.108.200"
        xmppStream.hostPort = 5222
        xmppStream.startTLSPolicy = .allowed
        hostDomain = domain

        xmppRosterStorage = XMPPRosterCoreDataStorage()
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        xmppRoster.autoFetchRoster = true
        xmppRoster.activate(xmppStream)
        
        super.init()
        xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }

    public var getFullNameJID: String {
        let fullname = xmppStream.myJID!.full().components(separatedBy: "/")
        return fullname[0]
    }

    public func disconnect() {
        self.isAutoReconnecting = false
        var _ = XMPPPresence(type: "unavailable")
        xmppStream.disconnect()
    }

    private func getDateCurrent(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    private func connectToServer() {
        do {
            try xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
        } catch {
            xmppIncomingMessageDelegate.authenticateFailed(error: TSMXMPPError(errorCode: .serverTimeout))
        }
    }

    public func login(username: String, password: String) {
        if !xmppStream.isAuthenticated() && !xmppStream.isConnected(){
            xmppStream.myJID = XMPPJID(string: username + "@" + hostDomain)
            passwordJID = password
        }

        if !xmppStream.isConnected() {
            connectToServer()
        }
    }

    public func login(username: String) {
        if !xmppStream.isAuthenticated() && !xmppStream.isConnected(){
            xmppStream.myJID = XMPPJID(string: username + "@" + hostDomain)
            passwordJID = "123"
        }

        if !xmppStream.isConnected() {
            connectToServer()
        }
    }

    public func autoReconnect(isAutoreconnecting: Bool) {
        self.isAutoReconnecting = isAutoreconnecting
    }

    public func sendMessage(sendTo: String, message: String) {
        let messageResponse = TSMMessage(id: UUID().uuidString, userSender: sendTo + "@" + hostDomain,
                                         text: message, time: getDateCurrent(date: Date()), files: [])
        self.sendToXMPP(sendTo: sendTo, message: messageResponse)
    }

    public func sendMessageAndFile(sendTo: String, message: String, listURL: [URL]) {
        let arrayTransferFiles = ManagerFiles.sharedInstance.uploadingFiles(arrayUrlPath: listURL)
        let messageResponse = TSMMessage(id: UUID().uuidString, userSender: sendTo + "@" + hostDomain,
                                         text: message, time: self.getDateCurrent(date: Date()), files: arrayTransferFiles)
        self.sendToXMPP(sendTo: sendTo, message: messageResponse)
    }

    public func sendMessageAndFileAsync(sendTo: String, message: String, listURL: [URL]) {
        let arrayTransferFiles = ManagerFiles.sharedInstance.uploadingFiles(arrayUrlPath: listURL)
        let messageResponse = TSMMessage(id: UUID().uuidString, userSender: sendTo + "@" + hostDomain,
                                         text: message, time: self.getDateCurrent(date: Date()), files: arrayTransferFiles)
        self.sendToXMPP(sendTo: sendTo, message: messageResponse)
    }

    private func sendToXMPP(sendTo: String, message: TSMMessage) {
        let sendTo = XMPPJID(string: sendTo + "@" + hostDomain)
        let messageTo = XMPPMessage(type: "chat", to: sendTo)
        // Parse Object a JSON
        let encodeData = try? JSONEncoder().encode(message)

        if self.xmppStream.isConnected() {

            messageTo?.addBody(String(data: encodeData!, encoding: .utf8)!)
            xmppStream.send(messageTo)
        }else {

            if(isAutoReconnecting) {
                connectToServer()
                messageTo?.addBody(String(data: encodeData!, encoding: .utf8)!)
                xmppStream.send(messageTo)
            }
        }
    }

}

extension TSMXMPP: XMPPStreamDelegate {

    public func xmppStreamWillConnect(_ sender: XMPPStream!) {
        print("WillConnect. 👍🙏")
        print(sender.myJID.full())
    }

    public func xmppStreamDidConnect(_ sender: XMPPStream) {
        print("Connected successlly.😀👍")
        print("Loggin in as " + sender.myJID!.full())

        do {
            try xmppStream.authenticate(withPassword: self.passwordJID)
        } catch  {
            xmppIncomingMessageDelegate.authenticateFailed(error: TSMXMPPError(errorCode: .authenticationFailed))
        }
    }

    public func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        print("Authenticated successfully. 😀👍")
        isAutoReconnecting = true
        let presence = XMPPPresence()
        xmppStream.send(presence)

        xmppIncomingMessageDelegate.connect(error: nil)
    }

    public func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: XMLElement) {
        xmppIncomingMessageDelegate.authenticateFailed(error: TSMXMPPError(errorCode: .customer, error: error.description))
    }
    
    public func xmppStreamDidDisconnect(_ sender: XMPPStream, withError error: Error?) {
        xmppIncomingMessageDelegate.connect(error: TSMXMPPError(errorCode: .customer, error: error?.localizedDescription))
    }
    
    //////////////////
    public func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        let presenceUser = presence.prettyXMLString()
        print(presenceUser)
    }

    public func xmppStream(_ sender: XMPPStream, willSend message: XMPPMessage) -> XMPPMessage? {
        print("Will send message ✈️✉️")
        // Parse JSON to Object
        let jsonData = message.body().data(using: .utf8)!
        let messageResponse = try! JSONDecoder().decode(TSMMessage.self, from: jsonData)
        //

        self.xmppOutgoingMessageDelegate.willSendMessage(message: TSMMessageMapper.instances.transferMessage(tsmMessage: messageResponse, isForme: false))

        return message
    }

    public func xmppStream(_ sender: XMPPStream, willReceive message: XMPPMessage) -> XMPPMessage? {
        print("Will receive send message 👉✉️")
        // Parse JSON to Object
        let jsonData = message.body().data(using: .utf8)!
        let messageResponse = try! JSONDecoder().decode(TSMMessage.self, from: jsonData)

        self.xmppOutgoingMessageDelegate.willReceiveSendMessage(message: TSMMessageMapper.instances.transferMessage(tsmMessage: messageResponse, isForme: true))

        return message
    }

    public func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        print("Receive message 😃✉️ ")
        // Parse JSON to Object
        let jsonData = message.body().data(using: .utf8)!
        let messageResponse = try! JSONDecoder().decode(TSMMessage.self, from: jsonData)
        //

        self.xmppIncomingMessageDelegate.receivedMessage(message: TSMMessageMapper.instances.transferMessage(tsmMessage: messageResponse, isForme: true))
    }

    public func xmppStream(_ sender: XMPPStream, didFailToSend message: XMPPMessage, error: Error) {
        self.xmppOutgoingMessageDelegate.didFailToSendMessage(error: TSMXMPPError(errorCode: .customer, error: error.localizedDescription))
    }
}

