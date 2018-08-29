//
//  NearbyUsersPresenter+GroupChats.swift
//  Limbo
//
//  Created by A-Team User on 29.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation

extension NearbyUsersPresenter {
    func groupChatCellTap() {
        let users = self.interactor.currentVisibleUsers()
        guard users != nil else { return }
        self.router.createAndPushAllUsersTVC(users: users!, groupChatDelegate: self.interactor as! GroupChatDelegate)
    }
}
