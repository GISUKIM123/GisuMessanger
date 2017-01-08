//
//  PersonalInfoView.swift
//  gisuchat
//
//  Created by GISU KIM on 2017-01-05.
//  Copyright © 2017 GISU KIM. All rights reserved.
//

import UIKit

class PersonalInfoView: UIViewController {
    
    var valueForAlpha: Double = 1
    
    let containerView : UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.yellow
        container.layer.cornerRadius = 50
        container.layer.masksToBounds = true
        container.contentMode = .scaleAspectFill

        return container
    }()
    
    let profileImage : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = UIColor.blue
        image.layer.cornerRadius = 20
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let nameTextField : UILabel = {
        let nameTextField = UILabel()
        nameTextField.text = "Gisu Kim"
        nameTextField.font = UIFont(name: "HelveticaNeue", size: CGFloat(22))
        nameTextField.shadowColor = UIColor.black
        nameTextField.textColor = UIColor.white
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        return nameTextField
    }()
    
    override func viewDidLoad() {
        
//        self.view.backgroundColor = UIColor.clear
        self.view.isOpaque = false
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        view.addSubview(containerView)
        
        //x,y,w,h
        containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -100).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        containerView.addSubview(profileImage)
        
        //x,y,w,h
        profileImage.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -10).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        containerView.addSubview(nameTextField)
        
        //x,y,w,h
        nameTextField.rightAnchor.constraint(equalTo: profileImage.rightAnchor, constant: -10).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: profileImage.leftAnchor, constant: 10).isActive = true
        nameTextField.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalToConstant: 150).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 25).isActive = true        
        
    }
    
    func handleDismiss(){
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
}
