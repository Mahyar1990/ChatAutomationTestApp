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
//import PodChat

//var myChatObject: Chat?

class MyChatViewController: UIViewController {
    
    var chatIsReady = false
/*
https://accounts.pod.land/oauth2/authorize/index.html?client_id=2051121e4348af52664cf7de0bda&response_type=token&redirect_uri=https://chat.fanapsoft.ir&scope=profile social:write
*/


// Main Addresses
    
//    var socketAddress   = "wss://msg.pod.ir/ws"
//    var ssoHost         = "https://accounts.pod.ir"
//    var platformHost    = "https://api.pod.ir/srv/core"
//    var fileServer      = "https://core.pod.ir"
//    var serverName      = "chat-server"
    
//    var socketAddress   = "wss://msg.pod.ir/ws"
//    var ssoHost         = "https://accounts.pod.ir"
//    var platformHost    = "https://api.pod.ir/srv/core"
//    var fileServer      = "https://core.pod.ir"
//    var serverName      = "chat-server"
    
    
// SandBox Addresses:
    
    var socketAddress           = "wss://chat-sandbox.pod.ir/ws"
    var serverName              = "chat-server"
    var ssoHost                 = "https://accounts.pod.ir"
    var platformHost            = "https://sandbox.pod.ir:8043/srv/basic-platform"    // {**REQUIRED**} Platform Core Address
    var fileServer              = "http://sandbox.fanapium.com:8080"                    // {**REQUIRED**} File Server Address
    var token                   = "cbd589cda67e46509aa99473e47fceec"
    
//    var socketAddress           = "wss://chat-sandbox.pod.ir/ws"
//    var serverName              = "chat-server"
//    var ssoHost                 = "https://accounts.pod.ir"
//    var platformHost            = "https://sandbox.pod.ir:8043/srv/basic-platform"    // {**REQUIRED**} Platform Core Address
//    var fileServer              = "http://sandbox.fanapium.com:8080"                    // {**REQUIRED**} File Server Address
//    var token                   = "4bf211c541ae4b1982ed4798f0f73b59"
    
    // Integration Adresses:
//    var socketAddress           = "ws://172.16.110.235:8003/ws"
//    var ssoHost                 = "http://172.16.110.76"
//    var platformHost            = "http://172.16.110.235:8003/srv/bptest-core"
//    var fileServer              = "http://172.16.110.76:8080"
//    var serverName              = "chatlocal"
    
// Local Addresses 1 (MehrAra)
//    var socketAddress           = "ws://172.16.106.26:8003/ws"
//    var serverName              = "chat-server"
//    var platformHost            = "http://172.16.106.26:8080/hamsam"    // {**REQUIRED**} Platform Core Address
//    var ssoHost                 = "http://172.16.110.76"
//    var fileServer              = "http://172.16.106.26:8080/hamsam"    // {**REQUIRED**} File Server Address
    
    
// Local Addresses 2 (SheikhHosseini)
//    var socketAddress           = "ws://172.16.110.131:8003/ws"
//    var serverName              = "chat-server2"
//    var platformHost            = "http://172.16.110.131:8080"
//    var ssoHost                 = "http://172.16.110.76"
//    var fileServer              = "http://172.16.106.26:8080/hamsam"    // {**REQUIRED**} File Server Address
    
    
// Integration Tokens:
//    var token = "f19933ae1b1e424db9965a243bf3bcd3" // SSO Token ZiZi
//    var token = "81025b3fbc1a4f7184c3600a2f874673" // SSO Token JiJi
//    var token = "3c4d62b6068043aa898cf7426d5cae68" // SSO Token FiFi
    
// Local Tokens:
//    var token                   = "fbd4ecedb898426394646e65c6b1d5d1"    // JiJi
//    var token                   = "7cba09ff83554fc98726430c30afcfc6"    // ZiZi
//    var token                   = "7a18deb4a4b64339a81056089f5e5922"    // ialexi
//    let token                   = "6421ecebd40b4d09923bcf6379663d87"    // iFelfeli
//    let token                   = "5fb88da4c6914d07a501a76d68a62363"    // FiFi
//    let token                   = "bebc31c4ead6458c90b607496dae25c6"    // Alexi
//    let token                   = "e4f1d5da7b254d9381d0487387eabb0a"    // Felfeli
    
    
    let wsConnectionWaitTime    = 1                 // Time out to wait for socket to get ready after open
    let connectionRetryInterval = 5                 // Time interval to retry registering device or registering server
    let connectionCheckTimeout  = 10                // Socket connection live time on server
    let messageTtl              = 86400             // Message time to live
    let reconnectOnClose        = true              // auto connect to socket after socket close
    
    
    
    let cellId              = "cellId"
    let uploadCellId        = "uploadCellId"
    var logArr              = [String]()
    var logHeightArr        = [Int]()
    var logBackgroundColor  = [UIColor]()
    
    let pickerDataCollection = ["Contact", "Thread", "Message", "Location", "File"]
    let pickerDataContact = ["AddContact", "Block", "GetBlockedList", "GetContacts", "RemoveContact", "SearchContact", "Unblock", "UpdateContact"]
    let pickerDataThread = ["AddAdmin", "AddAuditor", "AddParticipants", "ClearHistory", "CreateThread", "CreateThreadWithMessage", "CreateThreadWithFileMessage", "GetAdmins", "GetHistory", "GetThread", "GetThreadParticipants", "LeaveThread", "MuteThread", "UnmuteThread", "RemoveAdmin", "RemoveAuditor", "RemoveParticipant", "SpamThread", "CurrentUserRoles", "IsNameAvailable"]
    let pickerDataMessgae = ["DeleteMessage", "DeleteMultipleMessage", "EditMessage", "ForwardMessage", "MessageDeliveryList" ,"MessageSeenList", "PinMessage", "UnpinMessage", "ReplyTextMessage", "SendTextMessage", "SendBotMessage"]
    let pickerDataLocation = ["SendLocationMessage"]
    let pickerDataFile = ["ReplyFileMessage", "SendFileMessage", "UploadFile", "UploadImage"]
    
    
    var uploadImageUniqueId:    String = ""
    var uploadFileUniqueId:     String = ""
    var downloadFileUniqueId:   String = ""
    var isProgressActive = false
    var progressCell = -1
    var myProgress: Float = 0.0 {
        didSet {
            if progressCell >= 0 {
                let cellIndexPath = IndexPath(item: progressCell, section: 0)
                if let cell = myLogCollectionView.cellForItem(at: cellIndexPath) as? MyCollectionViewUploadCell {
                    cell.spaceProgressView.progress = myProgress
                }
            }
            //            spaceProgressView.progress = myProgress
        }
    }
    
    var section = 0
    var picker = 0
    
    
    /*
    let spaceProgressView: UIProgressView = {
        let pv = UIProgressView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.progressTintColor = UIColor.blue
        pv.trackTintColor = UIColor.gray
        pv.layer.cornerRadius = 4
        pv.layer.borderWidth = 2
        pv.layer.borderColor = UIColor.white.cgColor
        pv.clipsToBounds = true
        pv.progress = 0.0
        return pv
    }()
    let cancelUploadButton: UIButton = {
        let mb = UIButton()
        mb.translatesAutoresizingMaskIntoConstraints = false
        mb.setTitle("Cancel", for: UIControl.State.normal)
        mb.backgroundColor = UIColor(red: 0, green: 150/255, blue: 200/255, alpha: 1.0)
        mb.layer.cornerRadius = 5
        mb.layer.borderWidth = 1
        mb.layer.borderColor = UIColor.clear.cgColor
        mb.layer.shadowColor = UIColor(red: 0, green: 100/255, blue: 110/255, alpha: 1.0).cgColor
        mb.layer.shadowOpacity = 1
        mb.layer.shadowRadius = 1
        mb.layer.shadowOffset = CGSize(width: 0, height: 3)
        mb.addTarget(self, action: #selector(cancelUpload), for: UIControl.Event.touchUpInside)
        return mb
    }()
    let pauseUploadButton: UIButton = {
        let mb = UIButton()
        mb.translatesAutoresizingMaskIntoConstraints = false
        mb.setTitle("Pause", for: UIControl.State.normal)
        mb.backgroundColor = UIColor(red: 0, green: 150/255, blue: 200/255, alpha: 1.0)
        mb.layer.cornerRadius = 5
        mb.layer.borderWidth = 1
        mb.layer.borderColor = UIColor.clear.cgColor
        mb.layer.shadowColor = UIColor(red: 0, green: 100/255, blue: 110/255, alpha: 1.0).cgColor
        mb.layer.shadowOpacity = 1
        mb.layer.shadowRadius = 1
        mb.layer.shadowOffset = CGSize(width: 0, height: 3)
        mb.addTarget(self, action: #selector(pauseUpload), for: UIControl.Event.touchUpInside)
        return mb
    }()
    */
    
