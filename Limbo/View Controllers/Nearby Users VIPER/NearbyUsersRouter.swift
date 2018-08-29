//
//  NearbyUsersRouter.swift
//  Limbo
//
//  Created by A-Team User on 27.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//


let nearbyUsersVCIdentifier = "nearbyUsersVC"
let itemsVCIdentifier = "itemPopoverVC"

import UIKit

class NearbyUsersRouter: NSObject {
    
    var navigationController: UINavigationController!
    var mainViewController: UIViewController!
    var storyboard: UIStoryboard!
    
    init(mainVC: UIViewController, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.mainViewController = mainVC
        self.storyboard = UIStoryboard(name: "Main", bundle: nil)
        super.init()
    }
    
    static func createNearbyUsersModule() -> UIViewController {
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: nearbyUsersVCIdentifier) as! NearbyUsersViewControllerV
        let navigationController = UINavigationController(rootViewController: view)
        
        let presenter = NearbyUsersPresenter()
        let interactor = NearbyUsersInteractor()
        let router = NearbyUsersRouter(mainVC: view, navigationController: view.navigationController!)
        
        view.presenter = presenter
        interactor.presenter = presenter
//        router.presenter = presenter
        
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        
        return navigationController
    }
    
    private func properlyPushChatVC(chatVC: ChatViewController) {
        guard var viewControllers = self.navigationController?.viewControllers else { return }
        guard let lastViewController = viewControllers.last else { return }
        if lastViewController.isKind(of: ChatViewController.self) {
            _ = viewControllers.popLast()
            viewControllers.append(chatVC)
            self.navigationController?.setViewControllers(viewControllers, animated: true)
        } else {
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}

extension NearbyUsersRouter: NearbyUsersPresenterToRouterInterface {
    func presentItemPopover(specialItem: SpecialItem, sourceView: UIView, presentingVC: UIViewController) {
        let itemPopoverVC = storyboard.instantiateViewController(withIdentifier: itemsVCIdentifier) as! ItemPopoverViewController
        itemPopoverVC.specialItem = specialItem
        itemPopoverVC.modalPresentationStyle = .popover
        itemPopoverVC.preferredContentSize = CGSize(width: 250, height: 250)
        let popoverPresentationController = itemPopoverVC.popoverPresentationController
        popoverPresentationController?.permittedArrowDirections = .down
        popoverPresentationController!.sourceView = sourceView
        popoverPresentationController!.sourceRect = sourceView.bounds
        popoverPresentationController!.delegate = self
        presentingVC.present(itemPopoverVC, animated: true, completion: nil)
    }
    
    func presentLoginVC(loginDelegate: LoginDelegate) {
        let loginVC: LoginViewController = storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        loginVC.loginDelegate = loginDelegate
        self.mainViewController.present(loginVC, animated: true, completion: nil)
    }
    
    func presentUserAvatars(user: UserModel) {
        let avatarChooseVC = storyboard?.instantiateViewController(withIdentifier: "AvatarCollectionViewController") as! AvatarCollectionViewController
        avatarChooseVC.currentUser = user
        self.mainViewController.present(avatarChooseVC, animated: true, completion: nil)
    }
    
    func createAndPushChatModule(chatRoom: ChatRoomModel, usersConnectivityDelegate: UsersConnectivityDelegate) {
        let view = ChatRouter.createChatModule(using: self.navigationController, usersConnectivityDelegate: usersConnectivityDelegate, chatRoom: chatRoom)
        
        self.properlyPushChatVC(chatVC: view)
    }
    
    func createAndPushAllUsersTVC(users: [UserModel], groupChatDelegate: GroupChatDelegate) {
        let allUsersTVC = storyboard.instantiateViewController(withIdentifier: "allUsersTVC") as! AllUsersTableViewController
        allUsersTVC.groupChatDelegate = groupChatDelegate
        allUsersTVC.users = users
        self.navigationController?.pushViewController(allUsersTVC, animated: true)
    }
    

}


extension NearbyUsersRouter: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}


