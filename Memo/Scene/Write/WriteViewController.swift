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
    
    var titleText = ""
    
    var contentText = ""
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveButtonClicked()
    }
    
    override func configure() {
        let sharedButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(sharedButtonClicked))
        let saveButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(saveButtonClicked))
        navigationItem.rightBarButtonItems = [saveButton, sharedButton]
    }
    
    @objc func saveButtonClicked() {
        setContent()
        try! localRealm.write {
            let task = Memo(title: titleText, content: contentText, registerDate: Date(), isCompose: false)
            localRealm.add(task)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func sharedButtonClicked() {
        
    }
    
    func setContent() {
        let contentArray = mainView.userTextView.text.split(separator: "\n").map{String($0)}
        
        titleText = contentArray[0]
        for i in 1...contentArray.count - 1 {
            contentText += contentArray[i]
            if i != contentArray.count - 1 {
                contentText += "\n"
            }
        }
    }
}
