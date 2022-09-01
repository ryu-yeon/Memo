//
//  WriteView.swift
//  Memo
//
//  Created by 유연탁 on 2022/08/31.
//

import UIKit

import SnapKit

class WriteView: BaseView {
    
    let userTextView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 20)
        return view
    }()
    
    override func configureUI() {
        self.backgroundColor = .white
        [userTextView].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        userTextView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.leading.equalTo(20)
            make.trailing.bottom.equalTo(-20)
        }
    }
}
