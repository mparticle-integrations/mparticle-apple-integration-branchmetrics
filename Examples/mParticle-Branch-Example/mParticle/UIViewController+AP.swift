//
//  UIViewController+AP.swift
//  Fortune
//
//  Created by Edward Smith on 10/4/17.
//  Copyright © 2017 Branch. All rights reserved.
//

import UIKit

extension UIViewController {

    func showAlert(title: String, message: String) {
        let alert =
            UIAlertController(title: title,
                            message: message,
                     preferredStyle: UIAlertControllerStyle.alert
        );
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
        present(alert, animated: true, completion: nil);
    }
    
}
