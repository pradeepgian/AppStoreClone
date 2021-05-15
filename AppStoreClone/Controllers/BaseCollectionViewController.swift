//
//  BaseCollectionViewController.swift
//  AppStoreClone
//
//  Created by Pradeep Gianchandani on 14/05/21.
//

import UIKit

class BaseCollectionViewController: UICollectionViewController {
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
