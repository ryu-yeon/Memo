//
//  PopUpViewController.swift
//  Memo
//
//  Created by 유연탁 on 2022/08/31.
//

import UIKit

class PopUpViewController: BaseViewController {
    
    let mainView = PopUpView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configure() {
        mainView.okButton.addTarget(self, action: #selector(okButtonClicked), for: .touchUpInside)
    }
    
    @objc func okButtonClicked() {
        dismiss(animated: true)
    }
}
