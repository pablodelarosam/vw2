//
//  ViewController.swift
//  YoSoyVW
//
//  Created by Hugo Juárez on 5/7/19.
//  Copyright © 2019 Hugo Juárez. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSMobileClient


class ViewController: UIViewController {
    
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        AWSMobileClient.sharedInstance().initialize { (userState, error) in
//            if let userState = userState {
//                switch(userState){
//                case .signedIn:
//                    print("Logged In")
//                case .signedOut:
//                    AWSMobileClient.sharedInstance().showSignIn(navigationController: self.navigationController!, { (userState, error) in
//                        if(error == nil){       //Successful signin
//                            print("Logged In")
//                        }
//                    })
//                default:
//                    AWSMobileClient.sharedInstance().signOut()
//                }
//
//            } else if let error = error {
//                print(error.localizedDescription)
//            }
//        }
        let userUpdateNotification = Notification.Name("mfa")

        self.pool = AWSCognitoIdentityUserPool(forKey: Constants.AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
            // setUpMFA()
        }
         self.refresh()
        
    }
    
    
     private func setUpMFA() {
        // Enable MFA
        let settings = AWSCognitoIdentityUserSettings()
        self.user = self.pool?.currentUser()
        
        let mfaOptions = AWSCognitoIdentityUserMFAOption()
        mfaOptions.attributeName = "phone_number"
        mfaOptions.deliveryMedium = .sms
        settings.mfaOptions = [mfaOptions]
        user?.setUserSettings(settings)
            .continueOnSuccessWith(block: { (response) -> Any? in
                if response.error != nil {
                    let alert = UIAlertController(title: "Error", message: (response.error! as NSError).userInfo["message"] as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion:nil)
                    //   self.resetAttributeValues()
                } else {
                    //   self.fetchUserAttributes()
                }
                return nil
            })
    }

    @IBAction func logout(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("dismiss"), object: self, userInfo: ["user":  "Jim" ])
//          NotificationCenter.default.post(name: NSNotification.Name("dismissmfa"), object: self, userInfo: nil)
        self.user?.signOut()
        self.title = nil
        self.response = nil
        self.refresh()
        AWSMobileClient.sharedInstance().signOut()
      //  signIn()
        

    }

    
    func refresh() {
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result
                self.title = self.user?.username
            //    self.tableView.reloadData()
            })
            return nil
        }
    }
    
}

