//
//  LoginController+handler.swift
//  gisuchat
//
//  Created by GISU KIM on 2016-12-08.
//  Copyright © 2016 GISU KIM. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

extension LoginController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func handlerRegister(){
        guard let email = emailTextField.text, let password = passwordsTextField.text, let name = nameTextField.text else{
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print(error!)
                return
            }
            guard let uid = user?.uid else {
                return
            }
            //sucessfully authenticated user
            let imageName = NSUUID().uuidString
            
            let storageRef = FIRStorage.storage().reference().child("profile_Images").child("\(imageName).jpg")
   
            //guarantee programm not crashed
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
//            if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1){
//            
                //jpeg version is an compressed model of png which is much smaller byte required to be stored
//            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!){
                storageRef.put(uploadData, metadata: nil, completion: {(metadata, error) in
                
                    if error != nil{
                            print(error!)
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                            let values = ["name" : name, "email" : email, "profileImageUrl": profileImageUrl]
                        self.registerUseerIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                    }
                })
            }
            
        })
    }
    
    private func registerUseerIntoDatabaseWithUID(uid: String, values: [String: AnyObject]){
        
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child("users").child(uid)
//        let values = ["name" : name, "email" : email, "profileImageUrl": metadata.downloadUrl()]
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
            
//            self.messagesController?.navigationItem.title = values["name"] as? String
//
            let user = User()
            user.setValuesForKeys(values)
            self.messagesController?.setupNavBarWithUser(user: user)
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    
    func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var seletedImageFromPicker: UIImage?
        
        if let editingImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            seletedImageFromPicker = editingImage
        }else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            seletedImageFromPicker = originalImage
        }
        
        if let selectedImage = seletedImageFromPicker{
            profileImageView.image = selectedImage 
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
