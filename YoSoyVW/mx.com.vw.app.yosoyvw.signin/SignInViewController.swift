//
//  SignInViewController.swift
//  YoSoyVW
//
//  Created by Hugo Juárez on 5/7/19.
//  Copyright © 2019 Hugo Juárez. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider
import AWSMobileClient


class SignInViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Setup Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var password: UITextField!
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    var usernameText: String?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var trycounter = 0
    var phoneNumber: String?
    weak var delegate: SendInfoDelegate?
    //MARK: Internal varables
    
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.password.text = nil
        self.username.text = usernameText
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        let userUpdateNotification = Notification.Name("dismissmfa")
               NotificationCenter.default.addObserver(self, selector: #selector(dismissSignin(_ :)), name: userUpdateNotification, object: nil)
        setUpTextFields()
        activityIndicator.isHidden = true
        // Add touch gesture for contentView

        // Observe keyboard change
        view.bindToKeyboard()

//             if Constants.retrieveCounterCredentials() == 3 {
//                self.username.isEnabled = false
//                self.password.isEnabled = false
//                self.registerButton.isEnabled = false
//        }
           self.pool = AWSCognitoIdentityUserPool.init(forKey: Constants.AWSCognitoUserPoolsSignInProviderKey)
      
    }
    
    
    
    private func setUpUI() {
        registerButton.layer.borderWidth = 2
        registerButton.layer.borderColor = UIColor(hex: "004666").cgColor
    }
    
    @objc func dismissSignin(_ notification: Notification) {
        self.navigationController?.popToRootViewController(animated: true)
       //   self.dismiss(animated: false, completion: nil)
        // userInfo is the payload send by sender of notification
        if let userInfo = notification.userInfo {
            // Safely unwrap the name sent out by the notification sender
            if (userInfo["user"] as? String) != nil {
                print("pass data", userInfo)
            }
        }

    }
    
    private func setUpTextFields() {
        username.delegate = self
        password.delegate = self
    }
    
    private func setUpMFA() {
        // Enable MFA
        let settings = AWSCognitoIdentityUserSettings()
        self.user = self.pool?.getUser(self.usernameText ?? "")
        delegate?.sendInfo(self.user)
        

        let mfaOptions = AWSCognitoIdentityUserMFAOption()
        mfaOptions.attributeName = "phone_number"
        mfaOptions.deliveryMedium = .email
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
                              NotificationCenter.default.post(name: NSNotification.Name("sendUserInfo"), object: self, userInfo: ["user":  "Jim" ])

                }
                return nil
            })
    }
    
    @IBAction func signInPressed(_ sender: AnyObject) {
        self.user = pool?.getUser(self.username.text!)
  //  .getDetails().result?.userAttributes
        print(pool?.getUser("Charly").getDetails())
        pool?.getUser("Charly").getDetails().continueOnSuccessWith(block: { (response) -> Any? in
            print(response)
        })
        self.pool?.getUser((self.username.text!)).getAttributeVerificationCode("email")
        setUpUI()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        if (self.username.text != nil && self.password.text != nil) {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.username.text!, password: self.password.text! )
            self.passwordAuthenticationCompletion?.set(result: authDetails)
        
        } else {
            let alertController = UIAlertController(title: "Missing information",
                                                    message: "Please enter a valid user name and password",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alertController.addAction(retryAction)
        }
    }
}

extension SignInViewController: AWSCognitoIdentityPasswordAuthentication {
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.usernameText == nil) {
                self.usernameText = authenticationInput.lastKnownUsername
            }
        }
    }
    
    private func handlerAction() {
        let callActionHandler = { (action:UIAlertAction!) -> Void in
    
            
           // self.presentViewController(alertMessage, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let signUpConfirmationViewController = segue.destination as? ConfirmSignInViewController {
           // signUpConfirmationViewController.sentTo = self.sentTo
//            signUpConfirmationViewController.user = self.pool?.getUser(self.username.text!)
//            self.user?.getDetails().continueOnSuccessWith(block: { (att) -> Any? in
//                print(att)
//            })
            signUpConfirmationViewController.completePhoneNumber = self.phoneNumber
        }
    }
    
    private func blockUser() {
        let alertController = UIAlertController(title: "Usuario bloqueado",
                                                message: "Has excedido el límite de intentos",
                                                preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "OK", style: .default, handler: nil )
        alertController.addAction(retryAction)
        self.present(alertController, animated: true, completion: {
            self.username.isEnabled = false
            self.password.isEnabled = false
            self.registerButton.isEnabled = false
        
        } )
        

    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            let callActionHandler = { (action:UIAlertAction!) -> Void in
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
            if let error = error as NSError? {
                print(error.userInfo["message"])
                if error.userInfo["message"] as? String == "Incorrect username or password." {
                    print("Incorrect credentials")
                    if Constants.retrieveCounterCredentials() == 3 {
            
                        self.blockUser()
                    } else {
                        self.trycounter += 1
                        Constants.storeCounterBadCredentials(counter: self.trycounter)

                    }
                } else if error.userInfo["message"] as? String == "User is not confirmed."   {
                    self.user = self.pool?.getUser(self.username.text!)
     
               //    print(self.user?.resendConfirmationCode())
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
                                self?.phoneNumber = result.codeDeliveryDetails?.destination
                                print(result.codeDeliveryDetails?.destination)
                             //   self?.performSegue(withIdentifier: "ConfirmSignInSegue", sender:self)
//                                let alertController = UIAlertController(title: "Code Resent",
//                                                                        message: "Code resent to \(result.codeDeliveryDetails?.destination! ?? " no message")",
//                                    preferredStyle: .alert)
//                                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
//                                alertController.addAction(okAction)
//                                self?.present(alertController, animated: true, completion: nil)
                            }
                        })
                        return nil
                    }
                }
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil )
                alertController.addAction(retryAction)
                if error.userInfo["message"] as? String == "User is not confirmed." {
                    print(self.pool?.getUser("Charly"))
                
                        self.pool?.getUser("Charly").getDetails().continueOnSuccessWith(block: { (response) -> Any? in
                        print(response)
                    })
                    //self.performSegue(withIdentifier: "ConfirmSignInSegue", sender:self)
                }
                    self.present(alertController, animated: true, completion: {
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        
                    } )
                
                
             
                
            } else {
               // self.performSegue(withIdentifier: "confirmSignInSegue", sender:self)
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                                self.username.text = nil
                
             //     self.setUpMFA()
                self.pool?.getUser("Charly2").getDetails().continueOnSuccessWith(block: { (response) -> Any? in
                    print(response)
                })
  
                self.dismiss(animated: true, completion: nil )

            }
        }
    }
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard username != nil else {
            return
        }
        username.resignFirstResponder()
        password.resignFirstResponder()

    }
    
    //MARK: Textfield delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        username.resignFirstResponder()
        password.resignFirstResponder()
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    //MARK: Keyboard methods
    

}

extension UIView {


    func bindToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc func keyboardWillChange(_ notification: Notification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let curveFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = targetFrame.origin.y - curveFrame.origin.y

        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += deltaY
        }, completion: nil)

    }
}

