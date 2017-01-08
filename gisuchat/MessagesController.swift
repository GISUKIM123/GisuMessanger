//
//  ViewController.swift
//  gisuchat
//
//  Created by GISU KIM on 2016-12-06.
//  Copyright © 2016 GISU KIM. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MessagesController: UITableViewController {
    
    let cellId = "cellId"
    var chatLogController : ChatLogController?
    let personalInfoView = PersonalInfoView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(handleMessage))

        CheckIfUserIsLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    } 
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
         
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            FIRDatabase.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
                
                self.messageDictionary.removeValue(forKey: chatPartnerId)
                self.attempReloadOfTable()
                
                //this is one way of updating the table, but its actually not that safe..
//                self.messages.remove(at: indexPath.row)
//                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                //this cause a major error which the deleted msg come back after a deletion because we actually store data in messageDictionary rather than meessages array
            })
        }
        
    }
    
    var messages = [Message]()
    var messageDictionary = [String: Message]()
    
    func observeUserMessages(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: {(snapshot) in
            
            let userId = snapshot.key
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: {(snapshot) in
            
            let messageId = snapshot.key
            self.fetchmessageWithMessageId(messageId: messageId)
                
            }, withCancel: nil)
   
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: {(snapshot) in
            self.messageDictionary.removeValue(forKey: snapshot.key)
            self.attempReloadOfTable()
        }, withCancel: nil)
    }
        
    private func fetchmessageWithMessageId(messageId: String){
            let meesagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
            meesagesReference.observeSingleEvent(of: .value, with: {(snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message(dictionary: dictionary)
    
                    //message.setValuesForKeys(dictionary)
                    //self.messages.append(message)
                    
                    if let chatPartnerId = message.chatPartnerId() {
                        self.messageDictionary[chatPartnerId] = message
                    }
                    self.attempReloadOfTable()
                }
                
            }, withCancel: nil)
    }
    
    private func attempReloadOfTable(){
        //to fix a bug that profileImages loaded incorrectly
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    func handleReloadTable(){
        //messages does not need to be reloaded every single time, does need to constantly call it
        self.messages = Array(self.messageDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else{
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user: user)
        }, withCancel: nil)
    }

    func handleMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
        
    }
    
    func CheckIfUserIsLoggedIn(){
        // user is not logged in
        if FIRAuth.auth()?.currentUser?.uid == nil {
            //controller present main page after 0 second
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else {
            fetchUserAndSetipNavBarTitle()
        }
 
    }
    
    func fetchUserAndSetipNavBarTitle(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            //for some reason uid = nil
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
//                self.navigationItem.title = dictionary["name"] as? String
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
            }
        }, withCancel: nil)
    }
    
    let profileImageView : UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true

        
        return profileImageView
    }()
    
    lazy var titleView : UIView = {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPersonalProfileView)))
        return titleView
    }()
    
    let containerView : UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        return containerView
    }()
    
    func setupNavBarWithUser(user : User){
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        titleView.addSubview(containerView)
 
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        //ios 0 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive
         = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        self.navigationItem.titleView = titleView
        
    }
    
    func showPersonalProfileView(){
        let modalStyle: UIModalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        personalInfoView.modalTransitionStyle = modalStyle
        personalInfoView.modalPresentationStyle = .overCurrentContext
        personalInfoView.view.backgroundColor = UIColor(white: 1, alpha: 0.7)
        
        present(personalInfoView, animated: true, completion: nil)
    }
    
    func showChatControllerForUser(user: User){
        chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController?.user = user
        chatLogController?.navigationItem.hidesBackButton = true
        chatLogController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handledismiss))
        navigationController?.pushViewController((chatLogController!), animated: true)
    }
    
    func handledismiss(){
        chatLogController?.handleKeyboardDismissWhenTappingAround()
        
        _ = self.navigationController?.popToViewController(self, animated: true)
    }
   
    func handleLogout(){
        do {
           try FIRAuth.auth()?.signOut()
        }catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self 
        present(loginController, animated: true, completion: nil)
    }
    
}

