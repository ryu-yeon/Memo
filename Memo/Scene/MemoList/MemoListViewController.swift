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
    
    let repository = MemoRepository()
    
    let numberFormat: NumberFormatter = {
        let format = NumberFormatter()
        format.numberStyle = .decimal
        return format
    }()
    
    let dateFormat = DateFormatter()
    
    var searchTasks: Results<Memo>?
    
    var fixedTasks: Results<Memo>?
    
    var normalTasks: Results<Memo>?
    
    var searchText: String?
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !UserDefaults.standard.bool(forKey: "start") {
            UserDefaults.standard.set(true, forKey: "start")
            let vc = PopUpViewController()
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }
        
        setToolbarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        updateTasks()
        mainView.tableView.reloadData()
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setTitle()
    }
    
    
    override func configure() {
        
        setSearchController()
        
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        mainView.tableView.register(MemoListTableViewCell.self, forCellReuseIdentifier: MemoListTableViewCell.reusableIdentifier)
        
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemGray6
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController?.navigationBar.tintColor = .systemOrange
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func setTitle() {
        let memoCount = numberFormat.string(for: (fixedTasks?.count ?? 0) + (normalTasks?.count ?? 0))
        navigationItem.title = (memoCount ?? "0") + "개의 메모"
    }
    
    func setToolbarButton() {

        if #available(iOS 14.0, *) {
            let view = UIView()
            view.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            let writeButton = UIButton()
            writeButton.frame = CGRect(x: 0, y: -5, width: 30, height: 30)
            writeButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
            writeButton.contentVerticalAlignment = .fill
            writeButton.contentHorizontalAlignment = .fill
            
            view.addSubview(writeButton)
            writeButton.addTarget(self, action: #selector(writeButtonClicked), for: .touchUpInside)
            mainView.toolBar.items = [UIBarButtonItem.flexibleSpace(),  UIBarButtonItem(customView: view)]
        } else {
            let view = UIView()
            view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30)
            let writeButton = UIButton()
            writeButton.frame = CGRect(x: UIScreen.main.bounds.width - 60, y: -5, width: 30, height: 30)
            writeButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
            writeButton.contentVerticalAlignment = .fill
            writeButton.contentHorizontalAlignment = .fill
            
            view.addSubview(writeButton)
            writeButton.addTarget(self, action: #selector(writeButtonClicked), for: .touchUpInside)
            mainView.toolBar.items = [UIBarButtonItem(customView: view)]
        }
    }
    
    @objc func writeButtonClicked() {
        let vc = WriteViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationController?.navigationBar.backgroundColor = .systemGray6
        
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.backButtonTitle = "메모"
        searchController.searchBar.placeholder = "검색"
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")

    }
    
    func updateTasks() {
        fixedTasks = repository.fetchFiterSort(text: "isCompose = true", sort: "registerDate")
        normalTasks = repository.fetchFiterSort(text: "isCompose = false", sort: "registerDate")
    }
}

