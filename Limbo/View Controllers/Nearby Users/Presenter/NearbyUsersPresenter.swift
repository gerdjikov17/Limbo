//
//  NearbyUsersPresenter.swift
//  Limbo
//
//  Created by A-Team User on 27.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

class NearbyUsersPresenter: NSObject {

    var view: NearbyUsersPresenterToViewInterface!
    var interactor: NearbyUsersPresenterToInteractorInterface!
    var router: NearbyUsersPresenterToRouterInterface!
    
    var itemsCountIfBlind = 0
    var modelViews: [ChatRoomModelView] = Array()
    
    private func initRequiredPropertiesForLoggedUser() {
        self.interactor.initProperties()
        self.interactor.startLoopingForSpectres()
        self.interactor.checkForCurses()
        self.view.setUIContent(userModel: RealmManager.currentLoggedUser()!)

    }
    
    func groupChatCellTap() {
        let users = self.interactor.currentVisibleUsers()
        guard users != nil else { return }
        self.router.createAndPushAllUsersTVC(users: users!, groupChatDelegate: self.interactor as! GroupChatDelegate)
    }
}

extension NearbyUsersPresenter: NearbyUsersInteractorToPresenterInterface {
    func userObjectChanged(user: UserModel) {
        self.view.setUIContent(userModel: user)
    }
    
    func finishedSync(viewModels: [ChatRoomModelView]) {
        self.modelViews = viewModels
        self.view.reloadData()
    }
    
    func foundSpectre() {
        self.itemsCountIfBlind = 1
    }
    
    func lostSpectre() {
        self.itemsCountIfBlind = 0
    }
    
    func newChatRoom(chatRoomModelView: ChatRoomModelView) {
        self.modelViews.append(chatRoomModelView)
        self.view.reloadData()
    }
}

extension NearbyUsersPresenter: NearbyUsersViewToPresenterInterface {
    
    func firstInitialization() {
        
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaults.isLoged) {
            self.router.presentLoginVC(loginDelegate: self)
        }
        else {
            self.initRequiredPropertiesForLoggedUser()
        }
    }
    
    func medallionImageTap(sourceView: UIView, presentingVC: UIViewController) {
        self.router.presentItemPopover(specialItem: .SaintsMedallion, sourceView: sourceView, presentingVC: presentingVC)
    }
    
    func candleImageTap(sourceView: UIView, presentingVC: UIViewController) {
        self.router.presentItemPopover(specialItem: .HolyCandle, sourceView: sourceView, presentingVC: presentingVC)
    }
    
    func batteryLevelDidChange(batteryLevel: Float) {
        self.interactor.setBatteryLevelForCurrentUser(batteryLevel: batteryLevel)
    }
    
    func userImageTap() {
        self.router.presentUserAvatars(user: RealmManager.currentLoggedUser()!)
    }
    
    func signOutButtonTap() {
        guard RealmManager.currentLoggedUser()!.curse == Curse.None.rawValue else {
            self.view.showToast(message: "You can't sign out while cursed")
            return
        }
        self.interactor.userDidSignOut()
        self.router.presentLoginVC(loginDelegate: self)
    }
    
    func numberOfItems() -> Int {
//        temporary or pernament bug fix , method gets called even after presenting the login VC
        guard UserDefaults.standard.bool(forKey: Constants.UserDefaults.isLoged) else {
            return 0
        }
        if self.interactor.isCurrentUserBlind() {
            return itemsCountIfBlind
        }
        return self.modelViews.count
    }
    
    func chatRoomModelView(forIndexPath indexPath: IndexPath) -> ChatRoomModelView {
        return self.modelViews[indexPath.row]
    }
    
    func didSelectItem(atIndexPath indexPath: IndexPath) {
        let chatRoom = self.interactor.chatRoom(forIndexPath: indexPath)
        guard chatRoom.roomType != RoomType.CreateGroupChat.rawValue else {
            self.groupChatCellTap()
            return
        }
        let usCD = self.interactor.usersConnectivityDelegate()
        self.router.createAndPushChatModule(chatRoom: chatRoom, usersConnectivityDelegate: usCD)
        self.interactor.didSelectRoom(withUUID: chatRoom.uuid)
    }
    
    
    func viewDidAppear() {
        if UserDefaults.standard.bool(forKey: Constants.UserDefaults.isLoged) {
            self.interactor.didSelectRoom(withUUID: nil)
            self.interactor.showGroupChats()
            self.interactor.addGroupChatCell()
            self.interactor.filterUsersToShow()
            if self.interactor.hasGifts() {
                self.view.showGiftToast()
            }
        }
        
    }
    
    func viewDidDisappear() {
        
    }
}

extension NearbyUsersPresenter: NearbyUsersRouterToPresenterInterface {
    
}

extension NearbyUsersPresenter: LoginDelegate {
    func didLogin(userModel: UserModel) {
        UserDefaults.standard.set(true, forKey: Constants.UserDefaults.isLoged)
        UserDefaults.standard.set(userModel.userID, forKey: Constants.UserDefaults.loggedUserID)
        UserDefaults.standard.synchronize()
        self.initRequiredPropertiesForLoggedUser()
    }
}
