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
    
    func loginState(success: Bool, error: Error?)
    func receivedMessage(message: Message)
}

public protocol TSMXMPPOutgoingMessageDelegate {
    func willSendMessage(message: Message)
    func willReceiveSendMessage(message: Message)
    func didFailToSendMessage(error: Error?)
}

public class TSMXMPP: NSObject, TSMXMPPClientDelegate {

    private var hostDomain = ""
    private var resource = ""

    var xmppStream: XMPPStream!
    private var xmppRoster: XMPPRoster!
    private var xmppRosterStorage: XMPPRosterMemoryStorage!

    var passwordJID: String!
    var isAutoReconnecting: Bool!

    public var xmppIncomingMessageDelegate: TSMXMPPIncomingMessageDelegate!
    public var xmppOutgoingMessageDelegate: TSMXMPPOutgoingMessageDelegate!

    public init(domain: String) {

        xmppStream = XMPPStream()

        xmppStream.hostName = "192.168.1.238"
        xmppStream.hostPort = 5222
        xmppStream.startTLSPolicy = .allowed
        hostDomain = domain
        resource = "mobile"

        xmppRosterStorage = XMPPRosterMemoryStorage()
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        xmppRoster.autoFetchRoster = true

        super.init()

        xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)

    }

    public var getFullNameJID: String {
        return xmppStream.myJID!.full()
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

    public func login(username: String, password: String) {

        if !xmppStream.isAuthenticated() && !xmppStream.isConnected(){
            xmppStream.myJID = XMPPJID(user: username, domain: hostDomain, resource: resource)
            passwordJID = password
        }

        if !xmppStream.isConnected() {

            do {
                try xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
            } catch let error as NSError {
                print("Error connecting 😡😡😡: " + error.debugDescription)
                xmppIncomingMessageDelegate.loginState(success: false, error: error)
            }
        }

    }

    public func login(username: String) {

        if !xmppStream.isAuthenticated() && !xmppStream.isConnected(){
            xmppStream.myJID = XMPPJID(user: username, domain: hostDomain, resource: resource)
            passwordJID = "12345678"
        }

        if !xmppStream.isConnected() {

            do {
                try xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
            } catch let error as NSError {
                print("Error connecting 😡😡😡: " + error.debugDescription)
                xmppIncomingMessageDelegate.loginState(success: false, error: error)
            }
        }

    }

    public func autoReconnect(isAutoreconnecting: Bool) {
        self.isAutoReconnecting = isAutoreconnecting
    }

    public func sendMessage(sendTo: String, message: String) {

        let messageResponse = TSMMessage(id: UUID().uuidString, text: message, time: getDateCurrent(date: Date()), files: [])
        self.sendToXMPP(sendTo: sendTo, message: messageResponse)
    }

    func sendMessageAndFile(sendTo: String, message: String, listURL: [URL]) {

        DispatchQueue.main.sync {

            let arrayTransferFiles = ManagerFiles.sharedInstance.uploadingFiles(arrayUrlPath: listURL)
            let messageResponse = TSMMessage(id: UUID().uuidString, text: message, time: self.getDateCurrent(date: Date()), files: arrayTransferFiles)
            self.sendToXMPP(sendTo: sendTo, message: messageResponse)
        }

    }

    func sendMessageAndFileAsync(sendTo: String, message: String, listURL: [URL]) {

        DispatchQueue.main.sync {

            let arrayTransferFiles = ManagerFiles.sharedInstance.uploadingFiles(arrayUrlPath: listURL)
            let messageResponse = TSMMessage(id: UUID().uuidString, text: message, time: self.getDateCurrent(date: Date()), files: arrayTransferFiles)
            self.sendToXMPP(sendTo: sendTo, message: messageResponse)
        }

    }

    private func sendToXMPP(sendTo: String, message: TSMMessage) {

        let sendTo = XMPPJID(user: sendTo, domain: hostDomain, resource: resource)
        let messageTo = XMPPMessage(type: "chat", to: sendTo)
        // Parse Object a JSON
        let encodeData = try? JSONEncoder().encode(message)

        if self.xmppStream.isConnected() {

            messageTo?.addBody(String(data: encodeData!, encoding: .utf8)!)
        }else {

            if(isAutoReconnecting) {
                try! xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
                messageTo?.addBody(String(data: encodeData!, encoding: .utf8)!)
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
        } catch let error as NSError  {
            print("Error authenticating ❌❌❌: " + error.debugDescription)
            xmppIncomingMessageDelegate.loginState(success: false, error: error)
        }
    }

    public func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        print("Authenticated successfully. 😀👍")
        isAutoReconnecting = true
        let presence = XMPPPresence()
        xmppStream.send(presence)

        xmppIncomingMessageDelegate.loginState(success: true, error: nil)
    }

    public func xmppStreamDidDisconnect(_ sender: XMPPStream, withError error: Error?) {
        print("Stream disconnected with error ❌❌: " + error.debugDescription)

        xmppIncomingMessageDelegate.loginState(success: false, error: error)
    }

    public func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: XMLElement) {
        print("Authentication failed with error ❌❌: " + error.debugDescription)
    }

    public func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        let presenceUser = presence.prettyXMLString()
        print(presenceUser)
    }

    public func xmppStream(_ sender: XMPPStream, willSend message: XMPPMessage) -> XMPPMessage? {

        print("Will send message 👉✉️")
        print(message.to, message.from, message.body())

        // Parse JSON to Object
        let jsonData = message.body().data(using: .utf8)!
        let messageResponse = try! JSONDecoder().decode(TSMMessage.self, from: jsonData)
        //

        self.xmppOutgoingMessageDelegate.willSendMessage(message: TSMMessageMapper.instances.transferMessage(tsmMessage: messageResponse))

        return message
    }

    public func xmppStream(_ sender: XMPPStream, willReceive message: XMPPMessage) -> XMPPMessage? {

        print("Will receive send message 👉✉️")
        print(message.to, message.from, message.body())

        // Parse JSON to Object
        let jsonData = message.body().data(using: .utf8)!
        let messageResponse = try! JSONDecoder().decode(TSMMessage.self, from: jsonData)

        self.xmppOutgoingMessageDelegate.willReceiveSendMessage(message: TSMMessageMapper.instances.transferMessage(tsmMessage: messageResponse))

        return message
    }

    public func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        print("Receive message 😃✉️ ")
        print(message.to, message.from, message.body())

        // Parse JSON to Object
        let jsonData = message.body().data(using: .utf8)!
        let messageResponse = try! JSONDecoder().decode(TSMMessage.self, from: jsonData)
        //

        self.xmppIncomingMessageDelegate.receivedMessage(message: TSMMessageMapper.instances.transferMessage(tsmMessage: messageResponse))
    }

    public func xmppStream(_ sender: XMPPStream, didFailToSend message: XMPPMessage, error: Error) {
        self.xmppOutgoingMessageDelegate.didFailToSendMessage(error: error)
    }
}

