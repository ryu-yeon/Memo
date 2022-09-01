//
//  RealmModel.swift
//  Memo
//
//  Created by 유연탁 on 2022/08/31.
//

import Foundation

import RealmSwift

class Memo: Object {
    @Persisted var title: String
    @Persisted var content: String?
    @Persisted var registerDate: Date
    @Persisted var isCompose: Bool
    
    @Persisted(primaryKey: true) var objectId: ObjectId
    
    convenience init(title: String, content: String?, registerDate: Date, isCompose: Bool) {
        self.init()
        self.title = title
        self.content = content
        self.registerDate = Date()
        self.isCompose = false
    }
}