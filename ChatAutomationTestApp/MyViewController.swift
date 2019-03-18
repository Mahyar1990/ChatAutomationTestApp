//
//  ViewController.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/4/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import UIKit
import SwiftyJSON
import FanapPodChatSDK

var myChatObject: Chat?

class MyViewController: UIViewController {
    
    
    
    
    var chatIsReady = false
/*
https://accounts.pod.land/oauth2/authorize/index.html?client_id=2051121e4348af52664cf7de0bda&response_type=token&redirect_uri=https://chat.fanapsoft.ir&scope=profile social:write
*/
    
// SandBox Addresses:
    let socketAddress           = "wss://chat-sandbox.pod.land/ws"
    let serverName              = "chat-server"
    let ssoHost                 = "https://accounts.pod.land"
    let platformHost            = "https://sandbox.pod.land:8043/srv/basic-platform"    // {**REQUIRED**} Platform Core Address
    let fileServer              = "http://sandbox.fanapium.com:8080"                    // {**REQUIRED**} File Server Address
    var token                   = ""
    
    
// Local Addresses
//    let socketAddress           = "ws://172.16.106.26:8003/ws"
//    let serverName              = "chat-server"
//    let ssoHost                 = "http://172.16.110.76"
//    let platformHost            = "http://172.16.106.26:8080/hamsam"    // {**REQUIRED**} Platform Core Address
//    let fileServer              = "http://172.16.106.26:8080/hamsam"    // {**REQUIRED**} File Server Address
//    let token                   = "7a18deb4a4b64339a81056089f5e5922"    // ialexi
//    let token                   = "6421ecebd40b4d09923bcf6379663d87"    // iFelfeli
//    let token                   = "6421ecebd40b4d09923bcf6379663d87"
//    let token = "fbd4ecedb898426394646e65c6b1d5d1" //  {**REQUIRED**} SSO Token JiJi
//    let token = "5fb88da4c6914d07a501a76d68a62363" // {**REQUIRED**} SSO Token FiFi
//    let token = "bebc31c4ead6458c90b607496dae25c6" // {**REQUIRED**} SSO Token Alexi
//    let token = "e4f1d5da7b254d9381d0487387eabb0a" // {**REQUIRED**} SSO Token Felfeli
    
    let wsConnectionWaitTime    = 1                 // Time out to wait for socket to get ready after open
    let connectionRetryInterval = 5                 // Time interval to retry registering device or registering server
    let connectionCheckTimeout  = 10                // Socket connection live time on server
    let messageTtl              = 86400             // Message time to live
    let reconnectOnClose        = true              // auto connect to socket after socket close
    
    let cellId              = "cellId"
    var logArr              = [String]()
    var logHeightArr        = [Int]()
    var logBackgroundColor  = [UIColor]()
    let pickerData          = ["block", "getContacts", "addContact", "removeContact", "createThread", "GetBlockedList", "Unblock", "GetThread", "SendTextMessage"]
    
    
    let tokenTextField: UITextField = {
        let mt = UITextField()
        mt.translatesAutoresizingMaskIntoConstraints = false
        mt.placeholder = "write your token..."
        mt.autocapitalizationType = UITextAutocapitalizationType.none
        mt.autocorrectionType = UITextAutocorrectionType.no
        mt.backgroundColor = UIColor(white: 0.8, alpha: 1)
        return mt
    }()
    
