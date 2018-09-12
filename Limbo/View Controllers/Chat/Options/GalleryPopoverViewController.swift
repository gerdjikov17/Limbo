//
//  GalleryPopoverViewController.swift
//  Limbo
//
//  Created by A-Team User on 12.09.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

class GalleryPopoverViewController: UIViewController {

    var imgPickerDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)!
    var chatRouter: ChatRouterInterface!
    var completion: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cameraButtonTap(_ sender: Any) {
        self.dismiss(animated: true) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.chatRouter.presentUIImagePicker(sourceType: .camera, imgPickerDelegate: self.imgPickerDelegate, completion: self.completion)
            } else {
                self.chatRouter.presentUIImagePicker(sourceType: .photoLibrary, imgPickerDelegate: self.imgPickerDelegate, completion: self.completion)
            }
        }
    }
    
    @IBAction func galleryButonTap(_ sender: Any) {
        self.dismiss(animated: true) {
            self.chatRouter.presentUIImagePicker(sourceType: .photoLibrary, imgPickerDelegate: self.imgPickerDelegate, completion: self.completion)
        }
    }
}
