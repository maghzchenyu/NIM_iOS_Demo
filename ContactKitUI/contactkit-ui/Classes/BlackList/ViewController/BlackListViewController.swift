//
//  BlackListViewController.swift
//  ContactKit-UI
//
//  Created by yuanyuan on 2022/1/17.
//

import UIKit
import CoreKit_IM
class BlackListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,TeamTableViewCellDelegate {
    var tableView = UITableView(frame: .zero, style: .plain)
    var viewModel = BlackListViewModel()
    public var blackList: [User]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonUI()
        loadData()
    }
    
    func commonUI() {
        self.title = "黑名单"
        let image = UIImage.ne_imageNamed(name: "backArrow")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backEvent))
        let addImage = UIImage.ne_imageNamed(name: "add")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: addImage, style: .plain, target: self, action: #selector(addBlack))
        
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tableView)
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        self.tableView.register(BlackListCell.self, forCellReuseIdentifier: "\(NSStringFromClass(TeamTableViewCell.self))")
        self.tableView.rowHeight = 62
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
    }
    
    func loadData() {
        blackList = viewModel.getBlackList()
        self.tableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blackList?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(NSStringFromClass(TeamTableViewCell.self))", for: indexPath) as! BlackListCell
        cell.delegate = self
        cell.index = indexPath.row
        cell.setModel(blackList?[indexPath.row] as Any)
        return cell
    }
    
    @objc func backEvent() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func addBlack() {
        let contactSelectVC = ContactsSelectedViewController()
        self.navigationController?.pushViewController(contactSelectVC, animated: true)
        contactSelectVC.callBack = {[weak self] selectMemberarray in
            var users = [User]()
            selectMemberarray.forEach { memberInfo in
                if let u = memberInfo.user {
                    users.append(u)
                }
            }
            return self?.addBlackUsers(users: users)
        }
    }
    
    func addBlackUsers(users: [User]) {
        var num = users.count
        var suc = [User]()
        for user in users {
            viewModel.addBlackList(account: user.userId ?? "") {[weak self] error in
                if error == nil {
                    suc.append(user)
                }
                num = num - 1
                if num == 0 {
                    print("add black finished")
                    self?.blackList?.append(contentsOf: suc)
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
//MARK:TeamTableViewCellDelegate
    func removeUser(account: String?, index: Int) {
        guard let acc = account else {
            return
        }
        viewModel.removeFromBlackList(account: acc) { error in
            //1.当前页面刷新
            if error == nil {
                self.blackList?.remove(at: index)
                self.tableView.reloadData()
            }else {
                print("removeFromBlackList error:\(error!)");
            }
        }
    }
}
