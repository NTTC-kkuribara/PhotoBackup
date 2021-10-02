//
//  HomeViewController.swift
//  PhotoBackup
//
//  Created by ITMS NTTcom on 2021/09/30.
//

import UIKit
import Firebase
import SVProgressHUD
import Photos

class HomeViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 自動バックアップの間隔時間を入力
    @IBOutlet weak var timerTextField: UITextField!
    
    // タイマー
    var timer: Timer!
    
    // タイマー用の時間のための変数
    var timer_sec: Float = 0
    
    var collection: PHAssetCollection = PHAssetCollection()
    var assets: PHFetchResult<PHAsset> = PHFetchResult()
    var thumbnailSize = CGSize()
    var sections: [[String]] = []
    var cells: [[(dateStr: String, index: Int)]] = []
    
    @IBAction func handleBackupButton(_ sender: Any) {
        // ライブラリ（カメラロール）を指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage

            // あとでCLImageEditorライブラリで加工する
            print("DEBUG_PRINT: image = \(image)")
            
            // 画像をJPEG形式に変換する
            let imageData = image.jpegData(compressionQuality: 0.75)
            // 画像と投稿データの保存場所を定義する
            let postRef = Firestore.firestore().collection(Const.PostPath).document()
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
            // HUDで投稿処理中の表示を開始
            SVProgressHUD.show()
            // Storageに画像をアップロードする
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
                if error != nil {
                    // 画像のアップロード失敗
                    print(error!)
                    SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                    // 投稿処理をキャンセルし、先頭画面に戻る
                    UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                    return
                }
                // FireStoreに投稿データを保存する
                let name = Auth.auth().currentUser?.displayName
                let postDic = [
                    "name": name!,
                    "date": FieldValue.serverTimestamp(),
                    "tag":"",
                    "isFavorite": 0,
                    ] as [String : Any]
                postRef.setData(postDic)
                // HUDで投稿完了を表示する
                SVProgressHUD.showSuccess(withStatus: "アップロードが完了しました")
                // 投稿処理が完了したので先頭画面に戻る
               UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
            }

        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // ImageSelectViewController画面を閉じてタブ画面に戻る
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleLogoutButton(_ sender: Any) {
        // ログアウトする
        try! Auth.auth().signOut()

        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController!, animated: true, completion: nil)

        // ログイン画面から戻ってきた時のためにホーム画面（index = 0）を選択している状態にしておく
        tabBarController?.selectedIndex = 0
    }
    
    @objc func timerAction(_ timer: Timer) {
        autoBackup()
    }
    
    func autoBackup() {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            

            if collection.localizedTitle == nil {

                assets = PHAsset.fetchAssets(with: fetchOptions)
                
            } else {

                assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            }
            
            var assetIndex: [(dateStr: String, index: Int)] = []

            for i in 0 ... (assets.count - 1) {
                
                let asset = assets.object(at: i)
                
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone.current
                formatter.locale = Locale.current
                formatter.dateFormat = "yyyy-MM-dd"
                
                let dateStr = formatter.string(from: asset.creationDate!)

                sections.append([dateStr])
                assetIndex.append((dateStr: dateStr, index: i))
            }
            
            let orderedSet = NSOrderedSet(array: sections)
            sections = orderedSet.array as! [[String]]
            
            for section in sections {
                
                let sectionData: [(dateStr: String, index: Int)] = assetIndex.filter({$0.dateStr == section[0]})
                
                cells.append(sectionData)
                
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
   
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
