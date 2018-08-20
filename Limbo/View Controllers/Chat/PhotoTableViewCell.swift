//
//  PhotoTableViewCell.swift
//  Limbo
//
//  Created by A-Team User on 15.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {
    @IBOutlet weak var sentPhotoImageView: UIImageView!
    @IBOutlet weak var sentPhotoTimeStampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.sentPhotoTimeStampLabel.text = formatter.string(from: messageModel.timeSent)
    }

}
