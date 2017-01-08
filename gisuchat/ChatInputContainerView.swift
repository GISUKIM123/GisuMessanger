//
//  ChatInputContainerView.swift
//  gisuchat
//
//  Created by GISU KIM on 2016-12-23.
//  Copyright © 2016 GISU KIM. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {
    
    weak var chatLogController: ChatLogController? {
        didSet{
            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
            
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadView)))
        }
        
    }
    
    lazy var inputTextField : UITextField = {
        let TextField = UITextField()
        TextField.placeholder = "Enter Message..."
        TextField.translatesAutoresizingMaskIntoConstraints = false
        TextField.delegate = self
        
        return TextField
    }()

    let uploadImageView: UIImageView = {
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "picIcon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        return uploadImageView
    }()
    
    let separatorlineView : UIView = {
        let separatorlineView = UIView()
        separatorlineView.backgroundColor = UIColor.blue
        separatorlineView.translatesAutoresizingMaskIntoConstraints = false
        return separatorlineView
    }()
    
    
    let sendButton = UIButton(type: .system)
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(uploadImageView)
        
        
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(sendButton)
        //ios9 constraint anchors
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        
        addSubview(self.inputTextField)
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        //         inputTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        addSubview(separatorlineView)
        //x,y,width,height
        separatorlineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorlineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorlineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorlineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.handleSend()
        return true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
