//
//  MemoListTableViewCell.swift
//  Memo
//
//  Created by 유연탁 on 2022/08/31.
//

import UIKit

import SnapKit

class MemoListTableViewCell: BaseTableViewCell {
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .label
        view.font = .boldSystemFont(ofSize: 24)
        return view
    }()
    
    let dateLabel: UILabel = {
        let view = UILabel()
        view.textColor = .systemGray
        view.font = .systemFont(ofSize: 16)
        return view
    }()
    
    let contentLabel: UILabel = {
       let view = UILabel()
        view.textColor = .systemGray
        view.font = .systemFont(ofSize: 16)
        return view
    }()
    
    override func configureUI() {
        self.backgroundColor = .systemGray6
        [titleLabel, dateLabel, contentLabel].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(24)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.height.equalTo(26)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(20)
            make.height.equalTo(20)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.top)
            make.leading.equalTo(dateLabel.snp.trailing)
            make.trailing.equalTo(-20)
            make.bottom.equalTo(dateLabel.snp.bottom)
        }
    }
}
