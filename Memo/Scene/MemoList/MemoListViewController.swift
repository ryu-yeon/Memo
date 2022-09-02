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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            let pintasks = self.tasks.filter("isCompose = true")
            return pintasks.count
        }
        else {
            let memo = self.tasks.filter("isCompose = false")
            return memo.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.reusableIdentifier, for: indexPath) as? MemoListTableViewCell else { return UITableViewCell() }
        if indexPath.section == 0 {
            let pintasks = self.tasks.filter("isCompose = true").sorted(byKeyPath: "registerDate", ascending: true)
            cell.titleLabel.text = pintasks[indexPath.row].title
            cell.contentLabel.text = pintasks[indexPath.row].content
        } else if indexPath.section == 1{
            let memo = self.tasks.filter("isCompose = false").sorted(byKeyPath: "registerDate", ascending: true)
            cell.titleLabel.text = memo[indexPath.row].title
            cell.contentLabel.text = memo[indexPath.row].content
        } else {
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WriteViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 0 {
            let composeButton = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
                try! self.localRealm.write {
                    self.tasks.filter("isCompose = true").sorted(byKeyPath: "registerDate", ascending: true)[indexPath.row].isCompose = false
                }
                self.mainView.tableView.reloadData()
            }
            composeButton.image = UIImage(systemName: "pin.fill")
            composeButton.backgroundColor = .systemOrange
            return UISwipeActionsConfiguration(actions: [composeButton])
            
        } else {
            let composeButton = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
                try! self.localRealm.write {
                    self.tasks.filter("isCompose = false").sorted(byKeyPath: "registerDate", ascending: true)[indexPath.row].isCompose = true
                }
                    self.mainView.tableView.reloadData()
            }
            composeButton.image = UIImage(systemName: "pin.slash.fill")
            composeButton.backgroundColor = .systemOrange
            return UISwipeActionsConfiguration(actions: [composeButton])
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let removeButton = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            try! self.localRealm.write {
                self.localRealm.delete(self.tasks[indexPath.row])
            }
            self.mainView.tableView.reloadData()
        }
        
        removeButton.image = UIImage(systemName: "trash.fill")
        removeButton.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [removeButton])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 300, height: 30)
        if section == 0 {
            label.text = "고정된 메모"
        } else {
            label.text = "메모"
        }
        label.font = .boldSystemFont(ofSize: 28)
        view.addSubview(label)
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
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
