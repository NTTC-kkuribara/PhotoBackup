//
//  RegisterViewController.swift
//  PhotoBackup
//
//  Created by ITMS NTTcom on 2021/09/30.
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var mailaddressTextField: UITextField!
    @IBOutlet weak var passwordTextField1: UITextField!
    @IBOutlet weak var passwordTextField2: UITextField!
    
    @IBAction func handleResisterButton(_ sender: Any) {
        if let accountName = accountTextField.text, let address =  mailaddressTextField.text, let password1 = passwordTextField1.text, let password2 = passwordTextField2.text {

            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if accountName.isEmpty || address.isEmpty || password1.isEmpty || password2.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            if password1 != password2 {
                print("DEBUG_PRINT: パスワード不一致。")
                SVProgressHUD.showError(withStatus: "パスワードが一致しません")
                return
            }
            
            SVProgressHUD.show()
            
            // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
            Auth.auth().createUser(withEmail: address, password: password1) { authResult, error in
                   if let error = error {
                       // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                       print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
                       return
                   }
                
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                
                // 表示名を設定する
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = accountName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            // プロフィールの更新でエラーが発生
                            print("DEBUG_PRINT: " + error.localizedDescription)
                            SVProgressHUD.showError(withStatus: "アカウント名の設定に失敗しました。")
                            return
                        }
                        print("DEBUG_PRINT: [accountName = \(user.displayName!)]の設定に成功しました。")
                      
                        SVProgressHUD.dismiss()

                        // 画面を閉じてタブ画面に戻る
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
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