    let sendPingButton: UIButton = {
        let mb = UIButton()
        mb.translatesAutoresizingMaskIntoConstraints = false
        mb.setTitle("set Tocken and Connect Chat...", for: UIControl.State.normal)
        mb.backgroundColor = UIColor(red: 0, green: 150/255, blue: 200/255, alpha: 1.0)
        mb.layer.cornerRadius = 5
        mb.layer.borderWidth = 2
        mb.layer.borderColor = UIColor.clear.cgColor
        mb.layer.shadowColor = UIColor(red: 0, green: 100/255, blue: 110/255, alpha: 1.0).cgColor
        mb.layer.shadowOpacity = 2
        mb.layer.shadowRadius = 1
        mb.layer.shadowOffset = CGSize(width: 0, height: 3)
        mb.addTarget(self, action: #selector(connectChat), for: UIControl.Event.touchUpInside)
        return mb
    }()
    
    let input1TextField: UITextField = {
        let mt = UITextField()
        mt.translatesAutoresizingMaskIntoConstraints = false
        mt.placeholder = "Input 1"
        mt.autocapitalizationType = UITextAutocapitalizationType.none
        mt.autocorrectionType = UITextAutocorrectionType.no
        mt.backgroundColor = UIColor(white: 0.8, alpha: 1)
        return mt
    }()
    
    let input2TextField: UITextField = {
        let mt = UITextField()
        mt.translatesAutoresizingMaskIntoConstraints = false
        mt.placeholder = "Input 2"
        mt.autocapitalizationType = UITextAutocapitalizationType.none
        mt.autocorrectionType = UITextAutocorrectionType.no
        mt.backgroundColor = UIColor(white: 0.8, alpha: 1)
        return mt
    }()
    
    let input3TextField: UITextField = {
        let mt = UITextField()
        mt.translatesAutoresizingMaskIntoConstraints = false
        mt.placeholder = "Input 3"
        mt.autocapitalizationType = UITextAutocapitalizationType.none
        mt.autocorrectionType = UITextAutocorrectionType.no
        mt.backgroundColor = UIColor(white: 0.8, alpha: 1)
        return mt
    }()
    
    let input4TextField: UITextField = {
        let mt = UITextField()
        mt.translatesAutoresizingMaskIntoConstraints = false
        mt.placeholder = "Input 4"
        mt.autocapitalizationType = UITextAutocapitalizationType.none
        mt.autocorrectionType = UITextAutocorrectionType.no
        mt.backgroundColor = UIColor(white: 0.8, alpha: 1)
        return mt
    }()
    
    let pickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.backgroundColor = UIColor(white: 0.8, alpha: 0.8)
        
        return pv
    }()
    
    let logView: UIView = {
        let mv = UIView()
        mv.translatesAutoresizingMaskIntoConstraints = false
        mv.backgroundColor = UIColor.lightText
        mv.layer.cornerRadius = 5
        mv.layer.borderWidth = 2
        mv.layer.borderColor = UIColor.clear.cgColor
        mv.layer.shadowColor = UIColor.darkGray.cgColor
        mv.layer.shadowOpacity = 2
        mv.layer.shadowRadius = 1
        return mv
    }()
    
    let myLogCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let mcv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        mcv.translatesAutoresizingMaskIntoConstraints = false
        mcv.backgroundColor = UIColor.clear
        return mcv
    }()
    
    var picker = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fireButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.play, target: self, action: #selector(fireRequest))
        navigationItem.leftBarButtonItem = fireButton
        
        updateText(cellText: " Input 1 = contactId as Int \n Input 2 = threadId as Int \n Input 3 = userId as Int", cellHeight: 60, cellColor: UIColor.white)
        
        setupViews()
    }
    
    
    @objc func connectChat() {
        if (tokenTextField.text?.count)! > 30 {
            print("my token is : \(tokenTextField.text)")
            token = tokenTextField.text!
            createChat()
        } else {
            // error! Please inter your token
            updateText(cellText: "your token is invalid, write down valid token", cellHeight: 60, cellColor: UIColor.orange)
            token = "74a60ee10840403a9756ce5f02c6d879"
            createChat()
        }
    }
    
    
    
    func createChat() {
        // create Chat object
        myChatObject = Chat(socketAddress:          socketAddress,
                            ssoHost:                ssoHost,
                            platformHost:           platformHost,
                            fileServer:             fileServer,
                            serverName:             serverName,
                            token:                  token,
                            mapApiKey:              nil,
                            mapServer:              "https://api.neshan.org/v1",
                            typeCode:               "default",
                            enableCache:            true,
                            cacheTimeStampInSec:    nil,
                            msgPriority:            1,
                            msgTTL:                 messageTtl,
                            httpRequestTimeout:     nil,
                            actualTimingLog:        nil,
                            wsConnectionWaitTime:   Double(wsConnectionWaitTime),
                            connectionRetryInterval: connectionRetryInterval,
                            connectionCheckTimeout: connectionCheckTimeout,
                            messageTtl:             messageTtl,
                            reconnectOnClose:       true)
        
        myChatObject?.delegate = self
    }
    
    
    // write down senarios
    
    
}




