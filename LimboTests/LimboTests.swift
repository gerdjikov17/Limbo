//
//  LimboTests.swift
//  LimboTests
//
//  Created by A-Team User on 11.09.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import XCTest
@testable import Limbo

class LimboTests: XCTestCase {
    
    var chatViewControllerUnderTest: ChatViewController?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        chatViewControllerUnderTest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as? ChatViewController
        chatViewControllerUnderTest?.chatPresenter = MockChatPresenter()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatLoginViewControllerExists() {
        XCTAssertNotNil(chatViewControllerUnderTest, "a ChatViewController instance should be creatable from storyboard")
    }
    
    func testThatAfterViewDidLoadATableViewIsPresent() {
        _ = chatViewControllerUnderTest?.view
        XCTAssertNotNil(chatViewControllerUnderTest?.chatTableView, "a chatTableView instance should be present")
    }
    
    func testThatAfterViewDidLoadAMessageTextFieldIsPresent() {
        _ = chatViewControllerUnderTest?.view
        XCTAssertNotNil(chatViewControllerUnderTest?.messageTextField, "a messageTextfield instance should be present")
    }
    
    func testThatAfterViewDidLoadAllButtonsArePresent() {
        _ = chatViewControllerUnderTest?.view
        XCTAssertNotNil(chatViewControllerUnderTest?.sendButton, "a sendButton instance should be present")
        XCTAssertNotNil(chatViewControllerUnderTest?.navigationItem.rightBarButtonItems, "a rightBarButtonItems instance should be present")
    }

    
}
