//
//  QChatMemberPermissionSettingVC.swift
//  NEKitQChatUI
//
//  Created by yuanyuan on 2022/2/8.
//

import UIKit
import NEKitCoreIM

typealias updateSettingBlock = (_ memberRole: MemberRole?) -> ()
class QChatMemberPermissionSettingVC: QChatTableViewController, QChatPermissionSettingCellDelegate {
    public var channel: ChatChannel?
    public var memberRole: MemberRole?
//    public var didUpdateBlock: updateSettingBlock?
    private var commonAuths = [RoleStatusInfoExt]()
    private var messageAuths = [RoleStatusInfoExt]()
    private var memberAuths = [RoleStatusInfoExt]()

    private var auths = [[Any]]()

    init(channel: ChatChannel?, memberRole: MemberRole?) {
        super.init(nibName: nil, bundle: nil)
        self.channel = channel
        self.memberRole = memberRole
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localizable("member_permission_setting")
        self.tableView.register(QChatPermissionSettingCell.self, forCellReuseIdentifier: "\(QChatPermissionSettingCell.self)")
        self.tableView.register(QChatImageTextCell.self, forCellReuseIdentifier: "\(QChatImageTextCell.self)")
        self.tableView.register(QChatSectionView.self, forHeaderFooterViewReuseIdentifier: "\(QChatSectionView.self)")
        self.tableView.sectionHeaderHeight = 42
        self.tableView.rowHeight = 48
        reloadData()
        
    }
    
    private func reloadData() {
        let members = [self.memberRole]
        self.auths.append(members as [Any])
        
        if let auths = self.memberRole?.auths  {
            for auth in auths {
                var authExt = RoleStatusInfoExt(status: auth)
                let key = "auth" + String(auth.type.rawValue)
                authExt.title = localizable(key)
                switch auth.type {
                case .ManageChannel:
                    commonAuths.insert(authExt, at: 0)
                case .ManageRole:
                    commonAuths.append(authExt)
                case .SendMsg:
                    messageAuths.append(authExt)
//                case .DeleteOtherMsg:
//                    messageAuths.append(authExt)
//                case .RevokeMsg:
//                    messageAuths.append(authExt)
                case .BlackWhiteList:
                    memberAuths.append(authExt)
                default:
                    break
                }
            }
            
            if !commonAuths.isEmpty {
                self.auths.append(commonAuths)
            }
            if !messageAuths.isEmpty {
                self.auths.append(messageAuths)
            }
            if !memberAuths.isEmpty {
                self.auths.append(memberAuths)
            }
        }
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.auths.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.auths[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            //用户
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(QChatImageTextCell.self)", for: indexPath) as! QChatImageTextCell
            let members = self.auths[indexPath.section]
            let m = members[indexPath.row] as? MemberRole
            cell.setup(accid: m?.accid, nickName: m?.nick)
            if indexPath.row == 0 {
                cell.cornerType = CornerType.topLeft.union(CornerType.topRight)
            }else if indexPath.row == auths.count - 1 {
                cell.cornerType = CornerType.bottomLeft.union(CornerType.bottomRight)
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(QChatPermissionSettingCell.self)", for: indexPath) as! QChatPermissionSettingCell
            let auths = self.auths[indexPath.section]
            let authExt = auths[indexPath.row] as? RoleStatusInfoExt
            cell.updateModel(model: authExt)
            cell.delegate = self
            if indexPath.row == 0 {
                cell.cornerType = CornerType.topLeft.union(CornerType.topRight)
            }else if indexPath.row == auths.count - 1 {
                cell.cornerType = CornerType.bottomLeft.union(CornerType.bottomRight)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(QChatSectionView.self)") as? QChatSectionView
        if section == 1 {
            view?.titleLable.text = localizable("qchat_common_permission")
        }else if section == 2 {
            view?.titleLable.text = localizable("qchat_message_permission")
        }else if section == 3 {
            view?.titleLable.text = localizable("qchat_member_permission")
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 56
        }else {
            return 48
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 42
    }
    
//    MARK:QChatPermissionSettingCellDelegate
    func didSelected(cell: QChatPermissionSettingCell?, model: RoleStatusInfo?) {
        if let auth = model {
            let param = UpdateMemberRoleParam(serverId: self.channel?.serverId, channelId: self.channel?.channelId, accid: self.memberRole?.accid, commands: [auth])
            QChatRoleProvider.shared.updateMemberRole(param: param) {[weak self] error, memberRole in
                if error != nil {
                    self?.view.makeToast(error?.localizedDescription)
                    cell?.selectedSuccess(success: false)
                }else {
                    cell?.selectedSuccess(success: true)
//                    if let block = self?.didUpdateBlock {
//                        block(memberRole)
//                    }
                }
            }
        }
    }
}
