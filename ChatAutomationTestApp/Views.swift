//
//  Views.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import UIKit

// Views
extension MyViewController {
    
    func setupViews() {
        
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        myLogCollectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        myLogCollectionView.delegate = self
        myLogCollectionView.dataSource = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        view.addSubview(tokenTextField)
        view.addSubview(sendPingButton)
        view.addSubview(input1TextField)
        view.addSubview(input2TextField)
        view.addSubview(input3TextField)
        view.addSubview(input4TextField)
        view.addSubview(pickerView)
        view.addSubview(logView)
        logView.addSubview(myLogCollectionView)
        
        tokenTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        tokenTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        tokenTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        tokenTextField.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        sendPingButton.topAnchor.constraint(equalTo: tokenTextField.bottomAnchor, constant: 4).isActive = true
        sendPingButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        sendPingButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        sendPingButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        let textFieldWidth = ((view.frame.width - 16 - 12) / 4)
        
        input1TextField.topAnchor.constraint(equalTo: sendPingButton.bottomAnchor, constant: 8).isActive = true
        input1TextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        input1TextField.heightAnchor.constraint(equalToConstant: 32).isActive = true
        input1TextField.widthAnchor.constraint(equalToConstant: textFieldWidth).isActive = true
        
        input2TextField.topAnchor.constraint(equalTo: input1TextField.topAnchor).isActive = true
        input2TextField.leftAnchor.constraint(equalTo: input1TextField.rightAnchor, constant: 4).isActive = true
        input2TextField.bottomAnchor.constraint(equalTo: input1TextField.bottomAnchor).isActive = true
        input2TextField.widthAnchor.constraint(equalToConstant: textFieldWidth).isActive = true
        
        input3TextField.topAnchor.constraint(equalTo: input1TextField.topAnchor).isActive = true
        input3TextField.leftAnchor.constraint(equalTo: input2TextField.rightAnchor, constant: 4).isActive = true
        input3TextField.bottomAnchor.constraint(equalTo: input1TextField.bottomAnchor).isActive = true
        input3TextField.widthAnchor.constraint(equalToConstant: textFieldWidth).isActive = true
        
        input4TextField.topAnchor.constraint(equalTo: input1TextField.topAnchor).isActive = true
        input4TextField.leftAnchor.constraint(equalTo: input3TextField.rightAnchor, constant: 4).isActive = true
        input4TextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -4).isActive = true
        input4TextField.bottomAnchor.constraint(equalTo: input1TextField.bottomAnchor).isActive = true
        
        pickerView.topAnchor.constraint(equalTo: input1TextField.bottomAnchor, constant: 4).isActive = true
        pickerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        pickerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        pickerView.heightAnchor.constraint(equalToConstant: 108).isActive = true
        
        logView.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 8).isActive = true
        logView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        logView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        logView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        
        myLogCollectionView.topAnchor.constraint(equalTo: logView.topAnchor, constant: 4).isActive = true
        myLogCollectionView.leftAnchor.constraint(equalTo: logView.leftAnchor, constant: 8).isActive = true
        myLogCollectionView.rightAnchor.constraint(equalTo: logView.rightAnchor, constant: -8).isActive = true
        myLogCollectionView.bottomAnchor.constraint(equalTo: logView.bottomAnchor, constant: -8).isActive = true
        
    }
    
}

