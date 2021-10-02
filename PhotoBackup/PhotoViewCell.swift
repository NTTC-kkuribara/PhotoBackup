//
//  PhotoViewCell.swift
//  PhotoBackup
//
//  Created by ITMS NTTcom on 2021/10/02.
//

import UIKit
import FirebaseStorageUI

class PhotoViewCell: UICollectionViewCell {

    @IBOutlet weak var backupImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
        
    //override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    //}

    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        // 画像の表示
        backupImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        backupImageView.sd_setImage(with: imageRef)

        // 日時の表示
        //self.dateLabel.text = ""
        //if let date = postData.date {
            //let formatter = DateFormatter()
            //formatter.dateFormat = "yyyy-MM-dd HH:mm"
            //let dateString = formatter.string(from: date)
            //self.dateLabel.text = dateString
        //}

        // いいね数の表示
        //let likeNumber = postData.likes.count
        //likeLabel.text = "\(likeNumber)"

        // いいねボタンの表示
        //if postData.isLiked {
            //let buttonImage = UIImage(named: "like_exist")
            //self.likeButton.setImage(buttonImage, for: .normal)
        //} else {
            //let buttonImage = UIImage(named: "like_none")
            //self.likeButton.setImage(buttonImage, for: .normal)
        //}
    }
}
