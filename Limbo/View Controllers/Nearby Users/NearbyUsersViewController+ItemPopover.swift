//
//  NearbyUsersViewController+ItemPopover.swift
//  Limbo
//
//  Created by A-Team User on 3.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit

extension NearbyUsersViewController {
    @objc func candleImageTap() {
        presentItemPopover(specialItem: SpecialItem.HolyCandle)
    }
    
    @objc func medallionImageTap() {
        presentItemPopover(specialItem: SpecialItem.SaintsMedallion)
    }
    
    func presentItemPopover(specialItem: SpecialItem) {
        let itemPopoverVC = storyboard?.instantiateViewController(withIdentifier: "itemPopoverVC") as! ItemPopoverViewController
        itemPopoverVC.specialItem = specialItem
        itemPopoverVC.modalPresentationStyle = .popover
        itemPopoverVC.preferredContentSize = CGSize(width: 250, height: 250)
        let popoverPresentationController = itemPopoverVC.popoverPresentationController
        popoverPresentationController?.permittedArrowDirections = .down
        popoverPresentationController!.sourceView = self.currentUserImageView
        popoverPresentationController!.sourceRect = self.currentUserImageView.bounds
        popoverPresentationController!.delegate = self
        self.present(itemPopoverVC, animated: true, completion: nil)
    }
}

extension NearbyUsersViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.setUIContent(userModel: self.currentUser)
    }
}