    let input1TextField = MZInputTextField()
    let input2TextField = MZInputTextField()
    let input3TextField = MZInputTextField()
    let input4TextField = MZInputTextField()
    let input5TextField = MZInputTextField()
    let input6TextField = MZInputTextField()
    let input7TextField = MZInputTextField()
    let input8TextField = MZInputTextField()
    let pickerView = MZPickerView()
    let logView = MZLogView()
    let myLogCollectionView = MZCollectionView()
    let runButton: MZRunButton = {
        let bt = MZRunButton()
        bt.addTarget(self, action: #selector(fireRequest), for: UIControl.Event.touchUpInside)
        return bt
    }()
    var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
    let pickerController = UIImagePickerController()
    var theAlert = UIAlertController(title: "پارامترهای خواسته شده را به ترتیب وارد کنید", message: "\n socketAddress, \n serverName, \n ssoHost, \n platformHost, \n fileServer, \n token", preferredStyle: .alert)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Choose  ->  fill parameters  ->  Run"
        showAlert()
        setupViews()
    }
    
    
    func showAlert() {
        
        theAlert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "socketAddress"
            textField.text = self.socketAddress
        })
        theAlert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "serverName"
            textField.text = self.serverName
        })
        theAlert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "ssoHost"
            textField.text = self.ssoHost
        })
        theAlert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "platformHost"
            textField.text = self.platformHost
        })
        theAlert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "fileServer"
            textField.text = self.fileServer
        })
        theAlert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "token"
            textField.text = self.token
        })
        
        let textFieldAction = UIAlertAction(title: "تایید", style: .default, handler: { (action) -> Void in
            let textField0 = self.theAlert.textFields![0]
            let textField1 = self.theAlert.textFields![1]
            let textField2 = self.theAlert.textFields![2]
            let textField3 = self.theAlert.textFields![3]
            let textField4 = self.theAlert.textFields![4]
            let textField5 = self.theAlert.textFields![5]
            if let usersocketAddress = textField0.text {
                self.socketAddress = usersocketAddress
            }
            if let userserverName = textField1.text {
                self.serverName = userserverName
            }
            if let userssoHost = textField2.text {
                self.ssoHost = userssoHost
            }
            if let userplatformHost = textField3.text {
                self.platformHost = userplatformHost
            }
            if let userfileServer = textField4.text {
                self.fileServer = userfileServer
            }
            if let userToken = textField5.text {
                self.token = userToken
            }
            
            self.createChat()
            
        })
        
        self.theAlert.addAction(textFieldAction)
        self.present(self.theAlert, animated: true, completion: nil)
    }
    
    
    func createChat() {
        // create Chat object
        Chat.sharedInstance.createChatObject(socketAddress:         socketAddress,
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
                                            maxReconnectTimeInterval: nil,
                                            reconnectOnClose:       true,
                                            localImageCustomPath:   nil,
                                            localFileCustomPath:    nil,
                                            deviecLimitationSpaceMB: 100)
        
        Chat.sharedInstance.delegate = self
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.activityIndicator.startAnimating()
        
        Chat.sharedInstance.deleteCache()
    }
    
    
    @objc func cancelUpload() {
        updateText(cellText: "user tries to Cancel Upload/Download!", cellHeight: 40, cellColor: .gray)
        if uploadImageUniqueId != "" {
            Chat.sharedInstance.manageUpload(image: true, file: false, withUniqueId: uploadImageUniqueId, withAction: DownloaUploadAction.cancel, completion: { (message, state) in
                self.logBackgroundColor.append(UIColor.gray)
                self.logHeightArr.append(40)
                self.addtext(text: message)
            })
        } else if uploadFileUniqueId != "" {
            Chat.sharedInstance.manageUpload(image: false, file: true, withUniqueId: uploadFileUniqueId, withAction: DownloaUploadAction.cancel, completion: { (message, state) in
                self.logBackgroundColor.append(UIColor.gray)
                self.logHeightArr.append(40)
                self.addtext(text: message)
            })
        } else if downloadFileUniqueId != "" {
            Chat.sharedInstance.manageUpload(image: false, file: true, withUniqueId: downloadFileUniqueId, withAction: DownloaUploadAction.cancel, completion: { (message, state) in
                self.logBackgroundColor.append(UIColor.gray)
                self.logHeightArr.append(40)
                self.addtext(text: message)
            })
        }
    }
    
    
    @objc func pauseUpload() {
        if progressCell >= 0 {
            let cellIndexPath = IndexPath(item: progressCell, section: 0)
            if let cell = myLogCollectionView.cellForItem(at: cellIndexPath) as? MyCollectionViewUploadCell {
                
                if (cell.pauseUploadButton.titleLabel?.text == "Pause") {
                    cell.pauseUploadButton.setTitle("Resume", for: UIControl.State.normal)
                    updateText(cellText: "user tries to Pause the Upload/Download", cellHeight: 40, cellColor: .gray)
                    if uploadImageUniqueId != "" {
                        Chat.sharedInstance.manageUpload(image: true, file: false, withUniqueId: uploadImageUniqueId, withAction: DownloaUploadAction.suspend, completion: { (message, state) in
                            self.logBackgroundColor.append(UIColor.gray)
                            self.logHeightArr.append(40)
                            self.addtext(text: message)
                        })
                    } else if uploadFileUniqueId != "" {
                        Chat.sharedInstance.manageUpload(image: false, file: true, withUniqueId: uploadFileUniqueId, withAction: DownloaUploadAction.suspend, completion: { (message, state) in
                            self.logBackgroundColor.append(UIColor.gray)
                            self.logHeightArr.append(40)
                            self.addtext(text: message)
                        })
                    } else if downloadFileUniqueId != "" {
                        Chat.sharedInstance.manageUpload(image: false, file: true, withUniqueId: downloadFileUniqueId, withAction: DownloaUploadAction.suspend, completion: { (message, state) in
                            self.logBackgroundColor.append(UIColor.gray)
                            self.logHeightArr.append(40)
                            self.addtext(text: message)
                        })
                    }
                } else {
                    updateText(cellText: "user tries to Resume the Upload/Download", cellHeight: 40, cellColor: .gray)
                    if uploadImageUniqueId != "" {
                        Chat.sharedInstance.manageUpload(image: true, file: false, withUniqueId: uploadImageUniqueId, withAction: DownloaUploadAction.resume, completion: { (message, state) in
                            self.logBackgroundColor.append(UIColor.gray)
                            self.logHeightArr.append(40)
                            self.addtext(text: message)
                        })
                    } else if uploadFileUniqueId != "" {
                        Chat.sharedInstance.manageUpload(image: false, file: true, withUniqueId: uploadFileUniqueId, withAction: DownloaUploadAction.resume, completion: { (message, state) in
                            self.logBackgroundColor.append(UIColor.gray)
                            self.logHeightArr.append(40)
                            self.addtext(text: message)
                        })
                    } else if downloadFileUniqueId != "" {
                        Chat.sharedInstance.manageUpload(image: false, file: true, withUniqueId: downloadFileUniqueId, withAction: DownloaUploadAction.resume, completion: { (message, state) in
                            self.logBackgroundColor.append(UIColor.gray)
                            self.logHeightArr.append(40)
                            self.addtext(text: message)
                        })
                    }
                    cell.pauseUploadButton.setTitle("Pause", for: UIControl.State.normal)
                }
                
            }
        }
        
    }
    
    // write down senarios
    
    
}




extension MyChatViewController: MoreInfoDelegate {
    
    func newInfo(type: String, message: String, lineNumbers: Int) {
        self.logBackgroundColor.append(UIColor.init().hexToRGB(hex: "#ffeaa7", alpha: 1))
        self.logHeightArr.append(30 + (lineNumbers * 20))
        self.addtext(text: "inside \(type):\n\(message)")
    }
    
}





