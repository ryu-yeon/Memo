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
    
    let repository = MemoRepository()
    
    var task: Memo?
    
    var titleText = ""
    
    var contentText: String?
    
    var contentArray: [String] = []
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateMemo()
        
        if contentArray.count > 0 {
            
            if let task = task {
                repository.updateTask(task: task, title: titleText, content: contentText)
            } else {
                repository.saveTask(title: titleText, content: contentText)
            }
        }
    }
    
    override func configure() {

        mainView.userTextView.text = (task?.title ?? "") + "\n" + (task?.content ?? "")
        
        mainView.userTextView.becomeFirstResponder()
        
        let sharedButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(sharedButtonClicked))
        let saveButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(saveButtonClicked))
        navigationItem.rightBarButtonItems = [saveButton, sharedButton]
    }
    
    @objc func saveButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func sharedButtonClicked() {
        
        guard let sharedText = mainView.userTextView.text else { return }
        
        let vc = UIActivityViewController(activityItems: [sharedText], applicationActivities: [])
        present(vc, animated: true)
    }
    
    func updateMemo() {
        contentArray = mainView.userTextView.text.split(separator: "\n").map{String($0)}
        
        
        if contentArray.count > 1 {
            titleText = contentArray[0]
            contentText = ""
            for i in 1...contentArray.count - 1 {
                contentText! += contentArray[i]
                if i != contentArray.count - 1 {
                    contentText! += "\n"
                }
            }
        } else if contentArray.count == 0 {
            if let task = task {
                repository.deleteTask(task: task)
            }
        } else {
            titleText = contentArray[0]
        }
    }
}
