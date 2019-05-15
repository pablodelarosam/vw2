//
//  MultiFactorAuthenticationController.swift
//  CognitoApplication
//
//  Created by David Tucker on 8/1/17.
//  Copyright © 2017 David Tucker. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

//MARK: step 1 Add Protocol here.
protocol SendInfoDelegate: AnyObject {
    func sendInfo(_ user: AWSCognitoIdentityUser?)
}
class MultiFactorAuthenticationController: UIViewController, SendInfoDelegate {
    func sendInfo(_ user: AWSCognitoIdentityUser?) {
        
    }
    
    
    @IBOutlet weak var authenticationCode: UITextField!
    @IBOutlet weak var submitCodeButton: UIButton!
    var sentTo: String?
    var user: AWSCognitoIdentityUser?
    var completePhoneNumber: String?
    
    @IBOutlet weak var sentToLabel: UILabel!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var code: UITextField!
    
    var mfaCompletionSource:AWSTaskCompletionSource<NSString>?
    var signin: SignInViewController?
    @IBAction func submitCodePressed(_ sender: AnyObject) {
        self.mfaCompletionSource?.set(result: NSString(string: authenticationCode.text!))
    }
    
    override func viewDidLoad() {
        let userUpdateNotification = Notification.Name("sendUserInfo")
        NotificationCenter.default.addObserver(self, selector: #selector(retrieveUserInfo(_ :)), name: userUpdateNotification, object: nil)
        
   
    }
    
    @objc func retrieveUserInfo(_ notification: Notification) {
        self.dismiss(animated: false, completion: nil)
        // userInfo is the payload send by sender of notification
        if let userInfo = notification.userInfo {
            // Safely unwrap the name sent out by the notification sender
            if (userInfo["user"] as? String) != nil {
                print("passing data", userInfo)
            }
        }
    }
    
}

extension MultiFactorAuthenticationController: AWSCognitoIdentityMultiFactorAuthentication {
    
    func getCode(_ authenticationInput: AWSCognitoIdentityMultifactorAuthenticationInput, mfaCodeCompletionSource: AWSTaskCompletionSource<NSString>) {
        self.mfaCompletionSource = mfaCodeCompletionSource
    }
    
    func didCompleteMultifactorAuthenticationStepWithError(_ error: Error?) {
        DispatchQueue.main.async(execute: {
            if let error = error as NSError? {
                
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion:  nil)
                       NotificationCenter.default.post(name: NSNotification.Name("dismissmfa"), object: self, userInfo: ["user":  "Jim" ])
            } else {
                  var storyboard: UIStoryboard?
                  storyboard = UIStoryboard(name: "Signin", bundle: nil)
                let next = storyboard?.instantiateViewController(withIdentifier: "WelcomeScreen") as? UINavigationController
           //     self.dismiss(animated: true, completion: nil)
                self.present(next!, animated: true, completion: nil)
           

            }
        })
}
}
