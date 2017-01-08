//
//  KeyboardDown.swift
//  gisuchat
//
//  Created by GISU KIM on 2016-12-23.
//  Copyright © 2016 GISU KIM. All rights reserved.
//

import UIKit

extension MessageController:  UITableViewController {
    
    func dismissKeyboard(){
        view.endEditing(true)
    }

}
