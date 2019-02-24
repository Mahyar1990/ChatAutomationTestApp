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

class MyViewController: UIViewController {
    
    var myChatObject: Chat?
    
    
    var chatIsReady = false
    
// SandBox Addresses:
//    let socketAddress           = "wss://chat-sandbox.pod.land/ws"
//    let serverName              = "chat-server"
//    let ssoHost                 = "https://accounts.pod.land"
//    let platformHost            = "https://sandbox.pod.land:8043/srv/basic-platform"    // {**REQUIRED**} Platform Core Address
//    let fileServer              = "http://sandbox.fanapium.com:8080"                    // {**REQUIRED**} File Server Address
//    let token                   = "c850d7b7b1af4b53a14d53e03d5b7289"
    
    
// Local Addresses
    let socketAddress           = "ws://172.16.106.26:8003/ws"
    let serverName              = "chat-server"
    let ssoHost                 = "http://172.16.110.76"
    let platformHost            = "http://172.16.106.26:8080/hamsam"    // {**REQUIRED**} Platform Core Address
    let fileServer              = "http://172.16.106.26:8080/hamsam"    // {**REQUIRED**} File Server Address
    let token                   = "7a18deb4a4b64339a81056089f5e5922"    // ialexi
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
    let pickerData          = ["getUserInfo", "getContacts", "addContact", "removeContact", "block", "unblock", "getBlockList", "sendTextMessage", "sendFileMessage", "sendReplyMessage", "sendForwardMessage", "sendLocationMessage"]
    
    let pickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.backgroundColor = UIColor(white: 0.8, alpha: 0.8)
        