extension MyViewController: MoreInfoDelegate {
    
    func newInfo(type: String, message: String, lineNumbers: Int) {
        self.logBackgroundColor.append(UIColor.gray)
        self.logHeightArr.append(30 + (lineNumbers * 20))
        self.addtext(text: "inside \(type):\n\(message)")
    }
    
}









// MARK: UIPickerView methods
extension MyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("row at index \(row) did selected")
        
        resetCollectionViewCells()
        
        picker = row
        
        switch row {
        case 0:
            updateText(cellText: " Input 1 = contactId as Int \n Input 2 = threadId as Int \n Input 3 = userId as Int", cellHeight: 70, cellColor: UIColor.white)
        case 1: updateText(cellText: " Input 1 = count as Int \n Input 2 = offset as Int \n Input 3 = name as String", cellHeight: 70, cellColor: UIColor.white)
        case 2: updateText(cellText: " Input 1 = cellphoneNumber as String \n Input 2 = email as String \n Input 3 = firstName as String \n Input 4 = lastName as String", cellHeight: 70, cellColor: UIColor.white)
        case 3: updateText(cellText: " Input 1 = id as Int", cellHeight: 40, cellColor: UIColor.white)
        case 4: updateText(cellText: " Input 1 = description as String \n Input 2 = title as String \n Input 3 = inviteeId as String \n Input 4 = inviteeType as String", cellHeight: 70, cellColor: UIColor.white)
        case 5: updateText(cellText: " Input 1 = count as Int \n Input 2 = offset as Int", cellHeight: 40, cellColor: UIColor.white)
        case 6: updateText(cellText: " Input 1 = blockId as String \n Input 2 = contactId as String \n Input 3 = threadId as String \n Input 4 = userId as String", cellHeight: 70, cellColor: UIColor.white)
        case 7: updateText(cellText: " Input 1 = count as Int \n Input 2 = offset as Int \n Input 3 = name as String \n Input 4 = threadId as Int", cellHeight: 70, cellColor: UIColor.white)
        case 8: updateText(cellText: " Input 1 = count as Int \n Input 2 = repliedTo as Int \n Input 3 = threadId as Int", cellHeight: 70, cellColor: UIColor.white)
        default:
            print("Selected row number \(row) that is not in the correct range!")
        }
    }
    
    
    func updateText(cellText: String, cellHeight: Int, cellColor: UIColor) {
        self.addtext(text: cellText)
        self.logHeightArr.append(cellHeight)
        self.logBackgroundColor.append(cellColor)
    }
    
    
    func addtext(text: String) {
        logArr.append(text)
        myLogCollectionView.reloadData()
    }
    
    func resetCollectionViewCells() {
        logArr.removeAll()
        logHeightArr.removeAll()
        logBackgroundColor.removeAll()
        myLogCollectionView.reloadData()
    }
    
}



extension MyViewController {
    
