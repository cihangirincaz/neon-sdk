//
//  File.swift
//  
//
//  Created by Tuna Öztürk on 19.03.2023.
//

import Foundation

extension NotificationCenter {

    class func observe(name: NSNotification.Name, handler: @escaping (Notification) -> Void) {
        self.default.addObserver(forName: name, object: nil, queue: .main, using: handler)
    }
}