        return pv
    }()
    
    let sendPingButton: UIButton = {
        let mb = UIButton()
        mb.translatesAutoresizingMaskIntoConstraints = false
        mb.setTitle("Fire...", for: UIControl.State.normal)
        mb.backgroundColor = UIColor(red: 0, green: 150/255, blue: 200/255, alpha: 1.0)
        mb.layer.cornerRadius = 5
        mb.layer.borderWidth = 2
        mb.layer.borderColor = UIColor.clear.cgColor
        mb.layer.shadowColor = UIColor(red: 0, green: 100/255, blue: 110/255, alpha: 1.0).cgColor
        mb.layer.shadowOpacity = 2
        mb.layer.shadowRadius = 1
        mb.layer.shadowOffset = CGSize(width: 0, height: 3)
//        mb.addTarget(self, action: #selector(fireTheAction), for: UIControlEvents.touchUpInside)
        return mb
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




extension MyViewController {
    
    /*
     if somebody call this method,
     a getContacts request will send
     if the callers did't send input parameters, inputs will fill qoutomatically by this parameters:
     - count: will be some number between 0 and 50
     - offset: will be some number between 0 and 50
     */
    func getContacts(count: Int?, name: String?, offset: Int?, typeCode: String?,
                     uniqueId:          @escaping (String)->(),
                     serverResponse:    @escaping (GetContactsModel) -> (),
                     cacheResponse:     @escaping (GetContactsModel) -> ()) {
        
        func sendRequest(theCount: Int?, theName: String?, theOffset: Int?, theTypeCode: String?) {
            let getContactInput = GetContactsRequestModel(count: theCount, name: theName, offset: theOffset, typeCode: theTypeCode)
            myChatObject?.getContacts(getContactsInput: getContactInput, uniqueId: { (getContactUniqueId) in
                uniqueId(getContactUniqueId)
            }, completion: { (getContactsResponse) in
                serverResponse(getContactsResponse as! GetContactsModel)
            }, cacheResponse: { (getContactsCacheResponse) in
                cacheResponse(getContactsCacheResponse)
            })
        }
        
        // if none of the parameters filled by the user, jenerate fake values and fill the input model to send request
        if (count == nil) && (name == nil) && (offset == nil) {
            let fakeParams = generateFakeGetContactParams()
            sendRequest(theCount: fakeParams.0, theName: name, theOffset: fakeParams.1, theTypeCode: typeCode)
        }
        // some or all of the parameters are filled by the client, so send request with this params
        else {
            sendRequest(theCount: count, theName: name, theOffset: offset, theTypeCode: typeCode)
        }
        
        
    }
    
    
    /*
     if somebody call this method,
     a addContact request will send
     if the callers did't send input parameters, inputs will fill qoutomatically by this parameters:
     - cellphoneNumber: will a String with 11 characters
     - firstName:       will a String with 4 characters
     - lastName:        will a String with 7 characters
     - email:           will a email by using firstName and lastName that gererated before
     */
    func addContact(cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?,
                    uniqueId:       @escaping (String) -> (),
                    serverResponse: @escaping (ContactModel) -> ()) {
        
        func sendRequest(theCellphoneNumber: String?, theEmail: String?, theFirstName: String?, theLastName: String?) {
            let addContactInput = AddContactsRequestModel(cellphoneNumber: theCellphoneNumber, email: theEmail, firstName: theFirstName, lastName: theLastName)
            myChatObject?.addContact(addContactsInput: addContactInput, uniqueId: { (addContactsUniqueId) in
                uniqueId(addContactsUniqueId)
            }, completion: { (addContactServerResponse) in
                serverResponse(addContactServerResponse as! ContactModel)
            })
        }
        
        // if none of the parameters filled by the user, jenerate fake values and fill the input model to send request
        if (cellphoneNumber == nil) && (email == nil) && (firstName == nil) && (lastName == nil) {
            let fakeParams = generateFakeAddContactParams(cellphoneLength: 11, firstNameLength: 4, lastNameLength: 7)
            sendRequest(theCellphoneNumber: fakeParams.0, theEmail: fakeParams.1, theFirstName: fakeParams.2, theLastName: fakeParams.3)
        }
        // some or all of the parameters are filled by the client, so send request with this params
        else {
            sendRequest(theCellphoneNumber: cellphoneNumber, theEmail: email, theFirstName: firstName, theLastName: lastName)
        }
        
        
    }
    
    
    /*
     if somebody call this method,
     a removeContact request will send
     if the caller of this function filled the id of the contact that it wants to remove, removeContact request will send.
     but if the callers did't send input parameter, it means the caller want's to just test the removeContact functionality
     so the senario will be:
     first addContact by using addContact function that will generate some parameters to add a contact
     when the response of the addContact comes from server,
     we will send removeContact request by using the id of the new contact that we created earlier.
     */
    func removeContact(id:              Int?,
                       uniqueId:        @escaping (String) -> (),
                       serverResponse:  @escaping (RemoveContactModel) -> ()) {
        
        func sendRequest(theId: Int) {
            let removeContactInput = RemoveContactsRequestModel(id: theId)
            myChatObject?.removeContact(removeContactsInput: removeContactInput, uniqueId: { (removeContactUniqueId) in
                uniqueId(removeContactUniqueId)
            }, completion: { (removeContactServerResponse) in
                serverResponse(removeContactServerResponse as! RemoveContactModel)
            })
        }
        
        // the parameter is filled by the client, so send request with this params
        if let contactId = id {
            sendRequest(theId: contactId)
        }
            // if the input parameter didn't filled by the user, first create a contact, then remove it
        else {
            addContact(cellphoneNumber: nil, email: nil, firstName: nil, lastName: nil, uniqueId: { _ in }) { (contactModel) in
                if let myContact = contactModel.contacts.first {
                    if let contactId = myContact.id {
                        sendRequest(theId: contactId)
                    } else {
                        // handle error that didn't get contactId in the contact model
                    }
                } else {
                    // handle error that didn't get Contact Model
                }
            }
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func generateFakeGetContactParams() -> (Int?, Int?) {
        let count:  Int?
        let offset: Int?
        
        count   = generateNumberAsInt(from: 1, to: 50)
        offset  = generateNumberAsInt(from: 0, to: 50)
        
        return (count!, offset!)
    }
    
    
    func generateFakeAddContactParams(cellphoneLength: Int?, firstNameLength: Int?, lastNameLength: Int?) -> (String?, String?, String?, String?) {
        let cellphoneNumber: String?
        let email:          String?
        let firstName:      String?
        let lastName:       String?
        
        cellphoneNumber = generateNumberAsString(withLength: cellphoneLength ?? 11)
        firstName       = generateNameAsString(withLength: firstNameLength ?? 4)
        lastName        = generateNameAsString(withLength: lastNameLength ?? 7)
        email           = generateEmailAsString(withName: "\(firstName!).\(lastName!)", withoutNameWithLength: 8)
        
        return (cellphoneNumber!, email!, firstName!, lastName!)
    }
    
    
    
    
    
    
    
    
    func generateNameAsString(withLength length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
    
    func generateNumberAsString(withLength length: Int) -> String {
        let letters = "0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
    
    func generateEmailAsString(withName: String?, withoutNameWithLength length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let atSighn = String((0...4).map{ _ in letters.randomElement()! })
        let dot     = String((0...2).map{ _ in letters.randomElement()! })
        var emailName = ""
        if let name = withName {
            emailName = name
        } else {
            emailName = String((0...length-1).map{ _ in letters.randomElement()! })
        }
        return emailName + "@" + atSighn + "." + dot
    }
    
    func generateNumberAsInt(from: Int, to: Int) -> Int {
        return Int.random(in: from ... to)
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
























