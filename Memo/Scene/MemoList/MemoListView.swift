//
//  MemoListView.swift
//  Memo
//
//  Created by 유연탁 on 2022/08/31.
//

import UIKit

import SnapKit

class MemoListView: BaseView {
    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        return view
    }()
    
    let toolBar: UIToolbar = {
        let view = UIToolbar()
        view.backgroundColor = .white
        return view
    }()
    
    override func configureUI() {
        self.backgroundColor = .white
        [tableView, toolBar].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalTo(self)
            make.bottom.equalTo(toolBar.snp.top)
        }
        
        toolBar.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.leading.trailing.equalTo(self)
            make.bottom.equalTo(-40)
            make.height.equalTo(40)
        }
    }
}
