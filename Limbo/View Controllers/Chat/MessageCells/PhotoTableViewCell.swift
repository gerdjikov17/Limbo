//
//  PhotoTableViewCell.swift
//  Limbo
//
//  Created by A-Team User on 15.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell, SetableForMessageModel {
    
    
    @IBOutlet weak var sentPhotoImageView: UIImageView!
    @IBOutlet weak var sentPhotoTimeStampLabel: UILabel!
    @IBOutlet weak var senderImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func set(forMessageModel message: MessageModel, senderImage: UIImage?) {
        self.setCellUI(forMessageModel: message)
        self.senderImageView?.image = senderImage
    }
    
    func setCellUI(forMessageModel messageModel: MessageModel) {
        if let image = ImageCache.shared.getImage(forKey: (messageModel.messageString as NSString)) {
            self.sentPhotoImageView.image = image
            print("gets data from the cache")
        }
        else {
            let limboDirectory = FileManager.getDocumentsDirectory().appendingPathComponent("Limbo", isDirectory: false)
            let filePath = limboDirectory.appendingPathComponent(messageModel.messageString, isDirectory: false)
            if let imageData = try? Data(contentsOf: filePath) {
                if let image = UIImage(data: imageData) {
                    ImageCache.shared.cacheImage(image: image, forKey: (messageModel.messageString as NSString))
                    self.sentPhotoImageView.image = image
                }
                else {
                    self.sentPhotoImageView.image = #imageLiteral(resourceName: "notfound.png")
                }
            }
            else {
                self.sentPhotoImageView.image = #imageLiteral(resourceName: "notfound.png")
            }
            
            
        }
        self.sentPhotoTimeStampLabel.text = SmartFormatter.instance.formatDate(date: messageModel.timeSent)
    }

}