    @objc func fireRequest() {
        switch picker {
        case 0: implementBlock()            // implement Block
        case 1: implementGetContacts()      // implement GetContacts
        case 2: implementAddContact()       // implement AddContact
        case 3: implementRemoveContact()    // implement RemoveContact
        case 4: implementCreateThread()     // implement CreateThread
        case 5: implementGetBlockedList()   // implement GetBlockedList
        case 6: implementUnblock()          // implement Unblock
        case 7: implementGetThreads()       // implement GetThreads
        case 8: implementSendTextMessage()  // implement SendTextMessage
        default:
            print("Selected row number \(picker) that is not in the correct range!")
        }
    }
    
    func implementBlock() {
        let conId:  Int?    = Int(input1TextField.text ?? "")
        let thrId:  Int?    = Int(input2TextField.text ?? "")
        let usrId:  Int?    = Int(input3TextField.text ?? "")
        
        let block = BlockAutomation(contactId: conId, threadId: thrId, typeCode: nil, userId: usrId)
        block.delegate = self
        block.create(uniqueId: { (blockUniqueId) in
            let myText = "block uniqueId = \(blockUniqueId)"
            self.updateText(cellText: myText, cellHeight: 40, cellColor: .cyan)
        }) { (blockedContactModel) in
            let myText = "block response = \(blockedContactModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .cyan)
        }
    }
    
    func implementGetContacts() {
        let count:  Int?    = Int(input1TextField.text ?? "")
        let offst:  Int?    = Int(input2TextField.text ?? "")
        let name:   String? = input3TextField.text
        
        let getContact = GetContactsAutomation(count: count, name: name, offset: offst, typeCode: nil)
        getContact.delegate = self
        getContact.create(uniqueId: { (getContactUniqueId) in
            let myText = "get contact unique id = \(getContactUniqueId)"
            self.updateText(cellText: myText, cellHeight: 40, cellColor: .cyan)
        }, serverResponse: { (getContactsModel) in
            let myText = "get contact model server response = \(getContactsModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .cyan)
        }) { (getContactsModel) in
            let myText = "get contact model cache response = \(getContactsModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .blue)
        }
    }
    
    func implementAddContact() {
        let cell        = input1TextField.text
        let email       = input2TextField.text
        let firstName   = input3TextField.text
        let lastName    = input4TextField.text
        
        let addContact = AddContactAutomation(cellphoneNumber: cell, email: email, firstName: firstName, lastName: lastName)
        addContact.delegate = self
        addContact.create(uniqueId: { (addContactUniqueId) in
            let myText = "add contact unique id = \(addContactUniqueId)"
            self.updateText(cellText: myText, cellHeight: 40, cellColor: .cyan)
            print(myText)
        }) { (addContactModel) in
            let myText = "add contact model response = \(addContactModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .cyan)
        }
    }
    
    func implementRemoveContact() {
        let id: Int?    = Int(input1TextField.text ?? "")
        
        let removeContact = RemoveContactAutomation(id: id)
        removeContact.delegate = self
        removeContact.create(uniqueId: { (removeContactUniqueId) in
            let myText = "remove contact unique id = \(removeContactUniqueId)"
            self.updateText(cellText: myText, cellHeight: 40, cellColor: .cyan)
            print(myText)
        }) { (removeContactModel) in
            let myText = "remove contact model response = \(removeContactModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
            print(myText)
        }
    }
    
