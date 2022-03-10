//
//  JoinOtherServiceController.swift
//  QChatKit-UI
//
//  Created by vvj on 2022/1/24.
// Join someone else's server

import UIKit
import CoreKit
import CoreKit_IM

public class JoinOtherServiceController: NEBaseViewController {

    private let tag = "JoinOtherServiceController"
    public var serversArray = [QChatServer]()
    public var serverViewModel = CreateServerViewModel()
    public var channelViewModel = QChatChannelViewModel()

    public override func viewDidLoad() {
        super.viewDidLoad()
        initializeConfig()
        setupSubviews()
    }
    
    func initializeConfig(){
        self.title = localizable("qchat_join_otherServer")
        self.searchTextField.becomeFirstResponder()
    }
    
    func setupSubviews(){
        self.view.addSubview(searchTextField)
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: CGFloat(kNavigationHeight) + KStatusBarHeight + 20),
            searchTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: kScreenInterval),
            searchTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -kScreenInterval),
            searchTextField.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor,constant: 20),
            tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    

    // MARK: lazyMethod
    private lazy var searchTextField:SearchTextField = {
        let textField = SearchTextField()
        
       let image = UIImage(named:"otherService_search_icon",
                            in: Bundle(for: type(of:self)),
                            compatibleWith: nil)
        let leftImageView = UIImageView.init(image: image)
        textField.contentMode = .center
        textField.leftView = leftImageView
        textField.leftViewMode = .always
        textField.placeholder = localizable("搜索服务器ID")
        textField.font = DefaultTextFont(14)
        textField.textColor = TextNormalColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 8
        textField.backgroundColor = HexRGB(0xEFF1F4)
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(searchTextFieldChange), for: .editingDidEnd)
        textField.keyboardType = .numberPad
        return textField
    }()
    
    
    private lazy var tableView:UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NESearchServerCell.self, forCellReuseIdentifier: "\(NSStringFromClass(NESearchServerCell.self))")
        tableView.rowHeight = 60
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        return tableView
    }()
    
    private lazy var emptyView:EmptyDataView = {
        let view = EmptyDataView(imageName: "searchServer_noMoreData", content: "暂无你要的服务器ID",frame: tableView.bounds)
        return view
    }()
}

//MARK: UITableViewDelegate  UITableViewDataSource
extension JoinOtherServiceController:UITableViewDelegate,UITableViewDataSource  {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serversArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(NSStringFromClass(NESearchServerCell.self))", for: indexPath) as! NESearchServerCell
        cell.serverModel = serversArray[indexPath.row]
        weak var weakSelf = self
        cell.joinServerCallBack = {
            
            let successView = InviteMemberView(frame: CGRect.init(x: (kScreenWidth-176)/2, y: KStatusBarHeight, width: 176, height: 55))
            successView.showSuccessView()
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let serverId = serversArray[indexPath.row].serverId else { return  }
        let param = QChatGetChannelsByPageParam(timeTag: 0, serverId: serverId)
        weak var weakSelf = self
        channelViewModel.getChannelsByPage(parameter: param) {error, result in
            if error == nil {
                guard let dataArray = result?.channels else { return  }
                let chatVC = QChatViewController(channel: dataArray.first)
                weakSelf?.navigationController?.pushViewController(chatVC, animated: true)
            }else {
                print("getChannelsByPage failed,error = \(error!)")
            }
        }
    }
}

//MARK: private Method
extension JoinOtherServiceController {
    func showAlert(){
        let alertCtrl = UIAlertController.init(title: localizable("无法加入？"), message: localizable("你被该服务器封禁，无法加入。"), preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: localizable("知道了"), style: .default, handler: nil)
        alertCtrl.addAction(okAction)
        self.present(alertCtrl, animated: true, completion: nil)
    }
    

     @objc func searchTextFieldChange(textfield:SearchTextField){
         
         //选择高亮文本在进行搜索
//         let textRange = textfield.markedTextRange
//         if textRange == nil || ((textRange?.isEmpty) == nil) {
//             print("111")
//         }
         
         if !QChatDetectNetworkTool.shareInstance.isNetworkRecahability() {
             showToast("当前网络错误")
             return
         }
         
         guard let content = textfield.text else {
             return
         }
         //空字符串判断
         if content.isBlank {
             self.emptyView.removeFromSuperview()
             return
         }

         let param = QChatGetServersParam(serverIds: [NSNumber.init(value: UInt64(content)!)])
         serverViewModel.getServers(parameter: param) { error, serversArray in
             if error == nil{
                 self.serversArray = serversArray?.servers ?? Array()
                 if self.serversArray.isEmpty {
                     self.tableView.addSubview(self.emptyView)
                     return
                 }else {
                     self.emptyView.removeFromSuperview()
                 }
                 self.tableView.reloadData()
             }else {
                 QChatLog.errorLog(self.tag, desc: "❌getServers failed,error = \(error!)")
             }
         }
     }
}


//MARK: SearchTextField
 class SearchTextField:UITextField {
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += 10
        return rect
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.placeholderRect(forBounds: bounds)
        rect.origin.x += 1
        return rect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        var rect = super.editingRect(forBounds: bounds)
        rect.origin.x += 5
        return rect

    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        rect.origin.x += 5
        return rect
    }
}
