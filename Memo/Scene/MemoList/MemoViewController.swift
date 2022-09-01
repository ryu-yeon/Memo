//
//  MemoListViewController.swift
//  Memo
//
//  Created by 유연탁 on 2022/08/31.
//

import UIKit

import RealmSwift

class MemoListViewController: BaseViewController {
    
    let mainView = MemoListView()
    
    var tasks: Results<Memo>!
    
    let localRealm = try! Realm()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("Realm is located at:", localRealm.configuration.fileURL!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let vc = PopUpViewController()
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
        mainView.tableView.reloadData()
    }
    
    override func configure() {
        
        navigationItem.title = "메모"
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        mainView.tableView.register(MemoListTableViewCell.self, forCellReuseIdentifier: MemoListTableViewCell.reusableIdentifier)

        
        mainView.toolBar.items = [UIBarButtonItem.flexibleSpace(), UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(writeButtonClicked))]
        
        tasks = localRealm.objects(Memo.self)
    }
    
    @objc func writeButtonClicked() {
        let vc = WriteViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MemoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.reusableIdentifier, for: indexPath) as? MemoListTableViewCell else { return UITableViewCell() }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WriteViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let composeButton = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            // 고정
            self.mainView.tableView.reloadData()
        }
        
        composeButton.image = UIImage(systemName: "pin.fill")
        composeButton.backgroundColor = .systemOrange
        
        return UISwipeActionsConfiguration(actions: [composeButton])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let removeButton = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            // 삭제
            self.mainView.tableView.reloadData()
        }
        
        removeButton.image = UIImage(systemName: "trash.fill")
        removeButton.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [removeButton])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
