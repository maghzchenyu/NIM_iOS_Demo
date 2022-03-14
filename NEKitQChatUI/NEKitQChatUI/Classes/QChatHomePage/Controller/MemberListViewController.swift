//
//  MemberListViewController.swift
//  NEKitQChatUI
//
//  Created by vvj on 2022/2/7.
// Server under the member list page

import UIKit
import NEKitCoreIM
//import NEKitContactUI
import TPRouter_Swift
class MemberListViewController: NEBaseViewController {

    public var serverViewModel = CreateServerViewModel()
    public var memberViewModel = MemberListViewModel()
    
    var dataArray:Array<ServerMemeber>?
    var serverId: UInt64?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeConfig()
        requestData()
        addSubviews()
        // Do any additional setup after loading the view.
    }
    
    func requestData(){
        guard let id = serverId else {
            print("serverId is nil")
            return
        }
        let param = QChatGetServerMembersByPageParam(timeTag: 0, serverId: id)
        weak var weakSelf = self
        memberViewModel.requestServerMemebersByPage(param: param) { error, serverMemberArray in
            if error == nil {
                weakSelf?.dataArray = serverMemberArray
                weakSelf?.tableView.reloadData()
            }else {
                
            }
        }
    }
    
    func initializeConfig() {
        self.title = "成员"
        addRightAction(UIImage.ne_imageNamed(name: "sign_add"), #selector(addMemberClick), self)
    }
    
    func addSubviews(){
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }

    //MARK: lazy method
    private lazy var tableView:UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NEGroupIdentityMemberCell.self, forCellReuseIdentifier: "\(NSStringFromClass(NEGroupIdentityMemberCell.self))")
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.estimatedRowHeight = 125
        return tableView
    }()
}


extension MemberListViewController:UITableViewDelegate,UITableViewDataSource {
    
    @objc func addMemberClick(sender:UIButton) {
        
        Router.shared.register("didSelectedAccids") {[weak self] param in
            print("param\(param)")
            if let userIds = param["accids"] as? [String] {
                print("userIds:\(userIds)")
                guard let serverId = self?.serverId else { return }
                self?.serverViewModel.inviteMembersToServer(serverId: serverId, accids: userIds) { error in
                    if error == nil{
                        self?.requestData()
                    }
                }
            }
        }

        Router.shared.use("goToContactSelectedVC", parameters: ["nav": self.navigationController]) { obj, routerState, str in
            print("obj:\(obj) routerState:\(routerState) str:\(str)")
        }
        
//        FIXME:router
//        let contactCtrl = ContactsSelectedViewController()
//        self.navigationController?.pushViewController(contactCtrl, animated: true)
//        weak var weakSelf = self
//
//        contactCtrl.callBack = {(selectMemberarray)->Void in
//
//            guard let serverId = weakSelf?.serverId else { return  }
//            var accidArray = [String]()
//            selectMemberarray.forEach { memberInfo in
//                accidArray.append(memberInfo.user?.userId ?? "")
//            }
//            weakSelf?.serverViewModel.inviteMembersToServer(serverId: serverId, accids: accidArray) { error in
//                if error == nil{
//                    weakSelf?.requestData()
//                }
//            }
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray?.count ?? 0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(NSStringFromClass(NEGroupIdentityMemberCell.self))", for: indexPath) as! NEGroupIdentityMemberCell
        cell.memberModel = dataArray?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let user = viewModel.limitUsers[indexPath.row]
        if let member = dataArray?[indexPath.row] {
            let editMember = QChatEditMemberViewController()
            editMember.deleteCompletion = {
                self.requestData()
            }
            editMember.changeCompletion = {
                self.requestData()
            }
            let user = UserInfo(member)
            editMember.user = user
            navigationController?.pushViewController(editMember, animated: true)
        }
    }


}


