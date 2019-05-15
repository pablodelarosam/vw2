//
//  ConfirmSignUpViewController.swift
//  YoSoyVW
//
//  Created by Hugo Juárez on 5/7/19.
//  Copyright © 2019 Hugo Juárez. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider
import AWSMobileClient

class ConfirmSignUpViewController : UIViewController {
    
    var sentTo: String?
  //  var username: String?
    var user: AWSCognitoIdentityUser?
    var completePhoneNumber: String?
    var pool: AWSCognitoIdentityUserPool?

    @IBOutlet weak var sentToLabel: UILabel!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var code: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pool = AWSCognitoIdentityUserPool.init(forKey: Constants.AWSCognitoUserPoolsSignInProviderKey)
        if let username = self.user?.username {
            self.username.text = username
            self.phoneNumberField.text = completePhoneNumber

        }
    }
    
    // MARK: IBActions
    
    // handle confirm sign up
    @IBAction func confirm(_ sender: AnyObject) {
        
        var storyboard: UIStoryboard?
        storyboard = UIStoryboard(name: "Signin", bundle: nil)
        let next = storyboard?.instantiateViewController(withIdentifier: "WelcomeScreen") as? UINavigationController
             self.dismiss(animated: true, completion: nil)
    //    self.present(next!, animated: true, completion: nil)
        
        guard let confirmationCodeValue = self.code.text, !confirmationCodeValue.isEmpty else {
            let alertController = UIAlertController(title: "Confirmation code missing.",
                                                    message: "Please enter a valid confirmation code.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)

            self.present(alertController, animated: true, completion:  nil)
            return
        }
        self.user?.confirmSignUp(self.code.text!, forceAliasCreation: true).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)

                    strongSelf.present(alertController, animated: true, completion:  nil)
                } else {
                    let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                    print("Username ", self?.user?.username!)
                    print(self?.pool?.getUser((self?.user?.username!)!))
                //    self?.pool?.getUser
                    self?.pool?.getUser((self?.user?.username!)!).getAttributeVerificationCode("email")
                    
                    //self?.user?.getAttributeVerificationCode("email")
                  //  self?.user?.verifyAttribute("email", code: <#T##String#>)
                    let next = storyboard?.instantiateViewController(withIdentifier: "WelcomeScreen") as? UINavigationController
                    //     self.dismiss(animated: true, completion: nil)
                    self?.present(next!, animated: true, completion: nil)
                    print(                self?.pool?.getUser((self?.user?.username!)!).getAttributeVerificationCode("email")
)
               
                }
            })
            return nil
        }
    }
    
    // handle code resend action
    @IBAction func resend(_ sender: AnyObject) {
        print(self.user?.getDetails().result?.userAttributes)
        self.user?.resendConfirmationCode().continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let _ = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else if let result = task.result {
                    let alertController = UIAlertController(title: "Code Resent",
                                                            message: "Code resent to \(result.codeDeliveryDetails?.destination! ?? " no message")",
                        preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self?.present(alertController, animated: true, completion: nil)
                }
            })
            return nil
        }
    }
    
}
