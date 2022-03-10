//
//  QChatHomeViewController.swift
//  QChatKit-UI
//
//  Created by vvj on 2022/1/21.
// qchat homepage

import Foundation
import UIKit
import CoreKit_IM
import MJRefresh
import NIMSDK
import QChatKit

public class QChatHomeViewController: UIViewController, ViewModelDelegate {
    
    public var serverViewModel = CreateServerViewModel()
    public var serverListArray = [QChatServer]()
    fileprivate var selectIndex = 0
    
    public override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }

    public override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false

    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        weak var weakSelf = self
        QChatDetectNetworkTool.shareInstance.netWorkReachability() { status in
            if status == .notReachable,let networkView = weakSelf?.brokenNetworkView{
                weakSelf?.qChatBgView.addSubview(networkView)
            }else {
                weakSelf?.brokenNetworkView.removeFromSuperview()
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        serverViewModel.delegate = self
        qChatBgView.viewmodel = serverViewModel
        weak var weakSelf = self
        serverViewModel.updateServerList = {
            weakSelf?.tableView.reloadData()
        }
        initializeConfig()
        addSubviews()
        self.requestData(timeTag: 0)
        addObserve()
    }
    func initializeConfig(){
        QChatSystemMessageProvider.shared.addDelegate(delegate: self)
    }
    
    
    func addSubviews(){
        self.view.addSubview(addServiceBtn)
        self.view.addSubview(qChatBgView)
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            addServiceBtn.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 12),
            addServiceBtn.widthAnchor.constraint(equalToConstant: 42),
            addServiceBtn.heightAnchor.constraint(equalToConstant: 42),
            addServiceBtn.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 46),
        ])
        NSLayoutConstraint.activate([
            qChatBgView.leftAnchor.constraint(equalTo: addServiceBtn.rightAnchor, constant: 12),
            qChatBgView.topAnchor.constraint(equalTo: addServiceBtn.topAnchor),
            qChatBgView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            qChatBgView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: addServiceBtn.bottomAnchor,constant: 7),
            tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: qChatBgView.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    func requestData (timeTag:TimeInterval){
        let param = GetServersByPageParam(timeTag: timeTag, limit: 20)
        weak var weakSelf = self
        serverViewModel.getServerList(parameter: param) { error, response in
            
            if error == nil {
                guard let dataArray = response?.servers else { return  }
                if timeTag == 0 {
                    self.serverListArray.removeAll()
                    self.serverListArray = dataArray
                    if let first = dataArray.first {
                        self.qChatBgView.qchatServerModel = first
                        self.qChatBgView.dismissEmptyView()
                    }else {
                        //服务器列表为空
                        self.qChatBgView.showEmptyServerView()
                    }
                }else {
                    self.serverListArray+=dataArray
                }
                
                // 未读数入口
                weakSelf?.serverViewModel.getUnread(dataArray)
                
                self.tableView.reloadData()
            }else {
                print("getServerList failed,error = \(error!)")
            }
        }
    }
    
    func addObserve() {
        NotificationCenter.default.addObserver(self, selector: #selector(onCreateServer), name:NotificationName.createServer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onCreateChannel), name:NotificationName.createChannel, object: nil)
    }
    
    //MARK: lazy method
    private lazy var addServiceBtn:UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage.ne_imageNamed(name: "addService_icon"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(addServiceBtnClick), for: .touchUpInside)
        return btn
    }()

    private lazy var qChatBgView:NEHomeChannelView = {
        let view = NEHomeChannelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        weak var weakSelf = self
        view.viewmodel = serverViewModel
        view.setUpBlock = {()in
            print("设置服务器")
            if weakSelf?.serverListArray.count == 0 {
                return
            }
            if let index = weakSelf?.selectIndex,
                let server = weakSelf?.serverListArray[index]{
                let setting = QChatServerSettingViewController()
                setting.server = server
                setting.hidesBottomBarWhenPushed = true
                weakSelf?.navigationController?.pushViewController(setting, animated: true)
            }
        }
        
        view.addChannelBlock = {[weak self] in
            if self?.serverListArray.count ?? 0 > 0 {
                let server = self?.serverListArray[self?.selectIndex ?? 0]
                guard let serverId = server?.serverId, serverId > 0 else {
                    print("error: serverId:\(server?.serverId ?? 0)")
                    return
                }
                let nav = QChatNavigationController(rootViewController: QChatChannelViewController(serverId: serverId))
                nav.modalPresentationStyle = .fullScreen
                weakSelf?.present(nav, animated: true, completion: nil)
            }
        }
        
        view.selectedChannelBlock = {[weak self] channel in
            self?.enterChatVC(channel: channel)
            
        }
        return view
    }()
    
    private lazy var tableView:UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NEHomeServerCell.self, forCellReuseIdentifier: "\(NSStringFromClass(NEHomeServerCell.self))")
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.backgroundColor = HexRGB(0xe9eff5)
        let mjfooter = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        mjfooter.stateLabel?.isHidden = true
        tableView.mj_footer = mjfooter
        return tableView
    }()
    
    private lazy var brokenNetworkView:QChatBrokenNetworkView = {
        let view = QChatBrokenNetworkView.init(frame: CGRect.init(x: 0, y: 38, width: qChatBgView.width, height: 33))
        return view
    }()
}


