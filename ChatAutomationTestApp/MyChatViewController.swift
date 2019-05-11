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

class MyChatViewController: UIViewController {
    
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
//    var token                   = "7a18deb4a4b64339a81056089f5e5922"    // ialexi
//    let token                   = "6421ecebd40b4d09923bcf6379663d87"    // iFelfeli
//    var token                   = "7cba09ff83554fc98726430c30afcfc6"    // ZiZi
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
    let pickerData          = ["AddContact", "Block", "GetBlockedList", "GetContacts", "RemoveContact", "SearchContact", "Unblock", "UpdateContact", "AddParticipants", "CreateThread", "CreateThreadWithMessage", "GetHistory", "GetThread", "GetThreadParticipants", "LeaveThread", "MuteThread", "UnmuteThread", "RemoveParticipant", "SpamThread", "DeleteMessage", "EditMessage", "ForwardMessage", "ReplyTextMessage", "SendTextMessage"]
    
    let tokenTextField: UITextField = {
        let mt = UITextField()
        mt.translatesAutoresizingMaskIntoConstraints = false
        mt.placeholder = "write your token..."
        mt.autocapitalizationType = UITextAutocapitalizationType.none
        mt.autocorrectionType = UITextAutocorrectionType.no
        mt.backgroundColor = UIColor(white: 0.8, alpha: 1)
        return mt
    }()
    
    let setTokenAndConnectChatButton: UIButton = {
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
        
//        if let myToken = UserDefaults.standard.value(forKey: MyUserDefaultKeys.token) as? String {
//            if myToken.count > 30 {
//                token = myToken
//                createChat()
//            } else {
//                updateText(cellText: "your token is less than 30 characters!, get valid token!", cellHeight: 60, cellColor: UIColor.orange)
//            }
//        } else {
//            updateText(cellText: "your token is invalid!, get valid token!", cellHeight: 60, cellColor: UIColor.orange)
//        }
        
        if (tokenTextField.text?.count)! > 30 {
            print("my token is : \(tokenTextField.text)")
            token = tokenTextField.text!
            createChat()
        } else {
            // error! Please inter your token
            updateText(cellText: "your token is invalid, write down valid token", cellHeight: 60, cellColor: UIColor.orange)
/*
https://accounts.pod.land/oauth2/authorize/index.html?client_id=2051121e4348af52664cf7de0bda&response_type=token&redirect_uri=https://chat.fanapsoft.ir&scope=profile social:write
 */
            token = "48038718d349482785cd08254e931dae"
//            token = "7a18deb4a4b64339a81056089f5e5922"
//            token = "7cba09ff83554fc98726430c30afcfc6"
            createChat()
        }
        
    }
    
    
    
