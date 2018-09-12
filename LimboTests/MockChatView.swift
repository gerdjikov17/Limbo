//
//  MockChatView.swift
//  LimboTests
//
//  Created by A-Team User on 12.09.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit
@testable import Limbo

class MockChatView: ChatViewInterface {
    func reloadAllData() {
        print("reloadAllData()")
    }
    
    func insert(indexPaths: [IndexPath]) {
        print("insert(indexPaths: )")
    }
    
    func scrollTo(indexPath: IndexPath, at: UITableViewScrollPosition, animated: Bool) {
        print("scrollTo")
    }
    
    func setNavigationItemName(name: String) {
        print("setNavigationItemName(name: )")
    }
    
    func showSilencedMessage() {
        print("showSilencedMessage")
    }
    
    func didTapOnImage(recognizer: UITapGestureRecognizer) {
        
    }
    
    func didTapOnMessage(recognizer: UITapGestureRecognizer) {
        
    }
    
    
}
