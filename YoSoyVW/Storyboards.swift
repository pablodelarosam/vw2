//
//  Storyboards.swift
//  YoSoyVW
//
//  Created by Hugo Juárez on 5/9/19.
//  Copyright © 2019 Hugo Juárez. All rights reserved.
//

import Foundation
import UIKit

enum AppStoryboard : String {
    
    case Signin , Signup, Forgetpassword, HomeScreen
    
    var instance : UIStoryboard {
        
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T : UIViewController>(viewControllerClass : T.Type) -> T {
        
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        print("SI")
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard")
        }
        
        return scene
    }
    
    func initialViewController() -> UIViewController? {
        
        return instance.instantiateInitialViewController()
    }
}

extension UIViewController {
    
    // Not using static as it wont be possible to override to provide custom storyboardID then
    class var storyboardID : String {
        
        return "\(self)"
        
        // return String(reflecting: self).components(separatedBy: ".").last!
        // return "\(type(of:self))".components(separatedBy: ".").first!
    }
    
    static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {
        
        return appStoryboard.viewController(viewControllerClass: self)
    }
}
