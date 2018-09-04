//
//  AvatarCollectionReusableViewFooter.swift
//  Limbo
//
//  Created by A-Team User on 30.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import RealmSwift

class AvatarCollectionReusableViewFooter: UICollectionReusableView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var presentingVC: UIViewController?
    
    @IBAction func uploadAvatarButtonTap(_ sender: Any) {

        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = false
        imgPicker.sourceType = .photoLibrary
        self.presentingVC?.present(imgPicker, animated: true, completion: nil)
    }
    
    @IBAction func dismissButtonTap(_ sender: Any) {
        self.presentingVC?.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let clientID = "0feecf2e4de72c6"
            let headers = ["Authorization": "Client-ID " + clientID, "Accept": "application/json"]
            let urlPrefix = URL(string: "https://api.imgur.com/3/image")
            var request = URLRequest(url: urlPrefix!)
            request.allHTTPHeaderFields = headers
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = UIImageJPEGRepresentation(pickedImage, 1)?.base64EncodedData(options: .lineLength64Characters)
            request.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {             // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {// check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    
                    print("response = \(String(describing: response))")
                }
                
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                print("responseJSON = \(String(describing: json))")
                let responseData = json!["data"] as? [String: Any]
                let avatarString = responseData!["link"] as! String
                let realm = try! Realm()
                if let currentlyLoggedUser = RealmManager.currentLoggedUser() {
                    realm.beginWrite()
                    currentlyLoggedUser.avatarString = avatarString
                    try! realm.commitWrite()
                }
            }
            task.resume()
            self.presentingVC?.dismiss(animated: true, completion:nil)
            self.presentingVC?.dismiss(animated: true, completion:nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.presentingVC?.dismiss(animated: true, completion:nil)
    }
    
}
