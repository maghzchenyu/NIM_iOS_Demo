//
//  MemberListViewModel.swift
//  NEKitQChatUI
//
//  Created by vvj on 2022/2/12.
//

import Foundation
import NEKitQChat
import NEKitCoreIM

public class MemberListViewModel {
    
    let repo = QChatRepo()
    public var memberInfomationArray:[QChatMember]?
    weak var delegate: ViewModelDelegate?
    
    init(){}
    
    func requestServerMemebersByPage(param:QChatGetServerMembersByPageParam,_ completion: @escaping (NSError?,[ServerMemeber]?)->()){
        repo.getServerMembersByPage(param) { error, memberResult in
            
            if error == nil {
                guard let memberArr = memberResult?.memberArray else { return  }
                var accidList = [String]()
                var dic = [String: ServerMemeber]()
                
                for memberModel in memberArr {
                    accidList.append(memberModel.accid ?? "")
                    if let accid = memberModel.accid {
                        dic[accid] = memberModel
                    }
                }
                
                let roleParam = QChatGetExistingAccidsInServerRoleParam(serverId: param.serverId!, accids: accidList)
                self.repo.getExistingServerRolesByAccids(roleParam) { error, serverRolesDict in
                    serverRolesDict?.forEach({ key,roleArray in
                        dic[key]?.roles = roleArray
//                        dic[key]?.imName = "222"
                    })
                    var tempServerArray = [ServerMemeber]()
                    for var memberModel in memberArr {
                        if let accid = memberModel.accid,let dicMember = dic[accid] {
                            memberModel.roles = dicMember.roles
                            memberModel.imName = dicMember.imName
                            tempServerArray.append(memberModel)
                        }
                    }
                    completion(nil,tempServerArray)
                }
                
                
                /*
                 //获取im昵称
                 self.repo.fetchUserInfo(accountList: accidList) { users, error in
                     if error == nil {
                         guard let userArray = users else { return  }
                         for user in userArray {
 //                            if var memberModel = dic[user.userId!] {
                             dic[user.userId!]?.imName = user.userInfo?.nickName ?? ""
 //                            }
                         }
                         completion(nil,memberArr)
                     }else {
                         completion(error,nil)
                     }
                 }
                 */
                
                
                
 
                
            }else {
                completion(error,nil)
                print("getServerMembersByPage failed,error = \(error!)")
            }
        }
    }

    
    
    func getRoles(){
        
    }
    
}
