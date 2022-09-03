//
//  MemoListViewController.swift
//  Memo
//
//  Created by 유연탁 on 2022/08/31.
//

import UIKit

import RealmSwift
import Toast

class MemoListViewController: BaseViewController {
    
    let mainView = MemoListView()
    
    var tasks: Results<Memo>!
    
    let localRealm = try! Realm()
    
    let numberFormat = NumberFormatter()
    
    let dateFormat = DateFormatter()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("Realm is located at:", localRealm.configuration.fileURL!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        let vc = PopUpViewController()
//        vc.modalPresentationStyle = .overFullScreen
//        present(vc, animated: true)
        
        mainView.tableView.reloadData()
        
        numberFormat.numberStyle = .decimal
        let memoCount = numberFormat.string(for: tasks.count)
        navigationItem.title = (memoCount ?? "0") + "개의 메모"
    }
    
    override func configure() {
        
        setSearchController()
        
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        mainView.tableView.register(MemoListTableViewCell.self, forCellReuseIdentifier: MemoListTableViewCell.reusableIdentifier)
        
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        let writeButton = UIButton()
        writeButton.frame = CGRect(x: 40, y: 10, width: 40, height: 40)
        writeButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        writeButton.contentVerticalAlignment = .fill
        writeButton.contentHorizontalAlignment = .fill
        
        view.addSubview(writeButton)
        writeButton.addTarget(self, action: #selector(writeButtonClicked), for: .touchUpInside)
        
        mainView.toolBar.items = [UIBarButtonItem.flexibleSpace(),  UIBarButtonItem(customView: view)]
        
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
        navigationController?.navigationBar.backgroundColor = .systemGray6
        
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
            cell.contentLabel.text = pintasks[indexPath.row].content ?? "추가 텍스트 없음"
            if Calendar.current.isDateInToday(pintasks[indexPath.row].registerDate) {
                dateFormat.dateFormat = "a hh:mm"
                
            } else if Date(timeIntervalSinceNow: -7 * 24 * 60 * 60) <= pintasks[indexPath.row].registerDate {
                dateFormat.dateFormat = "EEEE"
            } else {
                dateFormat.dateFormat = "yyyy. MM. dd a hh:mm"
            }
            cell.dateLabel.text = dateFormat.string(from: pintasks[indexPath.row].registerDate)
            
        } else if indexPath.section == 1{
            let memo = self.tasks.filter("isCompose = false").sorted(byKeyPath: "registerDate", ascending: true)
            cell.titleLabel.text = memo[indexPath.row].title
            cell.contentLabel.text = memo[indexPath.row].content ?? "추가 텍스트 없음"
            
            if Calendar.current.isDateInToday(memo[indexPath.row].registerDate) {
                dateFormat.dateFormat = "a hh:mm"
                
            } else if Date(timeIntervalSinceNow: -7 * 24 * 60 * 60) <= memo[indexPath.row].registerDate {

                dateFormat.dateFormat = "EEEE"
            } else {
                dateFormat.dateFormat = "yyyy. MM. dd a hh:mm"
            }
            cell.dateLabel.text = dateFormat.string(from: memo[indexPath.row].registerDate)
                    
        } else {
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WriteViewController()
        
        if indexPath.section == 0 {
            vc.task = tasks.filter("isCompose = true")[indexPath.row]
        } else {
            vc.task = tasks.filter("isCompose = false")[indexPath.row]
        }
        
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
                if self.tasks.filter("isCompose = true").count < 5 {
                    try! self.localRealm.write {
                        self.tasks.filter("isCompose = false").sorted(byKeyPath: "registerDate", ascending: true)[indexPath.row].isCompose = true
                    }
                    self.mainView.tableView.reloadData()
                } else {
                    self.view.makeToast("최대 5개까지 메모를 고정할 수 있습니다.", duration: 2.0, position: .center, style: ToastStyle())
                }
            }
            composeButton.image = UIImage(systemName: "pin.slash.fill")
            composeButton.backgroundColor = .systemOrange
            return UISwipeActionsConfiguration(actions: [composeButton])
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let removeButton = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            
            let alert = UIAlertController(title: "삭제", message: "메모를 정말 삭제하시겠습니까?", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "확인", style: .destructive) { alert in
                try! self.localRealm.write {
                    self.localRealm.delete(self.tasks[indexPath.row])
                }
                self.mainView.tableView.reloadData()
            }
            
            let cancel = UIAlertAction(title: "취소", style: .default)
            
            [ok, cancel].forEach {
                alert.addAction($0)
            }
            self.present(alert, animated: true)
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
        if section == 0 && self.tasks.filter("isCompose = true").count == 0 {
            return 0
        } else if section == 1 && self.tasks.filter("isCompose = false").count == 0 {
            return 0
        } else {
            return 40
        }
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
