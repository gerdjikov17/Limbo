//
//  ChatModuleTest.swift
//  LimboTests
//
//  Created by A-Team User on 11.09.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import XCTest
@testable import Limbo

let inMemoryIdentifier = "inMemoryDB"

class ChatModuleTest: XCTestCase {
    
    var chatViewBeingTested: ChatViewController?
    var chatPresenterBeingTested: ChatPresenter?
    var chatInteractorBeingTested: ChatInteractor?
    var chatRouterBeingTested: ChatRouter?
    
    override func setUp() {
        super.setUp()
        MockRealmManager.setDefaultIdentifier(identifier: inMemoryIdentifier)
        
        MockRealmManager.deleteAll()
        
//        _ = MockRealmManager.registerUser(username: "test", password: "teeeest")
//        let user = MockRealmManager.userWith(username: "test", password: "teeeest")!
//        let chatRoom = ChatRoomModel(user: user, gameType: 0, peerIDString: "A")
//        MockRealmManager.addChatRoom(chatRoom: chatRoom)
//        let chatRoomUUID = chatRoom.uuid
//        let realmChatRoom = MockRealmManager.chatRoom(forUUID: chatRoomUUID)!
        
        let user = UserModel(username: "asd", password: "asd")
        let aRoom = ChatRoomModel(user: user, gameType: 1, peerIDString: "asdd")
        UserDefaults.standard.set(true, forKey: Constants.UserDefaults.isLoged)
        UserDefaults.standard.set(user.userID, forKey: Constants.UserDefaults.loggedUserID)
        UserDefaults.standard.synchronize()
        MockRealmManager.addChatRoom(chatRoom: aRoom)
        let chatRoom = MockRealmManager.chatRoom(forUUID: aRoom.uuid)!
        
        chatViewBeingTested = ChatRouter.createChatModule(using: UINavigationController(),
                                                          usersConnectivityDelegate: MockUsersConnectivity(),
                                                          chatRoom: chatRoom)
        
        chatPresenterBeingTested = chatViewBeingTested?.chatPresenter as? ChatPresenter
        
        chatInteractorBeingTested = chatPresenterBeingTested?.chatInteractor as? ChatInteractor
        
        chatRouterBeingTested = chatPresenterBeingTested?.chatRouter as? ChatRouter
        
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testChatViewTableViewIsPresent() {
        _ = chatViewBeingTested?.view
        XCTAssertNotNil(chatViewBeingTested?.chatTableView, "chatview Table view must be present")
    }
    
    func testModulePartsNotNil() {
        XCTAssertNotNil(chatViewBeingTested, "Chat view should not be nil")
        XCTAssertNotNil(chatPresenterBeingTested, "Chat presenter should not be nil")
        XCTAssertNotNil(chatInteractorBeingTested, "Chat interactor should not be nil")
        XCTAssertNotNil(chatRouterBeingTested, "Chat router should not be nil")
    }
    
    
    
}
