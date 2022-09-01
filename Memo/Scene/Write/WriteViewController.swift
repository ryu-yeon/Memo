//
//  WriteViewController.swift
//  Memo
//
//  Created by 유연탁 on 2022/08/31.
//

import UIKit

import RealmSwift

class WriteViewController: BaseViewController {
    
    let mainView = WriteView()
    
    let localRealm = try! Realm()
    
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configure() {
        let sharedButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(sharedButtonClicked))
        let saveButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(saveButtonClicked))
        navigationItem.rightBarButtonItems = [saveButton, sharedButton]
        
    }
    
    @objc func saveButtonClicked() {
        try! localRealm.write {
            let task = Memo(title: "안녕하세요", content: nil, registerDate: Date(), isCompose: true)
            localRealm.add(task)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func sharedButtonClicked() {
        
    }
}
