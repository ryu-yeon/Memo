//
//  WriteView.swift
//  Memo
//
//  Created by 유연탁 on 2022/08/31.
//

import UIKit

import SnapKit

class WriteView: BaseView {
    
    let viewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let userTextView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 20)
        view.backgroundColor = .white
        return view
    }()
    
    override func configureUI() {
        self.backgroundColor = .systemGray6
        [viewContainer, userTextView].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        viewContainer.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalTo(self)
        }
        
        userTextView.snp.makeConstraints { make in
            make.top.equalTo(viewContainer.snp.top).offset(20)
            make.leading.equalTo(viewContainer.snp.leading).inset(20)
            make.trailing.equalTo(viewContainer.snp.trailing).inset(20)
            make.bottom.equalTo(viewContainer.snp.bottom)
        }
    }
}
