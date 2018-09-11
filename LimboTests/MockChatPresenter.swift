//
//  MockChatPresenter.swift
//  LimboTests
//
//  Created by A-Team User on 11.09.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import XCTest
@testable import Limbo

class MockChatPresenter: ChatViewToPresenterInterface {
    
    func requestMessages() {}
    func requestMoreMessages() {}
    
    func viewDidDisappear() {}
    func viewDidLoad() {}
    func viewDidAppear() {}
    
    func makeTableViewScrollToLastRow(animated: Bool) {}
    
    func sendButtonTap(message: String) {}
    func didTapOnImage(recognizer: UITapGestureRecognizer, inTableView tableView: UITableView) {}
    func didTapOnMessage(recognizer: UITapGestureRecognizer, inTableView tableView: UITableView) {}
    func didTapOnOptionsButton(navigatoinButton: UIBarButtonItem) {}
    func didTapOnItemsButton(sourceView: UIView) {}
    func didTapOnAddPhotoButton() {}
    func voiceRecordButtonTap() {}
    
}
