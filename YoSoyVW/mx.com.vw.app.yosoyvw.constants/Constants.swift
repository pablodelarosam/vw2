//
//  Constants.swift
//  YoSoyVW
//
//  Created by Hugo Juárez on 5/7/19.
//  Copyright © 2019 Hugo Juárez. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider


struct Constants {
    
    static let AWSCognitoUserPoolsSignInProviderKey = "UserPool"
    
//    static let CognitoIdentityUserPoolRegion: AWSRegionType = .USEast1
//    static let CognitoIdentityUserPoolId = "us-east-1_PD7wwwFZY"
//    static let CognitoIdentityUserPoolAppClientId = "2ce2o36iro7ocaak5rbflbuv4h"
//    static let CognitoIdentityUserPoolAppClientSecret = "1ooii3bhgffbu44ahoete8kh9urvn6ekgupn864u0npot5l5mvlg"
    
    static let CognitoIdentityUserPoolRegion: AWSRegionType = .CACentral1
    static let CognitoIdentityUserPoolId = "ca-central-1_y9b6rRf8w"
    static let CognitoIdentityUserPoolAppClientId = "2ucjlq78imflcv571subdj0h4a"
    static let CognitoIdentityUserPoolAppClientSecret = "mgqb5u74u83s95v4v3qariidis1a7p91q8okfdk9cfcu0fkv4vt"
    
    static func storeCounterBadCredentials(counter: Int) {
        let userDefaults = UserDefaults.standard
        let currentCounter = counter + 1
        userDefaults.setValue(currentCounter , forKey: "counterCredentials")
    }
    
    static func retrieveCounterCredentials() -> Int? {
        let userDefaults = UserDefaults.standard
        let counter = userDefaults.value(forKey: "counterCredentials") as? Int
        return counter
        
    }
    
    static func storePhoneNumbr() {
        
    }
    
}
