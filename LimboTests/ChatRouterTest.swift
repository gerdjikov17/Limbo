//
//  ChatRouterTest.swift
//  LimboTests
//
//  Created by A-Team User on 11.09.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import XCTest
@testable import Limbo

class ChatRouterTest: XCTestCase {
    
    var chatRouterBeingTested = ChatRouter(navigationController: UINavigationController())
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatChatRouterNavigationControllerIsPresent() {
        XCTAssertNotNil(chatRouterBeingTested.navigationController, "ChatRouter's nav controller should be present")
    }
    
}
