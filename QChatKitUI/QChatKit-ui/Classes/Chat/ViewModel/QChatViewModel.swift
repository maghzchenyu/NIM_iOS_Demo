//
//  QChatViewModel.swift
//  QChatKit-UI
//
//  Created by yuanyuan on 2022/2/10.
//

import Foundation
import CoreKit_IM
import NIMSDK

public protocol QChatViewModelDelegate: AnyObject {
    func onRecvMessages(_ messages: [NIMQChatMessage])
    func willSend(_ message: NIMQChatMessage)
    func send(_ message: NIMQChatMessage, didCompleteWithError error: Error?)
    func send(_ message: NIMQChatMessage, progress: Float)
}

public class QChatViewModel: NSObject, NIMQChatMessageManagerDelegate {
    public var channel: ChatChannel?
    public var messages: [QChatMessageFrame] = [QChatMessageFrame]()
    public weak var delegate: QChatViewModelDelegate?
    private var lastMsg: NIMQChatMessage?
    
    init(channel:ChatChannel?) {
        super.init()
        self.channel = channel
        QChatSystemMessageProvider.shared.addDelegate(delegate: self)
    }
    
    public func sendTextMessage(text: String, _ completion: @escaping (Error?) -> Void) {
        if text.count <= 0 {
            return
        }
        if let cid = self.channel?.channelId, let sid = self.channel?.serverId {
            let message = NIMQChatMessage()
            message.text = text
            message.from = CoreKitIMEngine.instance.imAccid
            QChatSystemMessageProvider.shared.sendMessage(message: message, session: NIMSession(forQChat: Int64(cid), qchatServerId: Int64(sid))) { error in
                print("sendText error:\(error) ")
                completion(error)
            }
        }
    }
    
    public func sendImageMessage(image: UIImage, _ completion: @escaping (Error?) -> Void) {
        if let cid = self.channel?.channelId, let sid = self.channel?.serverId {
            let message = NIMQChatMessage()
            message.messageObject = NIMImageObject(image: image)
            message.from = CoreKitIMEngine.instance.imAccid
            QChatSystemMessageProvider.shared.sendMessage(message: message, session: NIMSession(forQChat: Int64(cid), qchatServerId: Int64(sid))) { error in
                print("sendImage error:\(error) ")
                completion(error)
            }
        }
    }
    
    public func getMessageHistory(_ completion: @escaping (Error?, [QChatMessageFrame]?) -> Void) {
        if let cid = self.channel?.channelId, let sid = self.channel?.serverId {
            self.lastMsg = nil
            var param = GetMessageHistoryParam(serverId: sid, channelId: cid)
            param.lastMsg = self.lastMsg
            QChatSystemMessageProvider.shared.getMessageHistory(param: param) { [weak self] error, messages in
                if let messageArray = messages, messageArray.count > 0 {
                    self?.lastMsg = messageArray.last
                    self?.getUserInfo(messages: messageArray, { error, messageExts in
                        for msgExt in messageExts {
                            self?.addTimeForHistoryMessage(msgExt)
                            self?.messages.insert(msgExt, at: 0)
                        }
                        if let last = messageExts.last, let msg = self?.timeModel(last) {
                            self?.messages.insert(msg, at: 0)
                        }
                        completion(error, messageExts)
                    })
                }else {
                    completion(error, nil)
                }
            }
        }else {
            completion(NSError.paramError(), nil)
        }
    }
    
    public func getMoreMessageHistory(_ completion: @escaping (Error?, [QChatMessageFrame]?) -> Void) {
        if let cid = self.channel?.channelId, let sid = self.channel?.serverId {
            var param = GetMessageHistoryParam(serverId: sid, channelId: cid)
            param.lastMsg = self.lastMsg
            QChatSystemMessageProvider.shared.getMessageHistory(param: param) { [weak self] error, messages in
                if let messageArray = messages, messageArray.count > 0 {
                    self?.lastMsg = messageArray.last
                    self?.getUserInfo(messages: messageArray, { error, messageExts in
                        for msgExt in messageExts {
                            self?.addTimeForHistoryMessage(msgExt)
                            self?.messages.insert(msgExt, at: 0)
                        }
                        if let last = messageExts.last, let msg = self?.timeModel(last) {
                            self?.messages.insert(msg, at: 0)
                        }
                        completion(error, messageExts)
                    })
                }else {
                    completion(error, nil)
                }
            }
        }else {
            completion(NSError.paramError(), nil)
        }
    }