    func implementCreateThread() {
        let description:String? = input1TextField.text
        let title:      String? = input2TextField.text
        let inviteeId:  String? = input3TextField.text
        let inviteeType:String? = input4TextField.text
        let invitee = Invitee(id: inviteeId, idType: inviteeType)
        
        let createThread = CreateThreadAutomation(description: description, image: nil, invitees: [invitee], metadata: nil, title: title, type: nil, requestUniqueId: nil)
        createThread.delegate = self
        createThread.create(uniqueId: { (createThreadUniqueId, on) in
            let myText = "create thread unique id \(on) = \(createThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }) { (createThreadModel, on) in
            let myText = "create thread model response \(on) = \(createThreadModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .cyan)
        }
    }
    
    func implementGetBlockedList() {
        let count:  Int?    = Int(input1TextField.text ?? "")
        let offset: Int?    = Int(input1TextField.text ?? "")
        
        let getBlockedList = GetBlockedListAutomation(count: count, offset: offset, typeCode: nil)
        getBlockedList.delegate = self
        getBlockedList.create(uniqueId: { (getBlockedListUniqueId) in
            let myText = "get blocked list unique id = \(getBlockedListUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }) { (getBlockedContactListModel) in
            let myText = "create thread model response = \(getBlockedContactListModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .cyan)
        }
    }
    
    func implementUnblock() {
        let blockId:    Int?    = Int(input1TextField.text ?? "")
        let contactId:  Int?    = Int(input2TextField.text ?? "")
        let threadId:   Int?    = Int(input3TextField.text ?? "")
        let userId:     Int?    = Int(input4TextField.text ?? "")
        
        let unblock = UnblockAutomation(blockId: blockId, contactId: contactId, threadId: threadId, typeCode: nil, userId: userId)
        unblock.delegate = self
        unblock.create(uniqueId: { (unblockUniqueId) in
            let myText = "unblock unique id = \(unblockUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }) { (unblockModel) in
            let myText = "unblock model response = \(unblockModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .cyan)
        }
    }
    
    func implementGetThreads() {
        let count:      Int?    = Int(input1TextField.text ?? "")
        let offset:     Int?    = Int(input2TextField.text ?? "")
        let name:       String? = input3TextField.text
        let threadId:   Int?    = Int(input4TextField.text ?? "")
        
        let getThread = GetThreadAutomation(count: count, coreUserId: nil, metadataCriteria: nil, name: name, new: nil, offset: offset, threadIds: [threadId ?? 0], typeCode: nil)
        getThread.delegate = self
        getThread.create(uniqueId: { (getThreadUniqueId) in
            let myText = "getThread unique id = \(getThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }, serverResponse: { (getThreadsModel) in
            let myText = "get thread model server response = \(getThreadsModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .cyan)
        }) { (getThreadsModel) in
            let myText = "get thread model cache response = \(getThreadsModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .blue)
        }
    }
    
    func implementSendTextMessage() {
        let content:    String? = input1TextField.text
        let repliedTo:  Int?    = Int(input2TextField.text ?? "")
        let threadId: Int? = Int(input3TextField.text ?? "")
        
        let sendTextMessage = SendTextMessageAutomation(content: content, metaData: nil, repliedTo: repliedTo, systemMetadata: nil, threadId: threadId, typeCode: nil, uniqueId: nil)
        sendTextMessage.create(uniqueId: { (sendTextMessageUniqueId) in
            let myText = "getThread unique id = \(sendTextMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }, serverSentResponse: { (sent) in
            let myText = "sendTextMessage sent response = \(sent)"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }, serverDeliverResponse: { (deliver) in
            let myText = "sendTextMessage deliver response = \(deliver)"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }) { (seen) in
            let myText = "sendTextMessage seen response = \(seen)"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }
    }
    
}



// MARK: CollectionView methods
extension MyViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return logArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MyCollectionViewCell
        cell.backgroundColor = logBackgroundColor[indexPath.item]
        cell.myTextView.text = logArr[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cgfloatHeight: CGFloat = CGFloat(logHeightArr[indexPath.item])
        return CGSize(width: view.frame.width - 32, height: cgfloatHeight)
    }
    
}














protocol MoreInfoDelegate: class {
    
    func newInfo(type: String, message: String, lineNumbers: Int)
    
}

enum MoreInfoTypes: String {
    case Block              = "Block"
    case GetContact         = "GetContact"
    case AddContact         = "AddContact"
    case RemoveContact      = "RemoveContact"
    case CreateThread       = "CreateThread"
    case GetBlockedList     = "GetBlockedList"
    case Unblock            = "Unblock"
    case GetThread          = "GetThread"
    case SendTextMessage    = "SendTextMessage"
}