extension QChatHomeViewController {
    
    @objc func addServiceBtnClick(sender:UIButton) {
        let nav = UINavigationController(rootViewController: CreateServerViewController())
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }

    @objc func loadMoreData(){
        if let time = self.serverListArray.last?.createTime {
            self.requestData(timeTag: time)
        }
        self.tableView.mj_footer?.endRefreshing()
    }
    
}

// MARK: tableviewDelegate dataSource
extension QChatHomeViewController:UITableViewDelegate,UITableViewDataSource {
    
    
    public func dataDidChange() {
        qChatBgView.tableView.reloadData()
    }
    
    public func dataDidError(_ error: Error) {
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.serverListArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(NSStringFromClass(NEHomeServerCell.self))", for: indexPath) as! NEHomeServerCell
        cell.showSelectState(isShow: indexPath.row == selectIndex ? true :false)
        cell.serverModel = serverListArray[indexPath.row]
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let serverModel = self.serverListArray[indexPath.row]
        self.qChatBgView.qchatServerModel = serverModel
        serverViewModel.currentServerId = serverModel.serverId
        selectIndex = indexPath.row
        tableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
//    MARK: action
    @objc func onCreateServer(noti: Notification) {
        print("noti create server id:\(String(describing: noti.object))")
        guard let serverId: UInt64 = noti.object as? UInt64 else {
            return
        }
        
        weak var weakSelf = self
        let viewModel = QChatChannelViewModel(serverId: serverId)
        viewModel.name = localizable("second_channel")
        let className = className()
        viewModel.createChannel { error, channel in
            if error == nil {
                QChatLog.infoLog(className, desc: "✅second_channel create success")
                viewModel.name = localizable("first_channel")
                viewModel.createChannel { error, channel in
                    if let err = error {
                        QChatLog.errorLog(className, desc: "❌createChannel first_channel failed，error = \(err)")
                    }else {
                        QChatLog.infoLog(className, desc: "✅enter first channel success")
                        weakSelf?.enterChatVC(channel: channel)
                    }
                }
            }
        }
    }
    
    @objc func onCreateChannel(noti: Notification) {
        // enter ChatVC
        guard let channel = noti.object as? ChatChannel else {
            return
        }
        enterChatVC(channel:channel)
    }
    
    private func enterChatVC(channel:ChatChannel?) {
        let chatVC = QChatViewController(channel: channel)
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}

extension QChatHomeViewController:NIMQChatMessageManagerDelegate {
    
    public func onRecvSystemNotification(_ result: NIMQChatReceiveSystemNotificationResult) {
        result.systemNotifications?.forEach({ systemNotification in
            
            switch systemNotification.type {

            case .channelCreate,.channelRemove,.channelUpdateWhiteBlackIdentifyUser,.channelUpdate:
                self.channelChange(notificationInfo: systemNotification)
                break
            case .serverMemberKick,.serverMemberInviteDone:
                
                if systemNotification.fromAccount != CoreKitIMEngine.instance.imAccid,((systemNotification.toAccids?.contains(CoreKitIMEngine.instance.imAccid)) != nil){
                    self.requestData(timeTag: 0)
                }
                break
            case .serverMemberApplyDone,.serverCreate,.serverRemove,.serverMemberLeave:
                
                if systemNotification.fromAccount == CoreKitIMEngine.instance.imAccid {
                    selectIndex = 0
                    self.requestData(timeTag: 0)
                }
                break
                
            case .serverUpdate:
                //刷新发生更新的cell
                self.reloadUpdateCell(targetServerId: systemNotification.serverId)
                break
            default:
                print("")
            }
            
        })
    }
    
    
    private func reloadUpdateCell(targetServerId:UInt64){
        var targetIndex = 0
        for (index, serverModel) in serverListArray.enumerated() {
            if targetServerId == serverModel.serverId{
                targetIndex = index
                break
            }
        }

        let indexPath = IndexPath(row: targetIndex, section: 0)
        let param = QChatGetServersParam(serverIds: [NSNumber.init(value: targetServerId)])
        weak var weakSelf = self
        serverViewModel.getServers(parameter: param) { erorr, result in
            if let serverArray = result?.servers,!serverArray.isEmpty {
                weakSelf?.serverListArray[targetIndex] = serverArray.first!
                weakSelf?.tableView.reloadRows(at: [indexPath], with: .none)
                
                if targetIndex == weakSelf?.selectIndex {
                    weakSelf?.qChatBgView.qchatServerModel = serverArray.first!
                }
            }
        }
    }
    
    private func channelChange(notificationInfo:NIMQChatSystemNotification){
        self.qChatBgView.channelChange(noticeInfo: notificationInfo)
    }
    
}
