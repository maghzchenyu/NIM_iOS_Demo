//
//  ContactsViewController.swift
//  ContactKitUI
//
//  Created by yuanyuan on 2021/12/29.
//

import UIKit
import CoreKit_IM

public class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SystemMessageProviderDelegate,FriendProviderDelegate {
    
    lazy var uiConfig = ContactsConfig()
    
    public var customCells:[Int : ContactTableViewCell.Type] = [ContactCellType.ContactPerson.rawValue : ContactTableViewCell.self, ContactCellType.ContactOthers.rawValue : ContactTableViewCell.self] // custom ui cell
    
    public var clickCallBacks = [Int : ConttactClickCallBack]()
    
    var tableView = UITableView(frame: .zero, style: .grouped)
    var viewModel = ContactViewModel(contactHeaders: [
        ContactHeadItem(name: "验证消息", imageName: "valid", router: ValidationMessageRouter),
        ContactHeadItem(name: "黑名单", imageName: "blackName", router: ContactBlackListRouter),
        ContactHeadItem(name: "我的群聊", imageName: "group", router: ContactGroupRouter)]
    )
    
    public init(withConfig custom: ContactsConfig){
        super.init(nibName: nil, bundle: nil)
        uiConfig = custom
        viewModel.contactRepo.addNotifyDelegate(delegate: self)
        viewModel.contactRepo.addContactDelegate(delegate: self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        weak var weakSelf = self
        viewModel.refresh = {
            weakSelf?.tableView.reloadData()
        }
        addNavbarAction()
        commonUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
         loadData()
    }
    
    func commonUI() {
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
        self.tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "\(ContactTableViewCell.self)")
        self.tableView.register(ContactSectionView.self, forHeaderFooterViewReuseIdentifier: "\(NSStringFromClass(ContactSectionView.self))")
        self.tableView.rowHeight = uiConfig.rowHeight
        self.tableView.sectionHeaderHeight = uiConfig.sectionHeaderHeight
        self.tableView.sectionFooterHeight = uiConfig.sectionFooterHeight
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
    }
    
    func loadData() {
        viewModel.loadData()
        self.tableView.reloadData()
    }
    
    // UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.contacts.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.contacts[section].contacts.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = viewModel.contacts[indexPath.section].contacts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(ContactTableViewCell.self)", for: indexPath) as! ContactTableViewCell
        cell.setModel(info, uiConfig)
        if indexPath.section == 0 && indexPath.row == 0 && viewModel.unreadCount > 0  {
            cell.redAngleView.isHidden = false
            cell.redAngleView.text = "\(viewModel.unreadCount)"
        }else {
            cell.redAngleView.isHidden = true
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView: ContactSectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(NSStringFromClass(ContactSectionView.self))") as! ContactSectionView
        sectionView.titleLabel.text = viewModel.contacts[section].initial
        return sectionView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if viewModel.contacts[section].initial.count > 0 {
            return uiConfig.sectionHeaderHeight
        }
        return 0
    }
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return viewModel.indexs
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return uiConfig.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info =  viewModel.contacts[indexPath.section].contacts[indexPath.row]
        if let callBack = clickCallBacks[info.contactCellType] {
            callBack(indexPath.row, indexPath.section)
            return
        }
        if info.contactCellType == ContactCellType.ContactOthers.rawValue {
            switch info.router {
            case ValidationMessageRouter:
                viewModel.contactRepo.clearUnreadCount()
                let validationController = ValidationMessageViewController()
                validationController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(validationController, animated: true)
                break
            case ContactBlackListRouter:
                let blackVC = BlackListViewController()
                blackVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(blackVC, animated: true)
                
                break
            case ContactGroupRouter:
                // My Team
                let teamVC = TeamListViewController()
                teamVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(teamVC, animated: true)
                
                break
            case ContactPersonRouter:
                
                break
            
            case ContactComputerRouter:
//                let select = ContactsSelectedViewController()
//                select.callBack = { contacts in
//                    print("select contacs : ", contacts)
//                }
//                select.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(select, animated: true)
                break
            default:
                break
            }
        }else {
            let userInfoVC = ContactUserViewController(user: info.user)
            userInfoVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(userInfoVC, animated: true)
        }
    }
    
//    MARK: SystemMessageProviderDelegate
    public func onRecieveNotification(notification: XNotification) {
        print("onRecieveNotification type:\(notification.type)")
        if notification.type == .addFriendDirectly {
            self.loadData()
        }
    }
        
    
    public func onNotificationUnreadCountChanged(count: Int) {
        print("unread count:\(count)")
    }
    
//    MARK: FriendProviderDelegate
    public func onFriendChanged(user: User) {
        print("onFriendChanged:\(user.userId)")
        self.loadData()
    }

    public func onBlackListChanged() {
        print("onBlackListChanged")
    }
    
    public func onUserInfoChanged(user: User) {
        print("onUserInfoChanged:\(user.userId)")
        self.loadData()
    }
}


extension ContactsViewController {
    private func addNavbarAction(){
        edgesForExtendedLayout = []
        let addItem = UIBarButtonItem(image: UIImage.ne_imageNamed(name: "add"), style: .plain, target: self, action: #selector(goToFindFriend))
        addItem.tintColor = UIColor(hexString: "333333")
        self.navigationItem.rightBarButtonItems = [addItem]
    }
    
    @objc private func goToFindFriend(){
        let findFriendController = FindFriendViewController()
        findFriendController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(findFriendController, animated: true)
    }
}
        

