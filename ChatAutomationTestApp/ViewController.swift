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
    
    
    
    
    
    
}






// Views
extension MyViewController {
    
    func setupViews() {
        
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        myLogCollectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        myLogCollectionView.delegate = self
        myLogCollectionView.dataSource = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        view.addSubview(pickerView)
        view.addSubview(sendPingButton)
        view.addSubview(logView)
        logView.addSubview(myLogCollectionView)
        
        pickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        pickerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        pickerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        pickerView.heightAnchor.constraint(equalToConstant: 128).isActive = true
        
        sendPingButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 8).isActive = true
        sendPingButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        sendPingButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        sendPingButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        logView.topAnchor.constraint(equalTo: sendPingButton.bottomAnchor, constant: 16).isActive = true
        logView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        logView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        logView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        
        myLogCollectionView.topAnchor.constraint(equalTo: logView.topAnchor, constant: 8).isActive = true
        myLogCollectionView.leftAnchor.constraint(equalTo: logView.leftAnchor, constant: 8).isActive = true
        myLogCollectionView.rightAnchor.constraint(equalTo: logView.rightAnchor, constant: -8).isActive = true
        myLogCollectionView.bottomAnchor.constraint(equalTo: logView.bottomAnchor, constant: -8).isActive = true
        
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



// MARK: Base Cell for collectionView
class MyCollectionViewCell: UICollectionViewCell {
    
    let myTextView: UITextView = {
        let mtv = UITextView()
        mtv.translatesAutoresizingMaskIntoConstraints = false
        mtv.backgroundColor = UIColor.clear
        return mtv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        addSubview(myTextView)
        myTextView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        myTextView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2).isActive = true
        myTextView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -2).isActive = true
        myTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}






// MARK: Chat delegatews
extension MyViewController: ChatDelegates {
    
    func chatConnected() {
        //        print("@@MyLog(Chat): connect")
    }
    
    func chatDisconnect() {
        //        print("@@MyLog(Chat): disconnect")
    }
    
    func chatReconnect() {
        //        print("@@MyLog(Chat): reconnect")
    }
    
    func chatThreadEvents() {
        //        print("@@MyLog(Chat): thread events")
    }
    
    func chatReady() {
        //        print("@@MyLog(Chat): chat ready")
    }
    
    func chatError(errorCode: Int, errorMessage: String, errorResult: Any?) {
        //        print("@@MyLog(Chat): error: errCode = \(errorCode), errMsg = \(errorMessage)")
    }
    
    func chatState(state: Int) {
        //        print("@@MyLog(Chat): chat state = \(state)")
    }
    
    func chatDeliver(messageId: Int, ownerId: Int) {
        //        print("@@MyLog(Chat): deliver with messageId = \(messageId), and ownerId = \(ownerId)")
    }
    
    func messageEvents(type: String, result: JSON) {
        //        print("@@MyLog(Chat): message events with \n type = \(type) \n result: \(result)")
        
        //        print("\n\n\n****************************")
        //        print("****************************")
        //        print("****************************")
        //        print("MessageType: \(type)")
        //        print("result in JSON: \n \(result)")
        //        print("****************************")
        //        print("****************************")
        //        print("****************************\n\n\n")
    }
    
    func threadEvents(type: String, result: JSON) {
        //        print("@@MyLog:(Chat): ThreadEvents: \n type = \(type) , \n result: \(result) \n")
        
        if type == "THREAD_UNREAD_COUNT_UPDATED" {
            print("\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
            print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
            print("THREAD_UNREAD_COUNT_UPDATED : ")
            print("\(result)")
            print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
            print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n")
        }
        
        if (type == "THREAD_LAST_ACTIVITY_TIME") {
            print("\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
            print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
            print("THREAD_LAST_ACTIVITY_TIME : ")
            print("\(result)")
            print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
            print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n")
        }
        
    }
    
    
}













