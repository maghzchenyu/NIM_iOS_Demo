//
//  QChatAuthoritySettingViewModel.swift
//  NEKitQChatUI
//
//  Created by yuanyuan on 2022/2/11.
//

import Foundation
import NEKitCoreIM
import NEKitQChat

public class QChatAuthoritySettingViewModel {
    public var channel: ChatChannel?
    public var rolesData = QChatRoles()
    public var membersData = QChatRoles()

    private var repo = QChatRepo()
    
    init(channel:ChatChannel?) {
        self.channel = channel
    }
    
    func firstGetChannelRoles(_ completion: @escaping (Error?, [RoleModel]?) -> Void) {
        self.rolesData.timeTag = 0
        self.rolesData.roles = [RoleModel]()
        getChannelRoles(completion)
    }

    func getChannelRoles(_ completion: @escaping (Error?, [RoleModel]?) -> Void) {
        guard let sid = channel?.serverId, let cid = channel?.channelId else {
            completion(NSError.paramError(), nil)
            return
        }
        var param: ChannelRoleParam = ChannelRoleParam(serverId: sid, channelId: cid)
        param.limit = self.rolesData.pageSize
        param.timeTag = self.rolesData.timeTag
        repo.getChannelRoles(param) {[weak self] error, roleList in
            print("error:\(error) roleList:\(roleList)")
            if error != nil {
                completion(error, self?.rolesData.roles)
            }else {
                // 移除占位
                if let last = self?.rolesData.roles.last, last.isPlacehold {
                    self?.rolesData.roles.removeLast()
                }
                
                if let roles = roleList, roles.count > 0 {
                    // 添加身份组
                    for role in roles {
                        var model = RoleModel()
                        model.role = role
                        self?.rolesData.roles.append(model)
                    }
                    //记录最后一个身份组的时间戳 用于下页请求
                    self?.rolesData.timeTag = self?.rolesData.roles.last?.role?.createTime
                    
                    //添加占位
                    if roles.count >= self?.rolesData.pageSize ?? 5 {
                        var placeholdModel = RoleModel()
                        placeholdModel.title = localizable("more")
                        placeholdModel.isPlacehold = true
                        self?.rolesData.roles.append(placeholdModel)
                    }
                    self?.setRoundedCorner()
                    //设置圆角
                    completion(error, self?.rolesData.roles)
                }else {
                    //设置圆角
                    self?.setRoundedCorner()
                    completion(error, self?.rolesData.roles)
                }
            }
        }
    }
    
    func firstGetMembers(_ completion: @escaping (Error?, [RoleModel]?) -> Void) {
        self.membersData.pageSize = 50
        self.membersData.timeTag = 0
        self.membersData.roles = [RoleModel]()
        getMembers(completion)
    }
    
    func getMembers(_ completion: @escaping (Error?, [RoleModel]?) -> Void) {
        guard let sid = channel?.serverId, let cid = channel?.channelId else {
            completion(NSError.paramError(), nil)
            return
        }
        var param = GetMemberRolesParam()
        param.serverId = sid
        param.channelId = cid
        param.limit = self.membersData.pageSize
        param.timeTag = self.membersData.timeTag
        
        repo.getMemberRoles(param: param) {[weak self] error , memberRoles in
            print("error:\(error) memberArray:\(memberRoles)")
            if error != nil {
                completion(error, self?.membersData.roles)
            }else {
                // 移除占位
                if let last = self?.membersData.roles.last, last.isPlacehold {
                    self?.membersData.roles.removeLast()
                }
                if let members = memberRoles, members.count > 0 {
                    // 添加成员
                    for member in members {
                        var model = RoleModel()
                        model.member = member
                        self?.membersData.roles.append(model)
                    }
                    //记录最后一个身份组的时间戳 用于下页请求
                    self?.membersData.timeTag = self?.membersData.roles.last?.member?.createTime

                    //添加占位
                    if members.count == self?.rolesData.pageSize {
                        var placeholdModel = RoleModel()
                        placeholdModel.title = localizable("more")
                        placeholdModel.isPlacehold = true
                        self?.membersData.roles.append(placeholdModel)
                    }
                    self?.setRoundedCorner()
                    //设置圆角
                    completion(error, self?.membersData.roles)
                }else {
                    //设置圆角
                    self?.setRoundedCorner()
                    completion(error, self?.membersData.roles)
                }
            }
        }
    }
    
    public func removeChannelRole(role: ChannelRole?, index: Int, _ completion: @escaping (NSError?)->()) {
        var param = RemoveChannelRoleParam()
        param.serverId = role?.serverId
        param.roleId = UInt64(role?.roleId ?? 0)
        param.channelId = role?.channelId
        repo.removeChannelRole(param: param) {[weak self] anError in
            if anError == nil {
                self?.rolesData.roles.remove(at: index)
                completion(anError)
            }
            completion(anError)
        }
    }
    
    public func removeMemberRole(member: MemberRole?, index: Int, _ completion: @escaping (NSError?)->()) {
        let param = RemoveMemberRoleParam(serverId: self.channel?.serverId, channelId: self.channel?.channelId, accid: member?.accid)
        repo.removeMemberRole(param: param) { [weak self] anError in
            if anError == nil {
                self?.membersData.roles.remove(at: index)
            }
            completion(anError)
        }
    }
    
//    本地插入成员
    public func insertLocalMemberAtHead(member: MemberRole) {
        let model = RoleModel(member: member, isPlacehold: false)
        self.membersData.roles.insert(model, at: 0)
        setRoundedCorner()
    }
//    本地插入身份组
    public func insertLocalRoleAtHead(role: ChannelRole) {
        let model = RoleModel(role:role, isPlacehold: false)
        self.rolesData.roles.insert(model, at: 0)
        setRoundedCorner()
    }
    
    private func setRoundedCorner() {
        if self.rolesData.roles.count > 0 {
            if self.rolesData.roles.count == 1 {
                self.rolesData.roles[0].corner = .all
            }else {
                self.rolesData.roles[0].corner = .top
                self.rolesData.roles[self.rolesData.roles.count - 1].corner = .bottom
            }
        }
        if self.membersData.roles.count > 0 {
            if self.membersData.roles.count == 1 {
                self.membersData.roles[0].corner = .all
            }else {
                self.membersData.roles[0].corner = .top
                self.membersData.roles[self.membersData.roles.count - 1].corner = .bottom
            }
        }
    }
    

}

