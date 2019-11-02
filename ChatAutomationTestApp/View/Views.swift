//
//  Views.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import UIKit

// Views
extension MyChatViewController {
    
    func setupViews() {
        
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        activityIndicator.color = UIColor.init().hexToRGB(hex: "#d63031", alpha: 1)
        
        myLogCollectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        myLogCollectionView.register(MyCollectionViewUploadCell.self, forCellWithReuseIdentifier: uploadCellId)
        myLogCollectionView.delegate = self
        myLogCollectionView.dataSource = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        view.addSubview(runButton)
        view.addSubview(input1TextField)
        view.addSubview(input2TextField)
        view.addSubview(input3TextField)
        view.addSubview(input4TextField)
        view.addSubview(input5TextField)
        view.addSubview(input6TextField)
        view.addSubview(input7TextField)
        view.addSubview(input8TextField)
        view.addSubview(pickerView)
        view.addSubview(logView)
        logView.addSubview(myLogCollectionView)
        
        pickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        pickerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        pickerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -78).isActive = true
        pickerView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        
        runButton.topAnchor.constraint(equalTo: pickerView.topAnchor, constant: 2).isActive = true
        runButton.bottomAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: -2).isActive = true
        runButton.leftAnchor.constraint(equalTo: pickerView.rightAnchor, constant: 8).isActive = true
        runButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        
        let inputTextFieldWidth = ((view.frame.width - 16 - 12) / 4)
        
        input1TextField.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 8).isActive = true
        input1TextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        input1TextField.heightAnchor.constraint(equalToConstant: 32).isActive = true
        input1TextField.widthAnchor.constraint(equalToConstant: inputTextFieldWidth).isActive = true
        
        input2TextField.topAnchor.constraint(equalTo: input1TextField.topAnchor).isActive = true
        input2TextField.leftAnchor.constraint(equalTo: input1TextField.rightAnchor, constant: 4).isActive = true
        input2TextField.bottomAnchor.constraint(equalTo: input1TextField.bottomAnchor).isActive = true
        input2TextField.widthAnchor.constraint(equalToConstant: inputTextFieldWidth).isActive = true
        
        input3TextField.topAnchor.constraint(equalTo: input1TextField.topAnchor).isActive = true
        input3TextField.leftAnchor.constraint(equalTo: input2TextField.rightAnchor, constant: 4).isActive = true
        input3TextField.bottomAnchor.constraint(equalTo: input1TextField.bottomAnchor).isActive = true
        input3TextField.widthAnchor.constraint(equalToConstant: inputTextFieldWidth).isActive = true
        
        input4TextField.topAnchor.constraint(equalTo: input1TextField.topAnchor).isActive = true
        input4TextField.leftAnchor.constraint(equalTo: input3TextField.rightAnchor, constant: 4).isActive = true
        input4TextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -4).isActive = true
        input4TextField.bottomAnchor.constraint(equalTo: input1TextField.bottomAnchor).isActive = true
        
        input5TextField.topAnchor.constraint(equalTo: input1TextField.bottomAnchor, constant: 2).isActive = true
        input5TextField.leftAnchor.constraint(equalTo: input1TextField.leftAnchor).isActive = true
        input5TextField.heightAnchor.constraint(equalToConstant: 32).isActive = true
        input5TextField.widthAnchor.constraint(equalToConstant: inputTextFieldWidth).isActive = true
        
        input6TextField.topAnchor.constraint(equalTo: input5TextField.topAnchor).isActive = true
        input6TextField.leftAnchor.constraint(equalTo: input2TextField.leftAnchor).isActive = true
        input6TextField.rightAnchor.constraint(equalTo: input2TextField.rightAnchor).isActive = true
        input6TextField.bottomAnchor.constraint(equalTo: input5TextField.bottomAnchor).isActive = true
        
        input7TextField.topAnchor.constraint(equalTo: input5TextField.topAnchor).isActive = true
        input7TextField.leftAnchor.constraint(equalTo: input3TextField.leftAnchor).isActive = true
        input7TextField.rightAnchor.constraint(equalTo: input3TextField.rightAnchor).isActive = true
        input7TextField.bottomAnchor.constraint(equalTo: input5TextField.bottomAnchor).isActive = true
        
        input8TextField.topAnchor.constraint(equalTo: input5TextField.topAnchor).isActive = true
        input8TextField.leftAnchor.constraint(equalTo: input4TextField.leftAnchor).isActive = true
        input8TextField.rightAnchor.constraint(equalTo: input4TextField.rightAnchor).isActive = true
        input8TextField.bottomAnchor.constraint(equalTo: input5TextField.bottomAnchor).isActive = true
        
        logView.topAnchor.constraint(equalTo: input5TextField.bottomAnchor, constant: 8).isActive = true
        logView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        logView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        logView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        
        myLogCollectionView.topAnchor.constraint(equalTo: logView.topAnchor, constant: 4).isActive = true
        myLogCollectionView.leftAnchor.constraint(equalTo: logView.leftAnchor, constant: 8).isActive = true
        myLogCollectionView.rightAnchor.constraint(equalTo: logView.rightAnchor, constant: -8).isActive = true
        myLogCollectionView.bottomAnchor.constraint(equalTo: logView.bottomAnchor, constant: -8).isActive = true
        
    }
    
}