// MARK: UIPickerView methods
extension MyChatViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return pickerDataCollection.count
        } else {
            switch pickerView.selectedRow(inComponent: 0) {
            case 0: return pickerDataContact.count
            case 1: return pickerDataThread.count
            case 2: return pickerDataMessgae.count
            case 3: return pickerDataLocation.count
            case 4: return pickerDataFile.count
            default:
                return 2
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return pickerDataCollection[row]
        } else {
            switch pickerView.selectedRow(inComponent: 0) {
            case 0: return pickerDataContact[row]
            case 1: return pickerDataThread[row]
            case 2: return pickerDataMessgae[row]
            case 3: return pickerDataLocation[row]
            case 4: return pickerDataFile[row]
            default:
                return ""
            }
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if (component == 0) {
            return CGFloat(pickerView.frame.width / 3)
        } else {
            return CGFloat(pickerView.frame.width / 3 * 2)
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("row at index \(row) did selected")
        
        resetCollectionViewCells()
        resetTextFields()
        
        if (component == 0) {
            switch row {
            case 0:     setPlaceHolderText(Input1: "phoneNumber", Input2: "email", Input3: "firstName", Input4: "lastName", Input5: "", Input6: "", Input7: "", Input8: "")
            case 1:     setPlaceHolderText(Input1: "threadId", Input2: "userId", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case 2:     setPlaceHolderText(Input1: "subjectId", Input2: "", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case 3:     setPlaceHolderText(Input1: "lat", Input2: "lon", Input3: "threadId", Input4: "message", Input5: "", Input6: "", Input7: "", Input8: "")
            case 4:     setPlaceHolderText(Input1: "fileName", Input2: "message", Input3: "repliedTo", Input4: "threadId", Input5: "", Input6: "", Input7: "", Input8: "")
            default:    print("Selected row number \(row) that is not in the correct range!")
            }
            section = row
            picker = 0
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            
        } else {
            picker = row
            switch (section, row) {
            // Contact Managements
            case (0, 0):    setPlaceHolderText(Input1: "phoneNumber", Input2: "email", Input3: "firstName", Input4: "lastName", Input5: "", Input6: "", Input7: "", Input8: "")
            case (0, 1):    setPlaceHolderText(Input1: "contactId", Input2: "threadId", Input3: "userId", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (0, 2):    setPlaceHolderText(Input1: "count", Input2: "offset", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (0, 3):    setPlaceHolderText(Input1: "count", Input2: "offset", Input3: "name", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (0, 4):    setPlaceHolderText(Input1: "id", Input2: "", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (0, 5):    setPlaceHolderText(Input1: "PhoneNumner", Input2: "firstName", Input3: "lastName", Input4: "id", Input5: "email", Input6: "offset", Input7: "count", Input8: "")
            case (0, 6):    setPlaceHolderText(Input1: "blockId", Input2: "contactId", Input3: "threadId", Input4: "userId", Input5: "", Input6: "", Input7: "", Input8: "")
            case (0, 7):    setPlaceHolderText(Input1: "contactId", Input2: "phoneNumber", Input3: "email", Input4: "firstname", Input5: "lastName", Input6: "", Input7: "", Input8: "")

            // Thread Managements
            case (1, 0):    setPlaceHolderText(Input1: "threadId", Input2: "userId", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (1, 1):    setPlaceHolderText(Input1: "threadId", Input2: "userId", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (1, 2):    setPlaceHolderText(Input1: "threadId", Input2: "ContactId", Input3: "ContactId", Input4: "ContactId", Input5: "", Input6: "", Input7: "", Input8: "")
            case (1, 3):    setPlaceHolderText(Input1: "threadId", Input2: "", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (1, 4):    setPlaceHolderText(Input1: "description", Input2: "title", Input3: "inviteeId", Input4: "inviteeType", Input5: "image", Input6: "metadata", Input7: "", Input8: "")
                            updateText(cellText: "inviteeType: \n 0 = TO_BE_USER_ID \n 1 = TO_BE_USER_SSO_ID \n 2 = TO_BE_USER_CONTACT_ID \n 3 = TO_BE_USER_CELLPHONE_NUMBER \n 4 = TO_BE_USER_USERNAME", cellHeight: 70, cellColor: .white)
            case (1, 5):    setPlaceHolderText(Input1: "message", Input2: "title", Input3: "inviteeId", Input4: "inviteeType", Input5: "description", Input6: "image", Input7: "metadata", Input8: "")
                            updateText(cellText: "inviteeType: \n 0 = TO_BE_USER_ID \n 1 = TO_BE_USER_SSO_ID \n 2 = TO_BE_USER_CONTACT_ID \n 3 = TO_BE_USER_CELLPHONE_NUMBER \n 4 = TO_BE_USER_USERNAME", cellHeight: 70, cellColor: .white)
            case (1, 6):    setPlaceHolderText(Input1: "message", Input2: "title", Input3: "inviteeId", Input4: "inviteeType", Input5: "description", Input6: "image", Input7: "metadata", Input8: "")
                            updateText(cellText: "inviteeType: \n 0 = TO_BE_USER_ID \n 1 = TO_BE_USER_SSO_ID \n 2 = TO_BE_USER_CONTACT_ID \n 3 = TO_BE_USER_CELLPHONE_NUMBER \n 4 = TO_BE_USER_USERNAME", cellHeight: 70, cellColor: .white)
            case (1, 7):    setPlaceHolderText(Input1: "count", Input2: "offset", Input3: "name", Input4: "threadId", Input5: "firstMessageId", Input6: "lastMessageId", Input7: "", Input8: "")
            case (1, 8):    setPlaceHolderText(Input1: "threadId", Input2: "fromTime", Input3: "toTime", Input4: "query", Input5: "count", Input6: "offset", Input7: "firstMessageId", Input8: "lastMessageId")
            case (1, 9):    setPlaceHolderText(Input1: "count", Input2: "offset", Input3: "name", Input4: "threadId", Input5: "coreUserId", Input6: "new", Input7: "", Input8: "")
                            updateText(cellText: "new: \n true or false", cellHeight: 35, cellColor: .white)
            case (1, 10):    setPlaceHolderText(Input1: "count", Input2: "offset", Input3: "name", Input4: "threadId", Input5: "firstMessageId", Input6: "lastMessageId", Input7: "", Input8: "")
            case (1, 11):    setPlaceHolderText(Input1: "ThreadId", Input2: "", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (1, 12):   setPlaceHolderText(Input1: "ThreadId", Input2: "", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (1, 13):   setPlaceHolderText(Input1: "ThreadId", Input2: "", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (1, 14):   setPlaceHolderText(Input1: "threadId", Input2: "userId", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (1, 15):   setPlaceHolderText(Input1: "threadId", Input2: "userId", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (1, 16):   setPlaceHolderText(Input1: "ThreadId", Input2: "participant", Input3: "participant", Input4: "participant", Input5: "", Input6: "", Input7: "", Input8: "")
            case (1, 17):   setPlaceHolderText(Input1: "ThreadId", Input2: "", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (1, 18):   setPlaceHolderText(Input1: "ThreadId", Input2: "", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (1, 19):   setPlaceHolderText(Input1: "name", Input2: "", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
                
            // Message Managements
            case (2, 0):    setPlaceHolderText(Input1: "subjectId", Input2: "", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (2, 1):    setPlaceHolderText(Input1: "threadId", Input2: "subjectId", Input3: "subjectId", Input4: "subjectId", Input5: "deleteForAll", Input6: "", Input7: "", Input8: "")
                            updateText(cellText: "deleteForAll: \n true or false", cellHeight: 35, cellColor: .white)
            case (2, 2):    setPlaceHolderText(Input1: "content", Input2: "messageId", Input3: "repliedTo", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (2, 3):    setPlaceHolderText(Input1: "messageIds", Input2: "subjectId", Input3: "repliedTo", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (2, 4):    setPlaceHolderText(Input1: "count", Input2: "offset", Input3: "messageId", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (2, 5):    setPlaceHolderText(Input1: "count", Input2: "offset", Input3: "messageId", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (2, 6):    setPlaceHolderText(Input1: "messageId", Input2: "", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (2, 7):    setPlaceHolderText(Input1: "messageId", Input2: "", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (2, 8):    setPlaceHolderText(Input1: "content", Input2: "repliedTo", Input3: "subjectId", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (2, 9):    setPlaceHolderText(Input1: "content", Input2: "repliedTo", Input3: "threadId", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (2, 10):   setPlaceHolderText(Input1: "content", Input2: "repliedTo", Input3: "threadId", Input4: "key, value", Input5: "key, value", Input6: "key, value", Input7: "key, value", Input8: "key, value")
            
            // Location Managements
            case (3, 0):    setPlaceHolderText(Input1: "lat", Input2: "lon", Input3: "threadId", Input4: "message", Input5: "", Input6: "", Input7: "", Input8: "")
            
            // File Managements
            case (4, 0):    setPlaceHolderText(Input1: "fileName", Input2: "message", Input3: "repliedTo", Input4: "threadId", Input5: "", Input6: "", Input7: "", Input8: "")
            case (4, 1):    setPlaceHolderText(Input1: "fileName", Input2: "message", Input3: "threadId", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (4, 2):    setPlaceHolderText(Input1: "fileName", Input2: "threadId", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            case (4, 3):    setPlaceHolderText(Input1: "imageName", Input2: "", Input3: "", Input4: "", Input5: "", Input6: "", Input7: "", Input8: "")
            
            default:        print("Selected row number \(row) that is not in the correct range!")
            }
        }
           
    }
    
    func setPlaceHolderText(Input1: String, Input2: String, Input3: String, Input4: String, Input5: String, Input6: String, Input7: String, Input8: String) {
        input1TextField.placeholder = Input1
        input2TextField.placeholder = Input2
        input3TextField.placeholder = Input3
        input4TextField.placeholder = Input4
        input5TextField.placeholder = Input5
        input6TextField.placeholder = Input6
        input7TextField.placeholder = Input7
        input8TextField.placeholder = Input8
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
        isProgressActive = false
        progressCell = -1
        myProgress = 0.0
        uploadImageUniqueId     = ""
        uploadFileUniqueId      = ""
        downloadFileUniqueId    = ""
        input1TextField.text?.removeAll()
        input2TextField.text?.removeAll()
        input3TextField.text?.removeAll()
        input4TextField.text?.removeAll()
    }
    
}



extension MyChatViewController {
    
    @objc func fireRequest() {
        switch (section, picker) {
        case (0, 0): implementAddContact()              // implement AddContact
        case (0,1): implementBlock()                    // implement Block
        case (0,2): implementGetBlockedList()           // implement GetBlockedList
        case (0,3): implementGetContacts()              // implement GetContacts
        case (0,4): implementRemoveContact()            // implement RemoveContact
        case (0,5): implementSearchContact()            // implement SearchContact
        case (0,6): implementUnblock()                  // implement Unblock
        case (0,7): implementUpdateContact()            // implement UpdateContact
            
        case (1, 0): implementAddAdmin()                // implement AddAdmin
        case (1, 1): implementAddAuditor()              // implement AddAuditor
        case (1, 2): implementAddParticipant()          // implement AddThreadParticipants
        case (1, 3): implementClearHistory()            // implement ClearHistory
        case (1, 4): implementCreateThread()            // implement CreateThread
        case (1, 5): implementCreateWithMessageThread() // implement CreateThreadWithMessage
        case (1, 6): implementCreateWithFileMessageThread() // implement CreateThreadWithFileMessage
        case (1, 7): implementGetAdminList()            // implement GetAdminList
        case (1, 8): implementGetHistory()              // implement GetHistory
        case (1, 9): implementGetThreads()              // implement GetThreads
        case (1, 10): implementGetThreadParticipants()   // implement GetThreadParticipants
        case (1, 11): implementLeaveThread()             // implement LeaveThread
        case (1, 12): implementMuteThread()             // implement MuteThread
        case (1, 13): implementUnmuteThread()           // implement UnmuteThread
        case (1, 14): implementRemoveAdmin()            // implement RemoveAdmin
        case (1, 15): implementRemoveAuditor()          // implement RemoveAuditor
        case (1, 16): implementRemoveParticipant()      // implement RemoveParticipant
        case (1, 17): implementSpamThread()             // implement SpamThread
        case (1, 18): implementGetCurrentUserRoles()    // implement GetCurrentUserRoles
        case (1, 19): implementIsNameAvailable()        // implement IsNameAvailable
            
        case (2, 0): implementDeleteMessage()           // implement DeletMessage
        case (2, 1): implementDeleteMultipleMessages()  // implement DeletMessage
        case (2, 2): implementEditMessage()             // implement EditMessage
        case (2, 3): implementForwardMessage()          // implement ForwardMessage
        case (2, 4): implementMessageDeliveryList()     // implement MessgaeDeliveryList
        case (2, 5): implementMessageSeenList()         // implement MessageSeenList
        case (2, 6): implementPinMessage()              // implement PinMessage
        case (2, 7): implementUnpinMessage()            // implement UnpinMessage
        case (2, 8): implementReplyTextMessage()        // implement ReplyTextMessage
        case (2, 9): implementSendTextMessage()         // implement SendTextMessage
        case (2, 10): implementBotTextMessage()          // implement SentBotMessage
            
        case (3, 0): implementSendLocationMessage()     // implement SendLocationMessage
            
        case (4, 0): implementReplyFileMessage()        // implement ReplyFileMessage
        case (4, 1): implementSendFileMessage()         // implement SendFileMessage
        case (4, 2): implementUploadFile()              // implement UploadFile
        case (4, 3): implementUploadImage()             // implement UploadImage
            
        default:
            print("Selected row number \(picker) that is not in the correct range!")
        }
    }
    
    // Contact Managements
    // (0, 0)
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
            let myText = "addContact uniqueId = \(addContactUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
            print(myText)
        }) { (addContactModel) in
            let myText = "add contact model response = \(addContactModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (0, 1)
    func implementBlock() {
        let conId:  Int?    = Int(input1TextField.text ?? "")
        let thrId:  Int?    = Int(input2TextField.text ?? "")
        let usrId:  Int?    = Int(input3TextField.text ?? "")
        
        let block = BlockAutomation(contactId: conId, threadId: thrId, typeCode: nil, userId: usrId)
        block.delegate = self
        block.create(uniqueId: { (blockUniqueId) in
            let myText = "block uniqueId = \(blockUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (blockedContactModel) in
            let myText = "block response = \(blockedContactModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (0, 2)
    func implementGetBlockedList() {
        let count:  Int?    = Int(input1TextField.text ?? "")
        let offset: Int?    = Int(input1TextField.text ?? "")
        
        let getBlockedList = GetBlockedListAutomation(count: count, offset: offset, typeCode: nil)
        getBlockedList.delegate = self
        getBlockedList.create(uniqueId: { (getBlockedListUniqueId) in
            let myText = "getBlockedList uniqueId = \(getBlockedListUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (getBlockedContactListModel) in
            let myText = "get blocked list model response = \(getBlockedContactListModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (0, 3)
    func implementGetContacts() {
        let count:  Int?    = Int(input1TextField.text ?? "")
        let offst:  Int?    = Int(input2TextField.text ?? "")
        var query:  String? = nil
        
        if let txt = input3TextField.text {
            if (txt != "") && (txt.first != " ") { query = txt }
        }
        
        let getContact = GetContactsAutomation(count: count, offset: offst, query: query, typeCode: nil)
        getContact.delegate = self
        getContact.create(uniqueId: { (getContactUniqueId) in
            let myText = "getContact uniqueId = \(getContactUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverResponse: { (getContactsModel) in
            let myText = "get contact model server response = \(getContactsModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (getContactsModel) in
            let myText = "get contact model cache response = \(getContactsModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#55efc4", alpha: 1))
        }
    }
    
    // (0, 4)
    func implementRemoveContact() {
        let id: Int?    = Int(input1TextField.text ?? "")
        
        let removeContact = RemoveContactAutomation(id: id)
        removeContact.delegate = self
        removeContact.create(uniqueId: { (removeContactUniqueId) in
            let myText = "removeContact uniqueId = \(removeContactUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
            print(myText)
        }) { (removeContactModel) in
            let myText = "remove contact model response = \(removeContactModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
            print(myText)
        }
    }
    
    // (0, 5)
    func implementSearchContact() {
        var cellPhone:  String? = nil
        var firstName:  String? = nil
        var lastName:   String? = nil
        var email:      String? = nil
        let id:     Int?    = Int(input4TextField.text ?? "")
        let offset: Int?    = Int(input6TextField.text ?? "")
        let count:  Int?    = Int(input7TextField.text ?? "")
        
        if let cell = input1TextField.text {
            if (cell != "") { cellPhone = cell }
        }
        if let first = input2TextField.text {
            if (first != "") { firstName = first }
        }
        if let last = input3TextField.text {
            if (last != "") { lastName = last }
        }
        if let em = input5TextField.text {
            if (em != "") { email = em }
        }
        
        let searchContact = SearchContactAutomation(cellphoneNumber:    cellPhone,
                                                    email:              email,
                                                    firstName:          firstName,
                                                    id:                 id,
                                                    lastName:           lastName,
                                                    offset:             offset,
                                                    size:               count,
                                                    requestUniqueId:    nil)
        
        searchContact.delegate = self
        searchContact.create(uniqueId: { (searchContactUniqueId) in
            let myText = "searchContact uniqueId = \(searchContactUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverResponse: { (searchContactsServerModel) in
            let myText = "search contact model server response = \(searchContactsServerModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (searchContactsCacheModel) in
            let myText = "search contact model cache response = \(searchContactsCacheModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#55efc4", alpha: 1))
        }
        
        
    }
    
    // (0, 6)
    func implementUnblock() {
        let blockId:    Int?    = Int(input1TextField.text ?? "")
        let contactId:  Int?    = Int(input2TextField.text ?? "")
        let threadId:   Int?    = Int(input3TextField.text ?? "")
        let userId:     Int?    = Int(input4TextField.text ?? "")
        
        let unblock = UnblockAutomation(blockId: blockId, contactId: contactId, threadId: threadId, typeCode: nil, userId: userId)
        unblock.delegate = self
        unblock.create(uniqueId: { (unblockUniqueId) in
            let myText = "unblock uniqueId = \(unblockUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (unblockModel) in
            let myText = "unblock model response = \(unblockModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (0, 7)
    func implementUpdateContact() {
        let contactId:          Int?    = Int(input1TextField.text ?? "")
        var cellPhoneNumber:    String? = nil
        var email:              String? = nil
        var firstName:          String? = nil
        var lastName:           String? = nil
        
        if let txt = input2TextField.text {
            if (txt != "") && (txt.first != " ") { cellPhoneNumber = txt }
        }
        if let txt = input3TextField.text {
            if (txt != "") && (txt.first != " ") { email = txt }
        }
        if let fn = input4TextField.text {
            firstName = fn
        }
        if let ln = input5TextField.text {
            lastName = ln
        }
        
        let updateContact = UpdateContactAutomation(cellphoneNumber: cellPhoneNumber, email: email, firstName: firstName, id: contactId, lastName: lastName)
        updateContact.delegate = self
        updateContact.create(uniqueId: { (updateContactUniqueId) in
            let myText = "updateContact uniqueId = \(updateContactUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (contactModelResponse) in
            let myText = "update contact model response = \(contactModelResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    
    // Thread Managements
    // (1, 0)
    func implementAddAdmin() {
        let threadId:   Int?    = Int(input1TextField.text ?? "")
        let userId:     Int?    = Int(input2TextField.text ?? "")
        
        let addAdmin = AddAdminAutomation(threadId: threadId, userId: userId, requestUniqueId: nil)
        addAdmin.delegate = self
        addAdmin.create(uniqueId: { (addAdminUniqueId) in
            let myText = "addAdmin uniqueId = \(addAdminUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverResponse: { (addAdminModelServerResponse) in
            let myText = "add admin model response = \(addAdminModelServerResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        })
        
    }
    
    // (1, 1)
    func implementAddAuditor() {
        let threadId:   Int?    = Int(input1TextField.text ?? "")
        let userId:     Int?    = Int(input2TextField.text ?? "")
        
        let addAuditor = AddAuditorAutomation(threadId: threadId, userId: userId, requestUniqueId: nil)
        addAuditor.delegate = self
        addAuditor.create(uniqueId: { (addAdminUniqueId) in
            let myText = "addAuditor uniqueId = \(addAdminUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverResponse: { (addAuditorModelServerResponse) in
            let myText = "add Auditor model response = \(addAuditorModelServerResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        })
    }
    
    // (1, 2)
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
        
        let addParticipant = AddParticipantAutomation(contacts: myContacts, threadId: threadId, typeCode: nil, requestUniqueId: nil)
        addParticipant.delegate = self
        addParticipant.create(uniqueId: { (addParticipantUniqueId) in
            let myText = "addThreadParticipant uniqueId) = \(addParticipantUniqueId)"
            self.updateText(cellText: myText, cellHeight: 60, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (addParticipantServerResponse) in
            let myText = "add thread participant server model response) = \(addParticipantServerResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (1,3)
    func implementClearHistory() {
        let threadId:   Int?    = Int(input1TextField.text ?? "")
        
        let clearHistory = ClearHistoryAutomation(threadId: threadId, requestUniqueId: nil)
        clearHistory.delegate = self
        clearHistory.create(uniqueId: { (clearHistoryUniqueId) in
            let myText = "clearHistory uniqueId = \(clearHistoryUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (clearHistoryServerResponse) in
            let myText = "clear history server model response = \(clearHistoryServerResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (1,4)
    func implementCreateThread() {
        var description:    String? = nil
        var title:          String? = nil
        var inviteeId:      String? = nil
        let inviteeType:    Int?    = Int(input4TextField.text ?? "")
        var image:          String? = nil
        var metadata:       String? = nil
        
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
            case 1:     invitees = [Invitee(id: id, idType: InviteeVoIdTypes.TO_BE_USER_SSO_ID)]
            case 2:     invitees = [Invitee(id: id, idType: InviteeVoIdTypes.TO_BE_USER_CONTACT_ID)]
            case 3:     invitees = [Invitee(id: id, idType: InviteeVoIdTypes.TO_BE_USER_CELLPHONE_NUMBER)]
            case 4:     invitees = [Invitee(id: id, idType: InviteeVoIdTypes.TO_BE_USER_USERNAME)]
            case 0:     invitees = [Invitee(id: id, idType: InviteeVoIdTypes.TO_BE_USER_ID)]
            default:    invitees = [Invitee(id: id, idType: "0")]
            }
        }
        if let txt = input5TextField.text {
            if (txt != "") && (txt.first != " ") { image = txt }
        }
        if let txt = input6TextField.text {
            if (txt != "") && (txt.first != " ") { metadata = txt }
        }
        
        let createThread = CreateThreadAutomation(description:      description,
                                                  image:            image,
                                                  invitees:         invitees,
                                                  metadata:         metadata,
                                                  title:            title,
                                                  uniqueName:       nil,
                                                  type:             ThreadTypes.PUBLIC_GROUP,
                                                  requestUniqueId:  nil)
        createThread.delegate = self
        createThread.create(uniqueId: { (createThreadUniqueId, on) in
            let myText = "createThread uniqueId \(on) = \(createThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 65, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (createThreadModel, on) in
            let myText = "create thread model response \(on) = \(createThreadModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (1, 5)
    func implementCreateWithMessageThread() {
        var textMessage:    String? = nil
        var title:          String? = nil
        var inviteeId:      String? = nil
        let inviteeType:    Int? = Int(input4TextField.text ?? "")
        var description:    String? = nil
        var image:          String? = nil
        var metadata:       String? = nil
        
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
            case 1:     invitees = [Invitee(id: id, idType: InviteeVoIdTypes.TO_BE_USER_SSO_ID)]
            case 2:     invitees = [Invitee(id: id, idType: InviteeVoIdTypes.TO_BE_USER_CONTACT_ID)]
            case 3:     invitees = [Invitee(id: id, idType: InviteeVoIdTypes.TO_BE_USER_CELLPHONE_NUMBER)]
            case 4:     invitees = [Invitee(id: id, idType: InviteeVoIdTypes.TO_BE_USER_USERNAME)]
            case 5:     invitees = [Invitee(id: id, idType: InviteeVoIdTypes.TO_BE_USER_ID)]
            default:    invitees = [Invitee(id: id, idType: "5")]
            }
        }
        if let txt = input5TextField.text {
            if (txt != "") && (txt.first != " ") { description = txt }
        }
        if let txt = input6TextField.text {
            if (txt != "") && (txt.first != " ") { image = txt }
        }
        if let txt = input7TextField.text {
            if (txt != "") && (txt.first != " ") { metadata = txt }
        }
        
        let createThtradWithMessage = CreateThreadWithMessageAutomation(description:        description,
                                                                        image:              image,
                                                                        invitees:           invitees,
                                                                        messageText:        textMessage,
                                                                        metadata:           metadata,
                                                                        title:              title,
                                                                        type:               nil,
                                                                        requestUniqueId:    nil)
        createThtradWithMessage.delegate = self
        createThtradWithMessage.create(uniqueId: { (createThreadUniqueId) in
            let myText = "createThread uniqueId) = \(createThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverResponse: { (createThreadModel) in
            let myText = "create thread model response) = \(createThreadModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverSentResponse: { (sent) in
            let myText = "sendTextMessage sent response = \(sent.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverDeliverResponse: { (deliver) in
            let myText = "sendTextMessage deliver response = \(deliver.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (seen) in
            let myText = "sendTextMessage seen response = \(seen.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
        
    }
    
    // (1, 6)
    func implementCreateWithFileMessageThread() {
        var textMessage:    String? = nil
        var title:          String? = nil
        var inviteeId:      String? = nil
        let inviteeType:    Int? = Int(input4TextField.text ?? "")
        var description:    String? = nil
        var image:          String? = nil
        var metadata:       String? = nil
        
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
            case 1:     invitees = [Invitee(id: id, idType: InviteeVoIdTypes.TO_BE_USER_SSO_ID)]
            case 2:     invitees = [Invitee(id: id, idType: InviteeVoIdTypes.TO_BE_USER_CONTACT_ID)]
            case 3:     invitees = [Invitee(id: id, idType: InviteeVoIdTypes.TO_BE_USER_CELLPHONE_NUMBER)]
            case 4:     invitees = [Invitee(id: id, idType: InviteeVoIdTypes.TO_BE_USER_USERNAME)]
            case 5:     invitees = [Invitee(id: id, idType: InviteeVoIdTypes.TO_BE_USER_ID)]
            default:    invitees = [Invitee(id: id, idType: "5")]
            }
        }
        if let txt = input5TextField.text {
            if (txt != "") && (txt.first != " ") { description = txt }
        }
        if let txt = input6TextField.text {
            if (txt != "") && (txt.first != " ") { image = txt }
        }
        if let txt = input7TextField.text {
            if (txt != "") && (txt.first != " ") { metadata = txt }
        }
        
        let createThtradWithFileMessage = CreateThreadWithFileMessageAutomation(description:        description,
                                                                                image:              image,
                                                                                invitees:           invitees,
                                                                                messageText:        textMessage,
                                                                                metadata:           metadata,
                                                                                title:              title,
                                                                                type:               nil,
                                                                                requestUniqueId:    nil)
        createThtradWithFileMessage.delegate = self
        createThtradWithFileMessage.create(uniqueId: { (createThreadUniqueId) in
            let myText = "createThread uniqueId) = \(createThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, uploadUniqueIdCallback: { (uploadUniqueId) in
            let myText = "upload uniqueId) = \(uploadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, progressCallback: { (progress) in
            if self.isProgressActive {
                self.myProgress = progress
            } else {
                self.isProgressActive = true
                let myText = "uploadFile Progress:"
                self.updateText(cellText: myText, cellHeight: 70, cellColor: .lightGray)
            }
        }, serverResponse: { (createThreadModel) in
            let myText = "create thread model response) = \(createThreadModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverSentResponse: { (sent) in
            let myText = "sendTextMessage sent response = \(sent.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverDeliverResponse: { (deliver) in
            let myText = "sendTextMessage deliver response = \(deliver.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (seen) in
            let myText = "sendTextMessage seen response = \(seen.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (1, 7)
    func implementGetAdminList() {
        let count:          Int?    = Int(input1TextField.text ?? "")
        let offset:         Int?    = Int(input2TextField.text ?? "")
        var name:           String? = nil
        let threadId:       Int?    = Int(input4TextField.text ?? "")
        let firstMessageId: Int?    = Int(input5TextField.text ?? "")
        let lastMessageId:  Int?    = Int(input6TextField.text ?? "")
        
        if let txt = input3TextField.text {
            if (txt != "") && (txt.first != " ") { name = txt }
        }
        
        let getThreadParticipant = GetAdminAutomation(count:            count,
                                                      firstMessageId:   firstMessageId,
                                                      lastMessageId:    lastMessageId,
                                                      name:             name,
                                                      offset:           offset,
                                                      threadId:         threadId,
                                                      typeCode:         nil)
        getThreadParticipant.delegate = self
        getThreadParticipant.create(uniqueId: { (getThreadParticipantUniqueId) in
            let myText = "getThreadParticipant uniqueId = \(getThreadParticipantUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverResponse: { (getThreadParticipantsModel) in
            let myText = "get thread participant model server response = \(getThreadParticipantsModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (getThreadParticipantsModel) in
            let myText = "get thread participant model cache response = \(getThreadParticipantsModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#55efc4", alpha: 1))
        }
    }
    
    // (1, 8)
    func implementGetHistory() {
        let threadId:       Int?    = Int(input1TextField.text ?? "")
        let fromTime:       UInt?   = UInt(input2TextField.text ?? "")
        let toTime:         UInt?   = UInt(input3TextField.text ?? "")
        var query:          String? = nil
        let count:          Int?    = Int(input5TextField.text ?? "")
        let offset:         Int?    = Int(input6TextField.text ?? "")
        let firstMessageId: Int?    = Int(input7TextField.text ?? "")
        let lastMessageId:  Int?    = Int(input8TextField.text ?? "")
        
        if let txt = input4TextField.text {
            if (txt != "") && (txt.first != " ") { query = txt }
        }
        
        let getHistory = GetHistoryAutomation(count:            count,
                                              firstMessageId:   firstMessageId,
                                              fromTime:         fromTime,
                                              lastMessageId:    lastMessageId,
                                              messageId:        nil,
                                              metadataCriteria: nil,
                                              offset:           offset,
                                              order:            nil,
                                              query:            query,
                                              threadId:         threadId,
                                              toTime:           toTime,
                                              typeCode:         nil,
                                              requestUniqueId:  nil)
        getHistory.delegate = self
        getHistory.create(uniqueId: { (getHistoryUniqueId) in
            let myText = "getHistory uniqueId = \(getHistoryUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverResponse: { (getHistoryServerModel) in
            let myText = "get history model server response = \(getHistoryServerModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (getHistoryCacheModel) in
            let myText = "get history model cache response = \(getHistoryCacheModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#55efc4", alpha: 1))
        }
    }
    
    // (1, 9)
    func implementGetThreads() {
        let count:      Int?    = Int(input1TextField.text ?? "")
        let offset:     Int?    = Int(input2TextField.text ?? "")
        var name:       String? = nil
        let threadId:   Int?    = Int(input4TextField.text ?? "")
        let coreUserId: Int?    = Int(input5TextField.text ?? "")
        var new:        Bool?   = nil
        
        if let txt = input3TextField.text {
            if (txt != "") && (txt.first != " ") { name = txt }
        }
        if let txt = input6TextField.text {
            if (txt != "") && (txt.first != " ") {
                (txt == "true") ? (new = true) : (new = false)
            }
        }
        
        let getThread = GetThreadAutomation(count:              count,
                                            coreUserId:         coreUserId,
                                            metadataCriteria:   nil,
                                            name:               name,
                                            new:                new,
                                            offset:             offset,
                                            threadIds:          [threadId ?? 0],
                                            typeCode:           nil)
        getThread.delegate = self
        getThread.create(uniqueId: { (getThreadUniqueId) in
            let myText = "getThread uniqueId = \(getThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverResponse: { (getThreadsModel) in
            let myText = "get thread model server response = \(getThreadsModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (getThreadsModel) in
            let myText = "get thread model cache response = \(getThreadsModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#55efc4", alpha: 1))
        }
    }
    
    // (1, 10)
    func implementGetThreadParticipants() {
        let count:          Int?    = Int(input1TextField.text ?? "")
        let offset:         Int?    = Int(input2TextField.text ?? "")
        var name:           String? = nil
        let threadId:       Int?    = Int(input4TextField.text ?? "")
        let firstMessageId: Int?    = Int(input5TextField.text ?? "")
        let lastMessageId:  Int?    = Int(input6TextField.text ?? "")
        
        if let txt = input3TextField.text {
            if (txt != "") && (txt.first != " ") { name = txt }
        }
        
        let getThreadParticipant = GetThreadParticipantsAutomation(admin:           false,
                                                                   count:           count,
                                                                   firstMessageId:  firstMessageId,
                                                                   lastMessageId:   lastMessageId,
                                                                   name:            name,
                                                                   offset:          offset,
                                                                   threadId:        threadId,
                                                                   typeCode:        nil)
        getThreadParticipant.delegate = self
        getThreadParticipant.create(uniqueId: { (getThreadParticipantUniqueId) in
            let myText = "getThreadParticipant uniqueId = \(getThreadParticipantUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverResponse: { (getThreadParticipantsModel) in
            let myText = "get thread participant model server response = \(getThreadParticipantsModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (getThreadParticipantsModel) in
            let myText = "get thread participant model cache response = \(getThreadParticipantsModel.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 140, cellColor: UIColor.init().hexToRGB(hex: "#55efc4", alpha: 1))
        }
    }
    
    // (1, 11)
    func implementLeaveThread() {
        let threadId: Int?  = Int(input1TextField.text ?? "")
        
        let leaveThread = LeaveThreadAutomation(threadId: threadId, typeCode: nil, requestUniqueId: nil)
        leaveThread.delegate = self
        leaveThread.create(uniqueId: { (leaveThreadUniqueId) in
            let myText = "leaveThread uniqueId = \(leaveThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (leaveThreadServerResponse) in
            let myText = "leaveThread response = \(leaveThreadServerResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (1, 12)
    func implementMuteThread() {
        let threadId: Int?  = Int(input1TextField.text ?? "")
        
        let muteThread = MuteThreadAutomation(threadId: threadId, typeCode: nil)
        muteThread.delegate = self
        muteThread.create(uniqueId: { (muteThreadUniqueId) in
            let myText = "muteThread uniqueId = \(muteThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (muteThreadServerResponse) in
            let myText = "muteThread response = \(muteThreadServerResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (1, 13)
    func implementUnmuteThread() {
        let threadId: Int?  = Int(input1TextField.text ?? "")
        
        let unmuteThread = UnmuteThreadAutomation(threadId: threadId, typeCode: nil)
        unmuteThread.delegate = self
        unmuteThread.create(uniqueId: { (unmuteThreadUniqueId) in
            let myText = "unmuteThread uniqueId = \(unmuteThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (unmuteThreadServerResponse) in
            let myText = "unmuteThread response = \(unmuteThreadServerResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (1, 14)
    func implementRemoveAdmin() {
        let threadId:   Int?    = Int(input1TextField.text ?? "")
        let userId:     Int?    = Int(input2TextField.text ?? "")
        
        let removeAdmin = RemoveAdminAutomation(threadId: threadId, userId: userId, requestUniqueId: nil)
        removeAdmin.delegate = self
        removeAdmin.create(uniqueId: { (removeAdminUniqueId) in
            let myText = "remove Admin uniqueId = \(removeAdminUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverResponse: { (removeAdminModelServerResponse) in
            let myText = "remove admin model response = \(removeAdminModelServerResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        })
    }
    
    // (1, 15)
    func implementRemoveAuditor() {
        let threadId:   Int?    = Int(input1TextField.text ?? "")
        let userId:     Int?    = Int(input2TextField.text ?? "")
        
        let removeAuditor = RemoveAuditorAutomation(threadId: threadId, userId: userId, requestUniqueId: nil)
        removeAuditor.delegate = self
        removeAuditor.create(uniqueId: { (removeAuditorUniqueId) in
            let myText = "removeAuditor uniqueId = \(removeAuditorUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverResponse: { (removeAuditorModelServerResponse) in
            let myText = "remove Auditor model response = \(removeAuditorModelServerResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        })
    }
    
    // (1, 16)
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
        
        let removeParticipant = RemoveParticipantAutomation(content:            myParticipants,
                                                            threadId:           threadId,
                                                            typeCode:           nil,
                                                            requestUniqueId:    nil)
        removeParticipant.delegate = self
        removeParticipant.create(uniqueId: { (removeParticipantUniqueId) in
            let myText = "removeParticipant uniqueId = \(removeParticipantUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (removeParticipantServerResponse) in
            let myText = "removeParticipant response = \(removeParticipantServerResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (1, 17)
    func implementSpamThread() {
        let threadId: Int?  = Int(input1TextField.text ?? "")
        
        let spamThread = SpamThreadAutomation(threadId: threadId, typeCode: nil)
        spamThread.delegate = self
        spamThread.create(uniqueId: { (spamThreadUniqueId) in
            let myText = "spamThread uniqueId = \(spamThreadUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (spamThreadServerResponse) in
            
            var myText = "spamThread response: \n"
            
            if let leaveThreadResponse = spamThreadServerResponse as? ThreadModel {
                myText += "leaveThreadResponse = \(leaveThreadResponse.returnDataAsJSON())"
            } else if let blockThreadResponse = spamThreadServerResponse as? BlockedUserModel  {
                myText += "blockThreadResponse = \(blockThreadResponse.returnDataAsJSON())"
            } else if let clearHistoryResponse = spamThreadServerResponse as? ClearHistoryModel {
                myText += "clearHistoryResponse = \(clearHistoryResponse.returnDataAsJSON())"
            }
            
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (1, 18)
    func implementGetCurrentUserRoles() {
        let threadId: Int?  = Int(input1TextField.text ?? "")
        
        let getCurrentUserRole = GetCurrentUserRolesAutomation(threadId: threadId, typeCode: nil)
        getCurrentUserRole.delegate = self
        getCurrentUserRole.create(uniqueId: { (getCurrentUserRoleUniqueId) in
            let myText = "getCurrentUserRole uniqueId = \(getCurrentUserRoleUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverResponse: { (getCurrentUserRoleServerResponse) in
            let myText = "getCurrentUserRole response: \n \(getCurrentUserRoleServerResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, cacheResponse: { (getCurrentUserRoleCacheResponse) in
            let myText = "getCurrentUserRole cache response = \(getCurrentUserRoleCacheResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#55efc4", alpha: 1))
        })
    }
    
    // (1, 19)
    func implementIsNameAvailable() {
        let name: String?  = input1TextField.text ?? ""
        
        let isNameAvailable = IsNameAvailableAutomation(name: name, typeCode: nil)
        isNameAvailable.delegate = self
        isNameAvailable.create(uniqueId: { (isNameAvailableUniqueId) in
            let myText = "isNameAvailableUniqueId uniqueId = \(isNameAvailableUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverResponse: { (isNameAvailableUniqueIdServerResponse) in
            let myText = "isNameAvailableUniqueId response: \n \(isNameAvailableUniqueIdServerResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        })
    }
    
    
    
    // Message Managements
    // (2, 0)
    func implementDeleteMessage() {
        let subjectId:  Int?    = Int(input1TextField.text ?? "")
        
        let deleteMessage = DeleteMessageAutomation(deleteForAll: nil, subjectId: subjectId, typeCode: nil, requestUniqueId: nil)
        deleteMessage.delegate = self
        deleteMessage.create(uniqueId: { (deleteMessageUniqueId) in
            let myText = "deleteMessage uniqueId = \(deleteMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (deleteMessageResponse) in
            let myText = "deleteMessage response = \(deleteMessageResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (2, 1)
    func implementDeleteMultipleMessages() {
        let threadId:       Int?    = Int(input1TextField.text ?? "")
        let subjectId1:     Int?    = Int(input2TextField.text ?? "")
        let subjectId2:     Int?    = Int(input3TextField.text ?? "")
        let subjectId3:     Int?    = Int(input4TextField.text ?? "")
        var deleteForAll:   Bool?   = nil
        
        if let txt = input5TextField.text {
            if (txt != "") && (txt.first != " ") {
                (txt == "true") ? (deleteForAll = true) : (deleteForAll = false)
            }
        }
        
        var subIds = [Int]()
        
        if let _ = subjectId1 { subIds.append(subjectId1!) }
        if let _ = subjectId2 { subIds.append(subjectId2!) }
        if let _ = subjectId3 { subIds.append(subjectId3!) }
        
        let deleteMessages = DeleteMultipleMessagesAutomation(deleteForAll:     deleteForAll,
                                                              threadId:         threadId,
                                                              messageIds:       subIds,
                                                              typeCode:         nil,
                                                              requestUniqueIds: nil)
        deleteMessages.delegate = self
        deleteMessages.create(uniqueId: { (deleteMultipleMessagesUniqueId) in
            let myText = "deleteMultipleMessage uniqueId = \(deleteMultipleMessagesUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (deleteMessageResponse) in
            let myText = "deleteMultipleMessage response = \(deleteMessageResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
        
    }
    
    // (2, 2)
    func implementEditMessage() {
        var content:    String? = nil
        let messageId:  Int?    = Int(input2TextField.text ?? "")
        let repliedId:  Int?    = Int(input3TextField.text ?? "")
        
        if let txt = input1TextField.text {
            if (txt != "") && (txt.first != " ") { content = txt }
        }
        
        let editMessage = EditMessageAutomation(content:            content,
                                                metadata:           nil,
                                                repliedTo:          repliedId,
                                                messageId:          messageId,
                                                typeCode:           nil,
                                                requestUniqueId:    nil)
        editMessage.delegate = self
        editMessage.create(uniqueId: { (editMessageUniqueId) in
            let myText = "editMessage uniqueId = \(editMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (editMessageResponse) in
            let myText = "editMessage response = \(editMessageResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (2, 3)
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
        
        let forwardMessage = ForwardMessageAutomation(messageIds:   messageIds,
                                                      metadata:     nil,
                                                      repliedTo:    repliedTo,
                                                      subjectId:    subjectId,
                                                      typeCode:     nil,
                                                      uniqueId:     nil)
        forwardMessage.delegate = self
        forwardMessage.create(uniqueId: { (forwardMessageUniqueId) in
            let myText = "forwardMessage uniqueId = \(forwardMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverSentResponse: { (sent) in
            let myText = "forwardMessage sent response = \(sent.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverDeliverResponse: { (deliver) in
            let myText = "forwardMessage deliver response = \(deliver.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (seen) in
            let myText = "forwardMessage seen response = \(seen.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (2, 4)
    func implementMessageDeliveryList() {
        let count:      Int?    = Int(input1TextField.text ?? "")
        let offset:     Int?    = Int(input2TextField.text ?? "")
        let messageId:  Int?    = Int(input3TextField.text ?? "")
        
        let deliveryList = MessageDeliveryListAutomation(count:     count,
                                                         messageId: messageId,
                                                         offset:    offset,
                                                         typeCode:  nil)
        deliveryList.delegate = self
        deliveryList.create(uniqueId: { (messageDeliveryListUniqueId) in
            let myText = "MessageDeliveryList uniqueId = \(messageDeliveryListUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (messageDeliveryListResponse) in
            let myText = "MessageDeliveryList sent response = \(messageDeliveryListResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (2, 5)
    func implementMessageSeenList() {
        let count:      Int?    = Int(input1TextField.text ?? "")
        let offset:     Int?    = Int(input2TextField.text ?? "")
        let messageId:  Int?    = Int(input3TextField.text ?? "")
        
        let seenList = MessageSeenListAutomation(count:     count,
                                                 messageId: messageId,
                                                 offset:    offset,
                                                 typeCode:  nil)
        seenList.delegate = self
        seenList.create(uniqueId: { (messageSeenListUniqueId) in
            let myText = "MessageSeenList uniqueId = \(messageSeenListUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (messageSeenListResponse) in
            let myText = "MessageSeenList sent response = \(messageSeenListResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (2, 6)
    func implementPinMessage() {
        let messageId:  Int?    = Int(input1TextField.text ?? "")
        
        let pinMessage = PinMessageAutomation(messageId:        messageId,
                                              typeCode:         nil,
                                              requestUniqueId:  nil)
        pinMessage.delegate = self
        pinMessage.create(uniqueId: { (pinMessageUniqueId) in
            let myText = "PinMessage uniqueId = \(pinMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (pinMessageResponse) in
            let myText = "PinMessage response = \(pinMessageResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (2, 7)
    func implementUnpinMessage() {
        let messageId:  Int?    = Int(input1TextField.text ?? "")
        
        let unpinMessage = UnpinMessageAutomation(messageId:        messageId,
                                                  typeCode:         nil,
                                                  requestUniqueId:  nil)
        unpinMessage.delegate = self
        unpinMessage.create(uniqueId: { (unpinMessageUniqueId) in
            let myText = "UnpinMessage uniqueId = \(unpinMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (unpinMessageResponse) in
            let myText = "UnpinMessage response = \(unpinMessageResponse.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (2, 8)
    func implementReplyTextMessage() {
        var content:    String? = nil
        let repliedTo:  Int?    = Int(input2TextField.text ?? "")
        let subjectId:  Int?    = Int(input3TextField.text ?? "")
        
        if let txt = input1TextField.text {
            if (txt != "") && (txt.first != " ") { content = txt }
        }
        
        let replyMessage = ReplyMessageAutomation(content:      content,
                                                  metadata:     nil,
                                                  repliedTo:    repliedTo,
                                                  subjectId:    subjectId,
                                                  typeCode:     nil,
                                                  uniqueId:     nil)
        replyMessage.delegate = self
        replyMessage.create(uniqueId: { (replyMessageUniqueId) in
            let myText = "replyTextMessage uniqueId = \(replyMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverSentResponse: { (sent) in
            let myText = "replyTextMessage sent response = \(sent.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverDeliverResponse: { (deliver) in
            let myText = "replyTextMessage deliver response = \(deliver.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (seen) in
            let myText = "replyTextMessage seen response = \(seen.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (2, 9)
    func implementSendTextMessage() {
        var content:    String? = nil
        let repliedTo:  Int?    = Int(input2TextField.text ?? "")
        let threadId:   Int?    = Int(input3TextField.text ?? "")
        
        if let txt = input1TextField.text {
            if (txt != "") && (txt.first != " ") { content = txt }
        }
        
        let sendTextMessage = SendTextMessageAutomation(content:        content,
                                                        metadata:       nil,
                                                        repliedTo:      repliedTo,
                                                        systemMetadata: nil,
                                                        threadId:       threadId,
                                                        typeCode:       nil,
                                                        uniqueId:       nil)
        sendTextMessage.delegate = self
        sendTextMessage.create(uniqueId: { (sendTextMessageUniqueId) in
            let myText = "sendTextMessage uniqueId = \(sendTextMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverSentResponse: { (sent) in
            let myText = "sendTextMessage sent response = \(sent.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverDeliverResponse: { (deliver) in
            let myText = "sendTextMessage deliver response = \(deliver.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (seen) in
            let myText = "sendTextMessage seen response = \(seen.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (2, 10)
    func implementBotTextMessage() {
        var content:    String? = nil
        var metadata:   JSON    = [:]
        let messageId:  Int?    = Int(input2TextField.text ?? "")
        let threadId:   Int?    = Int(input3TextField.text ?? "")
        
        if let txt = input1TextField.text {
            if (txt != "") && (txt.first != " ") { content = txt }
        }
        
        if let msgIdsTxt = input4TextField.text {
            let str = msgIdsTxt.replacingOccurrences(of: " ", with: "") // remove all spaces
            let stringIds = str.components(separatedBy: ",")            // seperate ids
            if let key = stringIds.first , let value = stringIds.last {
                metadata[key] = JSON(value)
            }
        }
        if let msgIdsTxt = input5TextField.text {
            let str = msgIdsTxt.replacingOccurrences(of: " ", with: "") // remove all spaces
            let stringIds = str.components(separatedBy: ",")            // seperate ids
            if let key = stringIds.first , let value = stringIds.last {
                metadata[key] = JSON(value)
            }
        }
        if let msgIdsTxt = input6TextField.text {
            let str = msgIdsTxt.replacingOccurrences(of: " ", with: "") // remove all spaces
            let stringIds = str.components(separatedBy: ",")            // seperate ids
            if let key = stringIds.first , let value = stringIds.last {
                metadata[key] = JSON(value)
            }
        }
        if let msgIdsTxt = input7TextField.text {
            let str = msgIdsTxt.replacingOccurrences(of: " ", with: "") // remove all spaces
            let stringIds = str.components(separatedBy: ",")            // seperate ids
            if let key = stringIds.first , let value = stringIds.last {
                metadata[key] = JSON(value)
            }
        }
        if let msgIdsTxt = input8TextField.text {
            let str = msgIdsTxt.replacingOccurrences(of: " ", with: "") // remove all spaces
            let stringIds = str.components(separatedBy: ",")            // seperate ids
            if let key = stringIds.first , let value = stringIds.last {
                metadata[key] = JSON(value)
            }
        }
        
        
        let sendBotMessage = SendBotMessageAutomation(content:          content,
                                                      messsageId:       messageId,
                                                      metadata:         "\(metadata)",
                                                      threadId:         threadId,
                                                      systemMetadata:   nil,
                                                      typeCode:         nil,
                                                      uniqueId:         nil)
        sendBotMessage.delegate = self
        sendBotMessage.create(uniqueId: { (sendBotMessageUniqueId) in
            let myText = "sendBotMessage uniqueId = \(sendBotMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverSentResponse: { (sent) in
            let myText = "sendBotMessage sent response = \(sent.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverDeliverResponse: { (deliver) in
            let myText = "sendBotMessage deliver response = \(deliver.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (seen) in
            let myText = "sendBotMessage seen response = \(seen.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // Location Managements
    // (3, 0)
    func implementSendLocationMessage() {
        let lat:    Double? = Double(input1TextField.text ?? "")
        let lon:    Double? = Double(input2TextField.text ?? "")
        let threadId:   Int?    = Int(input3TextField.text ?? "")
        var content:    String? = nil
        if let txt = input4TextField.text {
            if (txt != "") && (txt.first != " ") { content = txt }
        }
        
        let sendLocationMessage = SendLocationMessageAutomation(lat:        lat,
                                                                lon:        lon,
                                                                content:    content,
                                                                threadId:   threadId)
        sendLocationMessage.delegate = self
        sendLocationMessage.create(uniqueId: { (sendLocationMessageUniqueId) in
            let myText = "sendLocationMessage uniqueId = \(sendLocationMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
            self.downloadFileUniqueId = sendLocationMessageUniqueId
            self.uploadFileUniqueId = sendLocationMessageUniqueId
        }, downloadProgress: { (progress) in
            if self.isProgressActive {
                self.myProgress = progress
            } else {
                self.isProgressActive = true
                let myText = "downloadFile Progress:"
                self.updateText(cellText: myText, cellHeight: 70, cellColor: .lightGray)
            }
        }, uploadProgress: { (progress) in
            if self.isProgressActive {
                self.myProgress = progress
            } else {
                self.isProgressActive = true
                let myText = "uploadFile Progress:"
                self.updateText(cellText: myText, cellHeight: 70, cellColor: .lightGray)
            }
        }, serverSentResponse: { (sent) in
            let myText = "sendLocationMessage sent response = \(sent.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverDeliverResponse: { (deliver) in
            let myText = "sendLocationMessage deliver response = \(deliver.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (seen) in
            let myText = "sendLocationMessage seen response = \(seen.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
        
    }
    
    
    // File Managements
    // (4, 0)
    func implementReplyFileMessage() {
        var fileName:   String? = nil
        var content:    String? = nil
        let repliedTo:  Int?    = Int(input3TextField.text ?? "")
        let threadId:   Int?    = Int(input4TextField.text ?? "")
        
        if let txt = input1TextField.text {
            if (txt != "") && (txt.first != " ") { fileName = txt }
        }
        if let txt = input2TextField.text {
            if (txt != "") && (txt.first != " ") { content = txt }
        }
        let sendFileMessage = ReplyFileMessageAutomation(content:   content,
                                                         data:      nil,
                                                         fileName:  fileName,
                                                         threadId:  threadId,
                                                         repliedTo: repliedTo,
                                                         uniqueId:  nil)
        sendFileMessage.delegate = self
        sendFileMessage.create(uniqueId: { (replyFileMessageUniqueId) in
            let myText = "replyFileMessage uniqueId = \(replyFileMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
            self.uploadFileUniqueId = replyFileMessageUniqueId
        }, progress: { (progress) in
            if self.isProgressActive {
                self.myProgress = progress
            } else {
                self.isProgressActive = true
                let myText = "uploadFile Progress:"
                self.updateText(cellText: myText, cellHeight: 70, cellColor: .lightGray)
            }
        }, serverSentResponse: { (sent) in
            let myText = "replyFileMessage sent response = \(sent.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverDeliverResponse: { (deliver) in
            let myText = "replyFileMessage deliver response = \(deliver.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (seen) in
            let myText = "replyFileMessage seen response = \(seen.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (4, 1)
    func implementSendFileMessage() {
        var fileName:   String? = nil
        var content:    String? = nil
        let threadId:   Int?    = Int(input3TextField.text ?? "")
        
        if let txt = input1TextField.text {
            if (txt != "") && (txt.first != " ") { fileName = txt }
        }
        if let txt = input2TextField.text {
            if (txt != "") && (txt.first != " ") { content = txt }
        }
        let sendFileMessage = SendFileMessageAutomation(content:    content,
                                                        data:       nil,
                                                        fileName:   fileName,
                                                        threadId:   threadId,
                                                        uniqueId:   nil)
        sendFileMessage.delegate = self
        sendFileMessage.create(uniqueId: { (sendFileMessageUniqueId) in
            let myText = "sendFileMessage uniqueId = \(sendFileMessageUniqueId)"
            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
            self.uploadFileUniqueId = sendFileMessageUniqueId
        }, progress: { (progress) in
            if self.isProgressActive {
                self.myProgress = progress
            } else {
                self.isProgressActive = true
                let myText = "uploadFile Progress:"
                self.updateText(cellText: myText, cellHeight: 70, cellColor: .lightGray)
            }
        }, serverSentResponse: { (sent) in
            let myText = "sendFileMessage sent response = \(sent.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }, serverDeliverResponse: { (deliver) in
            let myText = "sendFileMessage deliver response = \(deliver.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }) { (seen) in
            let myText = "sendFileMessage seen response = \(seen.returnDataAsJSON())"
            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
        }
    }
    
    // (4, 2)
    func implementUploadFile() {
//        var fileName:    String? = nil
//        if let txt = input1TextField.text {
//            if (txt != "") && (txt.first != " ") { fileName = txt }
//        }
//        let threadId:   Int?    = Int(input2TextField.text ?? "")
//
//        let uploadFile = UploadFileAutomation(data:     nil,
//                                              fileName: fileName,
//                                              threadId: threadId,
//                                              uniqueId: nil)
//        uploadFile.delegate = self
//        uploadFile.create(uniqueId: { (uploadFileUniqueId) in
//            let myText = "uploadFile uniqueId = \(uploadFileUniqueId)"
//            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
//            self.uploadFileUniqueId = uploadFileUniqueId
//        }, progress: { (progress) in
//            if self.isProgressActive {
//                self.myProgress = progress
//            } else {
//                self.isProgressActive = true
//                let myText = "uploadFile Progress:"
//                self.updateText(cellText: myText, cellHeight: 70, cellColor: .lightGray)
//            }
//        }) { (uploadFileServerResponse) in
//            self.progressCell = -1
//            self.isProgressActive = false
//            let myText = "uploadFile response = \(uploadFileServerResponse.returnDataAsJSON())"
//            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
//        }
    }
    
    // (4, 3)
    func implementUploadImage() {
        pickerController.delegate = self
        pickerController.allowsEditing = true
        self.present(pickerController, animated: true, completion: nil)
    }
    
}



// MARK: - CollectionView methods
extension MyChatViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return logArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (logBackgroundColor[indexPath.item] != UIColor.lightGray) {
            let normalCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MyCollectionViewCell
            normalCell.backgroundColor = logBackgroundColor[indexPath.item]
            normalCell.myTextView.text = logArr[indexPath.item]
            return normalCell
        } else {
            progressCell = indexPath.item
            let uploadCell = collectionView.dequeueReusableCell(withReuseIdentifier: uploadCellId, for: indexPath) as! MyCollectionViewUploadCell
            uploadCell.backgroundColor = logBackgroundColor[indexPath.item]
            uploadCell.myTextView.text = logArr[indexPath.item]
            uploadCell.spaceProgressView.progress = myProgress
            uploadCell.cancelUploadButton.addTarget(self, action: #selector(cancelUpload), for: UIControl.Event.touchUpInside)
            uploadCell.pauseUploadButton.addTarget(self, action: #selector(pauseUpload), for: UIControl.Event.touchUpInside)
            return uploadCell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cgfloatHeight: CGFloat = CGFloat(logHeightArr[indexPath.item])
        return CGSize(width: view.frame.width - 32, height: cgfloatHeight)
    }
    
}



// MARK: - PickerViewDelegate methods
extension MyChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
//        var selectedImage: UIImage?
//        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
//            selectedImage = editedImage
//        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            selectedImage = originalImage
//        }
//        picker.dismiss(animated: true, completion: nil)
//
//        var fileName:    String? = nil
//        if let txt = input1TextField.text {
//            if (txt != "") && (txt.first != " ") { fileName = txt }
//        }
//
//        let uploadImge = UploadImageAutomation(image: selectedImage, fileName: fileName, threadId: nil, uniqueId: nil)
//        uploadImge.delegate = self
//        uploadImge.create(uniqueId: { (uploadImageUniqueId) in
//            let myText = "uploadImage uniqueId = \(uploadImageUniqueId)"
//            self.updateText(cellText: myText, cellHeight: 50, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
//            self.uploadImageUniqueId = uploadImageUniqueId
//        }, progress: { (progress) in
//            if self.isProgressActive {
//                self.myProgress = progress
//            } else {
//                self.isProgressActive = true
//                let myText = "uploadImage Progress:"
//                self.updateText(cellText: myText, cellHeight: 70, cellColor: .lightGray)
//            }
//        }) { (uploadImageServerResponse) in
//            self.progressCell = -1
//            self.isProgressActive = false
//            let myText = "uploadImage response = \(uploadImageServerResponse.returnDataAsJSON())"
//            self.updateText(cellText: myText, cellHeight: 120, cellColor: UIColor.init().hexToRGB(hex: "#81ecec", alpha: 1))
//        }
        
    }
}






protocol MoreInfoDelegate: class {
    
    func newInfo(type: String, message: String, lineNumbers: Int)
    
}












