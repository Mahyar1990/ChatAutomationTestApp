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
    let pickerData          = ["block", "getContacts", "addContact", "removeContact", "createThread"]
    
    
    let tokenTextField: UITextField = {
        let mt = UITextField()
        mt.translatesAutoresizingMaskIntoConstraints = false
        mt.placeholder = "write your token..."
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    
    @objc func connectChat() {
        if (tokenTextField.text?.count)! > 30 {
            print("my token is : \(tokenTextField.text)")
            token = tokenTextField.text!
            createChat()
        } else {
            // error! Please inter your token
            token = "f76cf19e50894e899e76ab9fdcde7b78"
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
        
        switch row {
        case 0:
            // implement block automation
            let block = BlockAutomation(contactId: nil, threadId: nil, typeCode: nil, userId: nil)
            block.delegate = self
            block.create(uniqueId: { (blockUniqueId) in
                let myText = "block uniqueId = \(blockUniqueId)"
                self.addtext(text: myText)
                self.logHeightArr.append(40)
                self.logBackgroundColor.append(UIColor.cyan)
                print(myText)
            }) { (blockedContactModel) in
                let myText = "block response = \(blockedContactModel.returnDataAsJSON())"
                self.addtext(text: myText)
                self.logHeightArr.append(140)
                self.logBackgroundColor.append(UIColor.cyan)
                print(myText)
            }
        case 1:
            // implement getContact automation
            let getContact = GetContactsAutomation(count: nil, name: nil, offset: nil, typeCode: nil)
            getContact.delegate = self
            getContact.create(uniqueId: { (getContactUniqueId) in
                let myText = "get contact unique id = \(getContactUniqueId)"
                self.addtext(text: myText)
                self.logHeightArr.append(40)
                self.logBackgroundColor.append(UIColor.cyan)
                print(myText)
            }, serverResponse: { (getContactsModel) in
                let myText = "get contact model server response = \(getContactsModel.returnDataAsJSON())"
                self.addtext(text: myText)
                self.logHeightArr.append(140)
                self.logBackgroundColor.append(UIColor.cyan)
                print(myText)
            }) { (getContactsModel) in
                let myText = "get contact model cache response = \(getContactsModel.returnDataAsJSON())"
                self.addtext(text: myText)
                self.logHeightArr.append(140)
                self.logBackgroundColor.append(UIColor.blue)
                print(myText)
            }
        case 2:
            // implement addContact automation
            let addContact = AddContactAutomation(cellphoneNumber: nil, email: nil, firstName: nil, lastName: nil)
            addContact.delegate = self
            addContact.create(uniqueId: { (addContactUniqueId) in
                let myText = "add contact unique id = \(addContactUniqueId)"
                self.addtext(text: myText)
                self.logHeightArr.append(40)
                self.logBackgroundColor.append(UIColor.cyan)
                print(myText)
            }) { (addContactModel) in
                let myText = "add contact model response = \(addContactModel.returnDataAsJSON())"
                self.addtext(text: myText)
                self.logHeightArr.append(140)
                self.logBackgroundColor.append(UIColor.cyan)
                print(myText)
            }
        case 3:
            // implement removeContact automation
            let removeContact = RemoveContactAutomation(id: nil)
            removeContact.delegate = self
            removeContact.create(uniqueId: { (removeContactUniqueId) in
                let myText = "remove contact unique id = \(removeContactUniqueId)"
                self.addtext(text: myText)
                self.logHeightArr.append(40)
                self.logBackgroundColor.append(UIColor.cyan)
                print(myText)
            }) { (removeContactModel) in
                let myText = "remove contact model response = \(removeContactModel.returnDataAsJSON())"
                self.addtext(text: myText)
                self.logHeightArr.append(120)
                self.logBackgroundColor.append(UIColor.cyan)
                print(myText)
            }
        case 4:
            // impelement createThread automation
            let createThread = CreateThreadAutomation(description: nil, image: nil, invitees: nil, metadata: nil, title: nil, type: nil, requestUniqueId: nil)
            createThread.delegate = self
            createThread.create(uniqueId: { (createThreadUniqueId, on) in
                let myText = "create thread unique id \(on) = \(createThreadUniqueId)"
                self.addtext(text: myText)
                self.logHeightArr.append(65)
                self.logBackgroundColor.append(UIColor.cyan)
                print(myText)
            }) { (createThreadModel, on) in
                let myText = "create thread model response \(on) = \(createThreadModel.returnDataAsJSON())"
                self.addtext(text: myText)
                self.logHeightArr.append(140)
                self.logBackgroundColor.append(UIColor.cyan)
                print(myText)
            }
        default:
            print("Selected row number \(row) that is not in the correct range!")
        }
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
    case Block          = "Block"
    case GetContact     = "GetContact"
    case AddContact     = "AddContact"
    case RemoveContact  = "RemoveContact"
    case CreateThread   = "CreateThread"
}










