//
//  ConfirmSignInViewController.swift
//  YoSoyVW
//
//  Created by Hugo Juárez on 5/14/19.
//  Copyright © 2019 Hugo Juárez. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ConfirmSignInViewController: UIViewController {

    var sentTo: String?
    var user: AWSCognitoIdentityUser?
    var completePhoneNumber: String?
    
    @IBOutlet weak var sentToLabel: UILabel!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var code: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let username = self.user?.username {
            self.username.text = username
            print(completePhoneNumber)
            self.phoneNumberField.text = completePhoneNumber
            
        }
    }
    
    // MARK: IBActions
    
    @IBAction func confirmCode(_ sender: Any) {
         print("TAP")
        var storyboard: UIStoryboard?
        storyboard = UIStoryboard(name: "Signin", bundle: nil)
        let next = storyboard?.instantiateViewController(withIdentifier: "WelcomeScreen") as? UINavigationController
           self.dismiss(animated: true, completion: nil)
       // self.navigationController?.popToRootViewController(animated: true)
    //    self.navigationController.pop
//        let customViewController = self.presentingViewController as? CustomViewController
//
//        self.dismiss(animated: true) {
//
//            customViewController?.dismiss(animated: true, completion: nil)
//
//        }
     //   self.present(next!, animated: true, completion: nil)
    }
    // handle confirm sign up
    @IBAction func confirm(_ sender: AnyObject) {
        print("TAP")
        var storyboard: UIStoryboard?
        storyboard = UIStoryboard(name: "Signin", bundle: nil)
        let next = storyboard?.instantiateViewController(withIdentifier: "WelcomeScreen") as? UINavigationController
          //   self.dismiss(animated: true, completion: nil)
        self.present(next!, animated: true, completion: nil)
        
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
                            self?.present(next!, animated: true, completion: nil)
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
