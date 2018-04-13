//
//  TSMXMPP.swift
//  TSMXMPPFramework
//
//  Created by Smith Huamani Hilario on 4/13/18.
//  Copyright © 2018 demos. All rights reserved.
//

import Foundation
import XMPPFramework

public class TSMXMPP {

    private var stream: XMPPStream!

    public init(domain: String) {
        stream = XMPPStream()
        stream.myJID = XMPPJID(user: "smith", domain: domain, resource: "mobile")
    }

    public var getFullNameJID: String {
        return stream.myJID!.full()
    }

}

