//
//  BaseCell.swift
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