    public func getUserInfo(messages: [NIMQChatMessage], _ completion: @escaping (Error?, [QChatMessageFrame]) -> Void) {
        var userIds = [String]()
        var lastMsg: NIMQChatMessage?
        var tmp = [QChatMessageFrame]()
        
        for message in messages {
            let isSend = message.from == CoreKitIMEngine.instance.imAccid
            let msgExt = QChatMessageFrame(isSender: isSend)
            msgExt.message = message
            msgExt.showAvatar = lastMsg?.from != message.from
            tmp.append(msgExt)
            lastMsg = message
            if let userId = message.from, msgExt.showAvatar {
                userIds.append(userId)
            }
        }
        if userIds.isEmpty {
            completion(nil, tmp)
        }else {
            FriendProvider.shared.getUserInfoAdvanced(userIds: userIds) { userInfoList, error in
                var result = [QChatMessageFrame]()
                for msg in tmp {
                    for u in userInfoList {
                        if msg.message?.from == u.userId {
                            msg.avatar = u.userInfo?.thumbAvatarUrl
                            msg.nickname = u.userInfo?.nickName
                        }
                    }
                    result.append(msg)
                }
                completion(error, result)
            }
        }
    }
    
    public func markMessageRead(time: TimeInterval) {
        if let cid = self.channel?.channelId, let sid = self.channel?.serverId {
            var param = MarkMessageReadParam(serverId: sid, channelId: cid)
            param.ackTimestamp = time
            QChatSystemMessageProvider.shared.markMessageRead(param: param) { error in
                print("mark read error : ", error as Any)
            }
        }
    }
    
    //    MARK: NIMChatManagerDelegate
        public func onRecvMessages(_ messages: [NIMQChatMessage]) {
            print("\(#function) messages:\(messages.count)")
            var channelMsgs = [NIMQChatMessage]()
            for msg in messages {
                if msg.qchatChannelId == self.channel?.channelId {
                    channelMsgs.append(msg)
                }
            }
            self.getUserInfo(messages: channelMsgs) { error, msgExts in
                for msgExt in msgExts {
                    self.addTimeMessage(msgExt)
                    self.messages.append(msgExt)
                }
            }
            self.delegate?.onRecvMessages(channelMsgs)
        }
        
        public func willSend(_ message: NIMQChatMessage) {
            print("\(#function)")
            if self.lastMsg == nil {
                self.lastMsg = message
            }
            self.getUserInfo(messages: [message]) { error, msgExts in
                for msgExt in msgExts {
                    self.addTimeMessage(msgExt)
                    self.messages.append(msgExt)
                }
            }
            self.delegate?.willSend(message)
        }
        
        public func send(_ message: NIMQChatMessage, progress: Float) {
            print("\(#function)  progress\(progress)")
            self.delegate?.send(message, progress: progress)
        }
        
        public func send(_ message: NIMQChatMessage, didCompleteWithError error: Error?) {
            print("\(#function) message deliveryState:\(message.deliveryState) error:\(error)")
            if let e = error as NSError? {
                if e.code == 403 {
                    var index = 0
                    for (i, msg) in self.messages.enumerated() {
                        if message.messageId == msg.message?.messageId {
                            index = i
                        }
                    }
                    self.messages.remove(at: index)
                }
            }else {
                for (i, msg) in self.messages.enumerated() {
                    if message.messageId == msg.message?.messageId {
                        self.messages[i].message = message
                        break
                    }
                }
            }
            self.delegate?.send(message, didCompleteWithError: error)
        }
    
    private func modelFromMessage(_ message: NIMQChatMessage) -> QChatMessageFrame {
        
        let isSend = message.from == CoreKitIMEngine.instance.imAccid
        let model = QChatMessageFrame(isSender: isSend)
        model.showAvatar = message.from != self.messages.last?.message?.from
        model.message = message
        return model
    }
    
    // history message insert message at first of messages, send message add last of messages
    private func addTimeMessage(_ message: QChatMessageFrame) {
        let lastTs = self.messages.last?.message?.timestamp ?? 0.0
        let curTs = message.message?.timestamp ?? 0.0
        let dur = curTs - lastTs
        if (dur / 60) > 5 {
//            let model = QChatMessageFrame(isSender: true)
//            model.showTime = true
//            model.time = String.stringFromDate(date:Date(timeIntervalSince1970: curTs))
//            model.showAvatar = false
//            model.cellHeight = 35
            self.messages.append(self.timeModel(message))
        }
    }
    
    private func addTimeForHistoryMessage(_ message: QChatMessageFrame) {
        let firstTs = self.messages.first?.message?.timestamp ?? 0.0
        let curTs = message.message?.timestamp ?? 0.0
        let dur = firstTs - curTs
        if (dur / 60) > 5 {
            let model = QChatMessageFrame(isSender: true)
            model.showTime = true
            model.time = String.stringFromDate(date:Date(timeIntervalSince1970: firstTs))
            model.showAvatar = false
            model.cellHeight = 35
            self.messages.insert(model, at: 0)
        }
    }
    
    private func timeModel(_ message: QChatMessageFrame) -> QChatMessageFrame {
        let curTs = message.message?.timestamp ?? 0.0
        let model = QChatMessageFrame(isSender: true)
        model.showTime = true
        model.time = String.stringFromDate(date:Date(timeIntervalSince1970: curTs))
        model.showAvatar = false
        model.cellHeight = 35
        return model
    }
}
