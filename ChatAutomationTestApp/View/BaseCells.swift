//
//  BaseCells.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import UIKit

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



class MyCollectionViewUploadCell: UICollectionViewCell {
    
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
        return mb
    }()
    
    
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupView() {
        addSubview(myTextView)
        addSubview(spaceProgressView)
        addSubview(cancelUploadButton)
        addSubview(pauseUploadButton)
        
        spaceProgressView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        spaceProgressView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 4).isActive = true
        spaceProgressView.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -4).isActive = true
        spaceProgressView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        cancelUploadButton.bottomAnchor.constraint(equalTo: spaceProgressView.topAnchor, constant: -4).isActive = true
        cancelUploadButton.rightAnchor.constraint(equalTo: spaceProgressView.rightAnchor).isActive = true
        cancelUploadButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        cancelUploadButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        pauseUploadButton.bottomAnchor.constraint(equalTo: cancelUploadButton.bottomAnchor).isActive = true
        pauseUploadButton.topAnchor.constraint(equalTo: cancelUploadButton.topAnchor).isActive = true
        pauseUploadButton.rightAnchor.constraint(equalTo: cancelUploadButton.leftAnchor, constant: -10).isActive = true
        pauseUploadButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        myTextView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        myTextView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2).isActive = true
        myTextView.rightAnchor.constraint(equalTo: pauseUploadButton.leftAnchor, constant: -2).isActive = true
        myTextView.bottomAnchor.constraint(equalTo: spaceProgressView.topAnchor, constant: -2).isActive = true
        
    }
    
}