    func createChat() {
        setTokenAndConnectChatButton.isEnabled = false
        
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
                            enableCache:            false,
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




extension MyChatViewController: MoreInfoDelegate {
    
    func newInfo(type: String, message: String, lineNumbers: Int) {
        self.logBackgroundColor.append(UIColor.gray)
        self.logHeightArr.append(30 + (lineNumbers * 20))
        self.addtext(text: "inside \(type):\n\(message)")
    }
    
}









// MARK: UIPickerView methods
extension MyChatViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
        resetTextFields()
        
        picker = row
        
        switch row {
        case 0: updateText(cellText: " Input 1 = cellphoneNumber as String \n Input 2 = email as String \n Input 3 = firstName as String \n Input 4 = lastName as String", cellHeight: 70, cellColor: .white)
        case 1: updateText(cellText: " Input 1 = contactId as Int \n Input 2 = threadId as Int \n Input 3 = userId as Int", cellHeight: 70, cellColor: .white)
        case 2: updateText(cellText: " Input 1 = count as Int \n Input 2 = offset as Int", cellHeight: 40, cellColor: .white)
        case 3: updateText(cellText: " Input 1 = count as Int \n Input 2 = offset as Int \n Input 3 = name as String", cellHeight: 70, cellColor: .white)
        case 4: updateText(cellText: " Input 1 = id as Int", cellHeight: 40, cellColor: .white)
        case 5: updateText(cellText: " Input 1 = cellPhoneNumner as String \n Input 2 = firstName as String \n Input 3 = lastName as String \n Input 4 = id as Int", cellHeight: 70, cellColor: .white)
        case 6: updateText(cellText: " Input 1 = blockId as String \n Input 2 = contactId as String \n Input 3 = threadId as String \n Input 4 = userId as String", cellHeight: 70, cellColor: .white)
        case 7: updateText(cellText: " Input 1 = contactId as Int \n Input 2 = cellphoneNumber as String \n Input 3 = email as String \n Input 4 = fullname (contain firstname and lastname seperated by cama ',') as String", cellHeight: 90, cellColor: .white)
            
        case 8: updateText(cellText: " Input 1 = threadId as Int \n Input 2 = ContactId1 as Int \n Input 3 = ContactId2 as Int \n Input 4 = ContactId3 as Int", cellHeight: 70, cellColor: .white)
        case 9: updateText(cellText: " Input 1 = description as String \n Input 2 = title as String \n Input 3 = inviteeId as String \n Input 4 = inviteeType as String", cellHeight: 70, cellColor: .white)
        case 10: updateText(cellText: " Input 1 = message text as String \n Input 2 = title as String \n Input 3 = inviteeId as String \n Input 4 = inviteeType as String", cellHeight: 70, cellColor: .white)
        case 11: updateText(cellText: " Input 1 = threadId as Int \n Input 2 = fromTime as UInt \n Input 3 = toTime as UInt \n Input 4 = query as String", cellHeight: 70, cellColor: .white)
        case 12: updateText(cellText: " Input 1 = count as Int \n Input 2 = offset as Int \n Input 3 = name as String \n Input 4 = threadId as Int", cellHeight: 70, cellColor: .white)
        case 13: updateText(cellText: " Input 1 = count as Int \n Input 2 = offset as Int \n Input 3 = name as String \n Input 4 = threadId as Int", cellHeight: 70, cellColor: .white)
        case 14: updateText(cellText: " Input 1 = ThreadId", cellHeight: 50, cellColor: .white)
        case 15: updateText(cellText: " Input 1 = ThreadId", cellHeight: 50, cellColor: .white)
        case 16: updateText(cellText: " Input 1 = ThreadId", cellHeight: 50, cellColor: .white)
        case 17: updateText(cellText: " Input 1 = ThreadId \n Input 2 = participant as Int \n Input 3 = participant as Int \n Input 4 = participant as Int", cellHeight: 50, cellColor: .white)
        case 18: updateText(cellText: " Input 1 = ThreadId", cellHeight: 50, cellColor: .white)
            
        case 19: updateText(cellText: " Input 1 = subjectId as Int", cellHeight: 40, cellColor: .white)
        case 20: updateText(cellText: " Input 1 = content as String \n Input 2 = repliedTo as Int \n Input 3 = subjectId as Int", cellHeight: 70, cellColor: .white)
        case 21: updateText(cellText: " Input 1 = messageIds as [Int] \n Input 2 = repliedTo as Int \n Input 3 = subjectId as Int", cellHeight: 70, cellColor: .white)
        case 22: updateText(cellText: " Input 1 = content as String \n Input 2 = repliedTo as Int \n Input 3 = subjectId as Int", cellHeight: 70, cellColor: .white)
        case 23: updateText(cellText: " Input 1 = content as String \n Input 2 = repliedTo as Int \n Input 3 = threadId as Int", cellHeight: 70, cellColor: .white)
            
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
    
    func resetTextFields() {
        input1TextField.text?.removeAll()
        input2TextField.text?.removeAll()
        input3TextField.text?.removeAll()
        input4TextField.text?.removeAll()
    }
    
}



extension MyChatViewController {
    
    @objc func fireRequest() {
        switch picker {
        case 0: implementAddContact()       // implement AddContact
        case 1: implementBlock()            // implement Block
        case 2: implementGetBlockedList()   // implement GetBlockedList
        case 3: implementGetContacts()      // implement GetContacts
        case 4: implementRemoveContact()    // implement RemoveContact
        case 5: implementSearchContact()    // implement SearchContact
        case 6: implementUnblock()          // implement Unblock
        case 7: implementUpdateContact()    // implement UpdateContact
            
        case 8: implementAddParticipant()   // implement AddThreadParticipants
        case 9: implementCreateThread()     // implement CreateThread
        case 10: implementCreateWithMessageThread()     // implement CreateThreadWithMessage
        case 11: implementGetHistory()      // implement GetHistory
        case 12: implementGetThreads()      // implement GetThreads
        case 13: implementGetThreadParticipants() // implement GetThreadParticipants
        case 14: implementLeaveThread()     // implement LeaveThread
        case 15: implementMuteThread()      // implement MuteThread
        case 16: implementUnmuteThread()    // implement UnmuteThread
        case 17: implementRemoveParticipant() // implement RemoveParticipant
        case 18: implementSpamThread()      // implement SpamThread
            
        case 19: implementDeleteMessage()   // implement DeletMessage
        case 20: implementEditMessage()     // implement EditMessage
        case 21: implementForwardMessage()  // implement ForwardMessage
        case 22: implementReplyTextMessage()// implement ReplyTextMessage
        case 23: implementSendTextMessage() // implement SendTextMessage
            
        default:
            print("Selected row number \(picker) that is not in the correct range!")
        }
    }
    
    // 0
    func implementAddContact() {
        var cell:       String? = nil
        var email:      String? = nil
        var firstName:  String? = nil
        var lastName:   String? = nil
        
        if let txt = input1TextField.text {
            if (txt != "") && (txt.first != " ") { cell = txt }
        }
        if let txt = input2TextField.text {
            if (txt != "") && (txt.first != " ") { email = txt }
        }
        if let txt = input3TextField.text {
            if (txt != "") && (txt.first != " ") { firstName = txt }
        }
        if let txt = input4TextField.text {
            if (txt != "") && (txt.first != " ") { lastName = txt }
        }
        
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
    
    // 1
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
    
    // 2
    func implementGetBlockedList() {
        let count:  Int?    = Int(input1TextField.text ?? "")
        let offset: Int?    = Int(input1TextField.text ?? "")
        
        let getBlockedList = GetBlockedListAutomation(count: count, offset: offset, typeCode: nil)
        getBlockedList.delegate = self
        getBlockedList.create(uniqueId: { (getBlockedListUniqueId) in
            let myText = "get blocked list unique id = \(getBlockedListUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }) { (getBlockedContactListModel) in
            let myText = "get blocked list model response = \(getBlockedContactListModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .cyan)
        }
    }
    
    // 3
    func implementGetContacts() {
        let count:  Int?    = Int(input1TextField.text ?? "")
        let offst:  Int?    = Int(input2TextField.text ?? "")
        var name:   String? = nil
        
        if let txt = input3TextField.text {
            if (txt != "") && (txt.first != " ") { name = txt }
        }
        
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
    
    // 4
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
    
    // 5
    func implementSearchContact() {
        var cellPhone:  String? = nil
        var firstName:  String? = nil
        var lastName:   String? = nil
        let id: Int?    = Int(input4TextField.text ?? "")
        
        if let cell = input1TextField.text {
            cellPhone = cell
        }
        if let first = input2TextField.text {
            firstName = first
        }
        if let last = input3TextField.text {
            lastName = last
        }
        
        let searchContact = SearchContactAutomation(cellphoneNumber: cellPhone,
                                                    email: nil,
                                                    firstName: firstName,
                                                    id: id,
                                                    lastName: lastName,
                                                    offset: nil,
                                                    size: nil,
                                                    requestUniqueId: nil)
        searchContact.delegate = self
        searchContact.create(uniqueId: { (searchContactUniqueId) in
            let myText = "searchContact unique id = \(searchContactUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }, serverResponse: { (searchContactsServerModel) in
            let myText = "search contact model server response = \(searchContactsServerModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .cyan)
        }) { (searchContactsCacheModel) in
            let myText = "search contact model cache response = \(searchContactsCacheModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .blue)
        }
        
        
    }
    
    // 6
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
    
    // 7
    func implementUpdateContact() {
        let contactId:          Int?    = Int(input1TextField.text ?? "")
        var cellPhoneNumber:    String? = nil
        var email:              String? = nil
        
        if let txt = input2TextField.text {
            if (txt != "") && (txt.first != " ") { cellPhoneNumber = txt }
        }
        if let txt = input3TextField.text {
            if (txt != "") && (txt.first != " ") { email = txt }
        }
        
        var firstName: String?  = nil
        var lastName: String?   = nil
        
        if let fullName = input4TextField.text {
            if (fullName != "") && (fullName.first != " ") {
                let str = fullName.replacingOccurrences(of: " ", with: "") // remove all spaces
                let fullnameArr = str.components(separatedBy: ",")            // seperate ids
                if let fn = fullnameArr.first {
                    firstName = fn
                }
                if let ln = fullnameArr.last {
                    lastName = ln
                }
            }
        }
        
        let updateContact = UpdateContactAutomation(cellphoneNumber: cellPhoneNumber, email: email, firstName: firstName, id: contactId, lastName: lastName)
        updateContact.delegate = self
        updateContact.create(uniqueId: { (updateContactUniqueId) in
            let myText = "update contact unique id = \(updateContactUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }) { (contactModelResponse) in
            let myText = "update contact model response = \(contactModelResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }
    }
    
    // 8
    func implementAddParticipant() {
        let threadId: Int? = Int(input1TextField.text ?? "")
        var myContacts: [Int] = []
        
        if let myContact1 = Int(input2TextField.text ?? "") {
            if (myContact1 != 0) {
                myContacts.append(myContact1)
            }
        }
        if let myContact2 = Int(input3TextField.text ?? "") {
            if (myContact2 != 0) {
                myContacts.append(myContact2)
            }
        }
        if let myContact3 = Int(input4TextField.text ?? "") {
            if (myContact3 != 0) {
                myContacts.append(myContact3)
            }
        }
        
        let addParticipant = AddParticipantAutomation(contacts: myContacts, threadId: threadId, typeCode: nil, uniqueId: nil)
        addParticipant.delegate = self
        addParticipant.create(uniqueId: { (addParticipantUniqueId) in
            let myText = "add thread participant unique id) = \(addParticipantUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }) { (addParticipantServerResponse) in
            let myText = "add thread participant unique id) = \(addParticipantServerResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .cyan)
        }
    }
    
    // 9
    func implementCreateThread() {
        var description:    String? = nil
        var title:          String? = nil
        var inviteeId:      String? = nil
        let inviteeType:    Int? = Int(input4TextField.text ?? "")
        
        if let txt = input1TextField.text {
            if (txt != "") && (txt.first != " ") { description = txt }
        }
        if let txt = input2TextField.text {
            if (txt != "") && (txt.first != " ") { title = txt }
        }
        if let txt = input3TextField.text {
            if (txt != "") && (txt.first != " ") { inviteeId = txt }
        }
        
        var invitees: [Invitee]? = nil
        if let id = inviteeId {
            switch inviteeType {
            case 1:
                invitees = [Invitee(id: id, idType: "\(InviteeVOidTypes.TO_BE_USER_SSO_ID)")]
            case 2:
                invitees = [Invitee(id: id, idType: "\(InviteeVOidTypes.TO_BE_USER_CONTACT_ID)")]
            case 3:
                invitees = [Invitee(id: id, idType: "\(InviteeVOidTypes.TO_BE_USER_CELLPHONE_NUMBER)")]
            case 4:
                invitees = [Invitee(id: id, idType: "\(InviteeVOidTypes.TO_BE_USER_USERNAME)")]
            case 0:
                invitees = [Invitee(id: id, idType: "\(InviteeVOidTypes.TO_BE_USER_ID)")]
            default:
                invitees = [Invitee(id: id, idType: "0")]
            }
            
        }
        
        let createThread = CreateThreadAutomation(description: description, image: nil, invitees: invitees, metadata: nil, title: title, type: nil, requestUniqueId: nil)
        createThread.delegate = self
        createThread.create(uniqueId: { (createThreadUniqueId, on) in
            let myText = "create thread unique id \(on) = \(createThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }) { (createThreadModel, on) in
            let myText = "create thread model response \(on) = \(createThreadModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .cyan)
        }
    }
    
    // 10
    func implementCreateWithMessageThread() {
        var textMessage:    String? = nil
        var title:          String? = nil
        var inviteeId:      String? = nil
        let inviteeType:    Int? = Int(input4TextField.text ?? "")
        
        if let txt = input1TextField.text {
            if (txt != "") && (txt.first != " ") { textMessage = txt }
        }
        if let txt = input2TextField.text {
            if (txt != "") && (txt.first != " ") { title = txt }
        }
        if let txt = input3TextField.text {
            if (txt != "") && (txt.first != " ") { inviteeId = txt }
        }
        
        var invitees: [Invitee]? = nil
        if let id = inviteeId {
            switch inviteeType {
            case 1:
                invitees = [Invitee(id: id, idType: "\(InviteeVOidTypes.TO_BE_USER_SSO_ID)")]
            case 2:
                invitees = [Invitee(id: id, idType: "\(InviteeVOidTypes.TO_BE_USER_CONTACT_ID)")]
            case 3:
                invitees = [Invitee(id: id, idType: "\(InviteeVOidTypes.TO_BE_USER_CELLPHONE_NUMBER)")]
            case 4:
                invitees = [Invitee(id: id, idType: "\(InviteeVOidTypes.TO_BE_USER_USERNAME)")]
            case 0:
                invitees = [Invitee(id: id, idType: "\(InviteeVOidTypes.TO_BE_USER_ID)")]
            default:
                invitees = [Invitee(id: id, idType: "0")]
            }
            
        }
        
        let createThtradWithMessage = CreateThreadWithMessageAutomation(description:    nil,
                                                                        image:          nil,
                                                                        invitees:       invitees,
                                                                        messageText:    textMessage,
                                                                        metadata:       nil,
                                                                        title:          title,
                                                                        type:           nil,
                                                                        requestUniqueId: nil)
        createThtradWithMessage.delegate = self
        createThtradWithMessage.create(uniqueId: { (createThreadUniqueId) in
            let myText = "create thread unique id) = \(createThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }, serverResponse: { (createThreadModel) in
            let myText = "create thread model response) = \(createThreadModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .cyan)
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
    
    // 11
    func implementGetHistory() {
        let threadId:   Int?    = Int(input1TextField.text ?? "")
        let fromTime:   UInt?   = UInt(input2TextField.text ?? "")
        let toTime:     UInt?   = UInt(input3TextField.text ?? "")
        var query:      String? = nil
        
        if let txt = input4TextField.text {
            if (txt != "") && (txt.first != " ") { query = txt }
        }
        
        let getHistory = GetHistoryAutomation(count: nil, firstMessageId: nil, fromTime: fromTime, lastMessageId: nil, messageId: nil, metadataCriteria: nil, offset: nil, order: nil, query: query, threadId: threadId, toTime: toTime, typeCode: nil, uniqueId: nil)
        getHistory.delegate = self
        getHistory.create(uniqueId: { (getHistoryUniqueId) in
            let myText = "getHistory unique id = \(getHistoryUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }, serverResponse: { (getHistoryServerModel) in
            let myText = "get thread model server response = \(getHistoryServerModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .cyan)
        }) { (getHistoryCacheModel) in
            let myText = "get thread model cache response = \(getHistoryCacheModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .blue)
        }
    }
    
    // 12
    func implementGetThreads() {
        let count:      Int?    = Int(input1TextField.text ?? "")
        let offset:     Int?    = Int(input2TextField.text ?? "")
        var name:       String? = nil
        let threadId:   Int?    = Int(input4TextField.text ?? "")
        
        if let txt = input3TextField.text {
            if (txt != "") && (txt.first != " ") { name = txt }
        }
        
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
    
    
    // 13
    func implementGetThreadParticipants() {
        let count:      Int?    = Int(input1TextField.text ?? "")
        let offset:     Int?    = Int(input2TextField.text ?? "")
        var name:       String? = nil
        let threadId:   Int?    = Int(input4TextField.text ?? "")
        
        if let txt = input3TextField.text {
            if (txt != "") && (txt.first != " ") { name = txt }
        }
        
        let getThreadParticipant = GetThreadParticipantsAutomation(count: count, firstMessageId: nil, lastMessageId: nil, name: name, offset: offset, threadId: threadId, typeCode: nil)
        getThreadParticipant.delegate = self
        getThreadParticipant.create(uniqueId: { (getThreadParticipantUniqueId) in
            let myText = "getThreadParticipant unique id = \(getThreadParticipantUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }, serverResponse: { (getThreadParticipantsModel) in
            let myText = "get thread participant model server response = \(getThreadParticipantsModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .cyan)
        }) { (getThreadParticipantsModel) in
            let myText = "get thread participant model cache response = \(getThreadParticipantsModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: .blue)
        }
    }
    
    // 14
    func implementLeaveThread() {
        let threadId: Int?  = Int(input1TextField.text ?? "")
        
        let leaveThread = LeaveThreadAutomation(threadId: threadId, typeCode: nil, requestUniqueId: nil)
        leaveThread.delegate = self
        leaveThread.create(uniqueId: { (leaveThreadUniqueId) in
            let myText = "leaveThread unique id = \(leaveThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }) { (leaveThreadServerResponse) in
            let myText = "leaveThread response = \(leaveThreadServerResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }
    }
    
    // 15
    func implementMuteThread() {
        let threadId: Int?  = Int(input1TextField.text ?? "")
        
        let muteThread = MuteThreadAutomation(threadId: threadId, typeCode: nil)
        muteThread.delegate = self
        muteThread.create(uniqueId: { (muteThreadUniqueId) in
            let myText = "muteThread unique id = \(muteThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }) { (muteThreadServerResponse) in
            let myText = "muteThread response = \(muteThreadServerResponse)"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }
    }
    
    // 16
    func implementUnmuteThread() {
        let threadId: Int?  = Int(input1TextField.text ?? "")
        
        let unmuteThread = UnmuteThreadAutomation(threadId: threadId, typeCode: nil)
        unmuteThread.delegate = self
        unmuteThread.create(uniqueId: { (unmuteThreadUniqueId) in
            let myText = "unmuteThread unique id = \(unmuteThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }) { (unmuteThreadServerResponse) in
            let myText = "unmuteThread response = \(unmuteThreadServerResponse)"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }
    }
    
    // 17
    func implementRemoveParticipant() {
        let threadId:       Int?    = Int(input1TextField.text ?? "")
        var myParticipants: [Int] = []
        
        if let myContact1 = Int(input2TextField.text ?? "") {
            if (myContact1 != 0) {
                myParticipants.append(myContact1)
            }
        }
        if let myContact2 = Int(input3TextField.text ?? "") {
            if (myContact2 != 0) {
                myParticipants.append(myContact2)
            }
        }
        if let myContact3 = Int(input4TextField.text ?? "") {
            if (myContact3 != 0) {
                myParticipants.append(myContact3)
            }
        }
        
        let removeParticipant = RemoveParticipantAutomation(content: myParticipants,
                                                            threadId: threadId,
                                                            typeCode: nil,
                                                            requestUniqueId: nil)
        removeParticipant.delegate = self
        removeParticipant.create(uniqueId: { (removeParticipantUniqueId) in
            let myText = "removeParticipant unique id = \(removeParticipantUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }) { (removeParticipantServerResponse) in
            let myText = "removeParticipant response = \(removeParticipantServerResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }
    }
    
    // 18
    func implementSpamThread() {
        let threadId: Int?  = Int(input1TextField.text ?? "")
        
        let spamThread = SpamThreadAutomation(threadId: threadId, typeCode: nil)
        spamThread.delegate = self
        spamThread.create(uniqueId: { (spamThreadUniqueId) in
            let myText = "spamThread unique id = \(spamThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }) { (spamThreadServerResponse) in
            let myText = "spamThread response = \(spamThreadServerResponse)"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }
    }
    
    // 19
    func implementDeleteMessage() {
        let subjectId:  Int?    = Int(input1TextField.text ?? "")
        
        let deleteMessage = DeleteMessageAutomation(deleteForAll: nil, subjectId: subjectId, typeCode: nil, requestUniqueId: nil)
        deleteMessage.delegate = self
        deleteMessage.create(uniqueId: { (deleteMessageUniqueId) in
            let myText = "deleteMessage unique id = \(deleteMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }) { (deleteMessageResponse) in
            let myText = "deleteMessage response = \(deleteMessageResponse)"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }
    }
    
    // 20
    func implementEditMessage() {
        var content:    String? = nil
        let subjectId:  Int?    = Int(input2TextField.text ?? "")
        let repliedId:  Int?    = Int(input3TextField.text ?? "")
        
        if let txt = input1TextField.text {
            if (txt != "") && (txt.first != " ") { content = txt }
        }
        
        let editMessage = EditMessageAutomation(content: content, metaData: nil, repliedTo: repliedId, subjectId: subjectId, typeCode: nil, requestUniqueId: nil)
        editMessage.delegate = self
        editMessage.create(uniqueId: { (editMessageUniqueId) in
            let myText = "editMessage unique id = \(editMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }) { (editMessageResponse) in
            let myText = "editMessage response = \(editMessageResponse)"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }
    }
    
    // 21
    func implementForwardMessage() {
        
        var messageIds: [Int]?
        if let msgIdsTxt = input1TextField.text {
            let str = msgIdsTxt.replacingOccurrences(of: " ", with: "") // remove all spaces
            let stringIds = str.components(separatedBy: ",")            // seperate ids
            messageIds = []
            if (stringIds.first != nil) && (stringIds.first != "") {
                for item in stringIds {
                    messageIds?.append(Int(item)!)
                }
            }
        }
        
        let subjectId:  Int?    = Int(input2TextField.text ?? "")
        let repliedTo:  Int?    = Int(input3TextField.text ?? "")
        
        let forwardMessage = ForwardMessageAutomation(messageIds: messageIds, metaData: nil, repliedTo: repliedTo, subjectId: subjectId, typeCode: nil, uniqueId: nil)
        forwardMessage.delegate = self
        forwardMessage.create(uniqueId: { (forwardMessageUniqueId) in
            let myText = "forwardMessage unique id = \(forwardMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }, serverSentResponse: { (sent) in
            let myText = "forwardMessage sent response = \(sent)"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }, serverDeliverResponse: { (deliver) in
            let myText = "forwardMessage deliver response = \(deliver)"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }) { (seen) in
            let myText = "forwardMessage seen response = \(seen)"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }
    }
    
    // 22
    func implementReplyTextMessage() {
        var content:    String? = nil
        let repliedTo:  Int?    = Int(input2TextField.text ?? "")
        let subjectId:  Int?    = Int(input3TextField.text ?? "")
        
        if let txt = input1TextField.text {
            if (txt != "") && (txt.first != " ") { content = txt }
        }
        
        let replyMessage = ReplyMessageAutomation(content: content, metaData: nil, repliedTo: repliedTo, subjectId: subjectId, typeCode: nil, uniqueId: nil)
        replyMessage.delegate = self
        replyMessage.create(uniqueId: { (replyMessageUniqueId) in
            let myText = "replyTextMessage unique id = \(replyMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: .cyan)
        }, serverSentResponse: { (sent) in
            let myText = "replyTextMessage sent response = \(sent)"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }, serverDeliverResponse: { (deliver) in
            let myText = "replyTextMessage deliver response = \(deliver)"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }) { (seen) in
            let myText = "replyTextMessage seen response = \(seen)"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: .cyan)
        }
    }
    
    // 23
    func implementSendTextMessage() {
        var content:    String? = nil
        let repliedTo:  Int?    = Int(input2TextField.text ?? "")
        let threadId:   Int?    = Int(input3TextField.text ?? "")
        
        if let txt = input1TextField.text {
            if (txt != "") && (txt.first != " ") { content = txt }
        }
        
        let sendTextMessage = SendTextMessageAutomation(content: content, metaData: nil, repliedTo: repliedTo, systemMetadata: nil, threadId: threadId, typeCode: nil, uniqueId: nil)
        sendTextMessage.delegate = self
        sendTextMessage.create(uniqueId: { (sendTextMessageUniqueId) in
            let myText = "sendTextMessage unique id = \(sendTextMessageUniqueId)"
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
extension MyChatViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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












