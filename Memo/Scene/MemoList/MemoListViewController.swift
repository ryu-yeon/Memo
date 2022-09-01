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
        
        navigationItem.title = "\(tasks.count)개의 메모"
    }
    
    override func configure() {
        
        setSearchController()
        
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        mainView.tableView.register(MemoListTableViewCell.self, forCellReuseIdentifier: MemoListTableViewCell.reusableIdentifier)
        
        mainView.toolBar.items = [UIBarButtonItem.flexibleSpace(), UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(writeButtonClicked))]
        
        tasks = localRealm.objects(Memo.self).sorted(byKeyPath: "registerDate", ascending: true)
    }
    
    @objc func writeButtonClicked() {
        let vc = WriteViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.largeTitleDisplayMode = .always
        searchController.searchBar.placeholder = "검색"
    }
}

extension MemoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.reusableIdentifier, for: indexPath) as? MemoListTableViewCell else { return UITableViewCell() }
        
        cell.titleLabel.text = tasks[indexPath.row].title
        cell.contentLabel.text = tasks[indexPath.row].content
        
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

extension MemoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text != "" {
            tasks = localRealm.objects(Memo.self).filter("title CONTAINS[c] '\(text)'")
        } else {
            tasks = localRealm.objects(Memo.self).sorted(byKeyPath: "registerDate", ascending: true)
        }
        mainView.tableView.reloadData()
    }

}