extension MemoListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && searchTasks == nil {
            return fixedTasks?.count ?? 0
        } else if section == 1 && searchTasks == nil {
            return normalTasks?.count ?? 0
        } else if section == 2 {
            return searchTasks?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.reusableIdentifier, for: indexPath) as? MemoListTableViewCell else { return UITableViewCell() }
        
        dateFormat.locale = Locale(identifier: "ko_KR")
        
        if indexPath.section == 0 {
            
            guard let fixedTasks = fixedTasks else { return UITableViewCell() }
            
            cell.titleLabel.text = fixedTasks[indexPath.row].title
            cell.contentLabel.text = fixedTasks[indexPath.row].content ?? "추가 텍스트 없음"
            if Calendar.current.isDateInToday(fixedTasks[indexPath.row].registerDate) {
                dateFormat.dateFormat = "a hh:mm"
                
            } else if NSCalendar.current.component(.weekOfYear, from: fixedTasks[indexPath.row].registerDate) == NSCalendar.current.component(.weekOfYear, from: Date()) {
                dateFormat.dateFormat = "EEEE"
            } else {
                dateFormat.dateFormat = "yyyy. MM. dd a hh:mm"
            }
            cell.dateLabel.text = dateFormat.string(from: fixedTasks[indexPath.row].registerDate)
            
        } else if indexPath.section == 1 {
            
            guard let normalTasks = normalTasks else { return UITableViewCell() }
            
            cell.titleLabel.text = normalTasks[indexPath.row].title
            cell.contentLabel.text = normalTasks[indexPath.row].content ?? "추가 텍스트 없음"
            
            if Calendar.current.isDateInToday(normalTasks[indexPath.row].registerDate) {
                dateFormat.dateFormat = "a hh:mm"
                
            } else if NSCalendar.current.component(.weekOfYear, from: normalTasks[indexPath.row].registerDate) == NSCalendar.current.component(.weekOfYear, from: Date()) {
                dateFormat.dateFormat = "EEEE"
            } else {
                dateFormat.dateFormat = "yyyy. MM. dd a hh:mm"
            }
            cell.dateLabel.text = dateFormat.string(from: normalTasks[indexPath.row].registerDate)
                    
        } else {
            
            guard let searchTasks = searchTasks else { return UITableViewCell() }
            
            cell.titleLabel.text = searchTasks[indexPath.row].title
            cell.contentLabel.text = searchTasks[indexPath.row].content ?? "추가 텍스트 없음"
            
            if let text = cell.titleLabel.text  {
                
                let attributeString = NSMutableAttributedString(string: text)
                
                attributeString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (text as NSString).range(of: searchText ?? ""))
                
                cell.titleLabel.attributedText = attributeString
            }
            
            if let text = cell.contentLabel.text  {
                
                let attributeString = NSMutableAttributedString(string: text)
                
                attributeString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (text as NSString).range(of: searchText ?? ""))
                
                cell.contentLabel.attributedText = attributeString
            }
            
            if Calendar.current.isDateInToday(searchTasks[indexPath.row].registerDate) {
                dateFormat.dateFormat = "a hh:mm"
            } else if NSCalendar.current.component(.weekOfYear, from: searchTasks[indexPath.row].registerDate) == NSCalendar.current.component(.weekOfYear, from: Date()) {
                        dateFormat.dateFormat = "EEEE"
                
            } else {
                dateFormat.dateFormat = "yyyy. MM. dd a hh:mm"
            }
            cell.dateLabel.text = dateFormat.string(from: searchTasks[indexPath.row].registerDate)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = WriteViewController()
        
        if indexPath.section == 0 {
            vc.task = fixedTasks?[indexPath.row]
        } else if indexPath.section == 1 {
            vc.task = normalTasks?[indexPath.row]
        } else if indexPath.section == 2 {
            navigationItem.backButtonTitle = "검색"
            vc.task = searchTasks?[indexPath.row]
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let composeButton = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            
            if indexPath.section == 0 {
                guard let fixedTasks = self.fixedTasks else { return }
                
                self.repository.updateIsCompose(task: fixedTasks[indexPath.row])
            } else if indexPath.section == 1 {
                if (self.fixedTasks?.count ?? 0) < 5 {
                    
                    guard let normalTasks = self.normalTasks else { return }
                    
                    self.repository.updateIsCompose(task: normalTasks[indexPath.row])
                    
                    self.updateTasks()
                    self.mainView.tableView.reloadData()
                } else {
                    self.view.makeToast("최대 5개까지 메모를 고정할 수 있습니다.", duration: 2.0, position: .center, style: ToastStyle())
                }
            } else {
                guard let searchTasks = self.searchTasks else { return }
                
                if searchTasks[indexPath.row].isCompose == true {
                    
                    self.repository.updateIsCompose(task: searchTasks[indexPath.row])
                    
                    self.updateTasks()
                    self.mainView.tableView.reloadData()
                } else {
                    if (self.fixedTasks?.count ?? 0) < 5 {
                        self.repository.updateIsCompose(task: searchTasks[indexPath.row])
                        
                        self.updateTasks()
                        self.mainView.tableView.reloadData()
                    } else {
                        self.view.makeToast("최대 5개까지 메모를 고정할 수 있습니다.", duration: 2.0, position: .center, style: ToastStyle())
                    }
                }
            }
            self.updateTasks()
            self.mainView.tableView.reloadData()
        }
        
        if indexPath.section == 0 {
            composeButton.image = fixedTasks?[indexPath.row].isCompose == true ? UIImage(systemName: "pin.fill") : UIImage(systemName: "pin.slash.fill")
        } else if indexPath.section == 1 {
            composeButton.image = normalTasks?[indexPath.row].isCompose == true ? UIImage(systemName: "pin.fill") : UIImage(systemName: "pin.slash.fill")
        } else {
            composeButton.image = searchTasks?[indexPath.row].isCompose == true ? UIImage(systemName: "pin.fill") : UIImage(systemName: "pin.slash.fill")
        }
        
        composeButton.backgroundColor = .systemOrange
        return UISwipeActionsConfiguration(actions: [composeButton])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let removeButton = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            
            let alert = UIAlertController(title: "삭제", message: "메모를 정말 삭제하시겠습니까?", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "확인", style: .destructive) { alert in
                
                if indexPath.section == 0 {
                    guard let fixedTasks = self.fixedTasks else { return }
                    
                    self.repository.deleteTask(task: fixedTasks[indexPath.row])
                    
                } else if indexPath.section == 1 {
                    guard let normalTasks = self.normalTasks else { return }
                    
                    self.repository.deleteTask(task: normalTasks[indexPath.row])
                    
                } else {
                    guard let searchTasks = self.searchTasks else { return }
                    
                    self.repository.deleteTask(task: searchTasks[indexPath.row])
                }
                
                self.setTitle()
                self.updateTasks()
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
        label.textColor = .label
        label.frame = CGRect(x: 0, y: 0, width: 300, height: 30)
        if section == 0 {
            label.text = "고정된 메모"
        } else if section == 1{
            label.text = "메모"
        } else {
            label.text = "\(searchTasks?.count ?? 0)개 찾음"
        }
        label.font = .boldSystemFont(ofSize: 28)
        view.addSubview(label)
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if searchTasks != nil || fixedTasks?.count == 0 {
                return 0
            }
        } else if section == 1 {
            if searchTasks != nil || normalTasks?.count == 0 {
                return 0
            }
        } else if section == 2 && searchTasks == nil {
            return 0
        }
        return 40
    }
}

extension MemoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text != "" {
            searchText = text
            searchTasks = repository.fetchFiterSort(text: "title CONTAINS[c] '\(text)' || content CONTAINS[c] '\(text)'", sort: "registerDate")
        } else {
            searchTasks = nil
        }
        mainView.tableView.reloadData()
    }
}
