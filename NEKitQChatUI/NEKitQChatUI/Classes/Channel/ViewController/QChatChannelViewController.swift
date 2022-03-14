//
//  QChatChannelViewController.swift
//  NEKitQChatUI
//
//  Created by yuanyuan on 2022/1/21.
//

import UIKit
import Toast_Swift
import NEKitCoreIM

struct Channel {
    var sectionName = ""
    var contentName = ""
}

public class QChatChannelViewController: QChatTableViewController, QChatTextEditCellDelegate, QChatChannelTypeVCDelegate {

    var viewModel: QChatChannelViewModel?
    var dataList = [Channel]()
    
    public init(serverId: UInt64) {
        self.viewModel = QChatChannelViewModel(serverId: serverId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        commonUI()
        loadData()
    }
    
    func commonUI() {
        self.title = localizable("create_channel")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: localizable("create"), style: .plain, target: self, action: #selector(createChannel))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: localizable("cancel"), style: .plain, target: self, action: #selector(cancelEvent))
        self.navigationItem.rightBarButtonItem?.tintColor = .ne_greyText
        self.tableView.register(QChatTextEditCell.self, forCellReuseIdentifier: "\(QChatTextEditCell.self)")
        self.tableView.register(QChatTextArrowCell.self, forCellReuseIdentifier: "\(QChatTextArrowCell.self)")
        self.tableView.register(QChatSectionView.self, forHeaderFooterViewReuseIdentifier: "\(QChatSectionView.self)")
    }
    
    func loadData() {
        dataList.append(Channel(sectionName: localizable("channel_name"), contentName: localizable("input_channel_name")))
        dataList.append(Channel(sectionName: localizable("channel_topic"), contentName: localizable("input_channel_topic")))
        dataList.append(Channel(sectionName: localizable("channel_type"), contentName: localizable("public")))
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return dataList.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(QChatTextEditCell.self)", for: indexPath) as! QChatTextEditCell
            cell.cornerType = CornerType.bottomLeft.union(CornerType.bottomRight).union(CornerType.topLeft).union(CornerType.topRight)
            cell.textFied.placeholder = dataList[indexPath.section].contentName
            cell.delegate = self
            cell.textFied.tag = 11
            return cell
        }else if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(QChatTextEditCell.self)", for: indexPath) as! QChatTextEditCell
            cell.cornerType = CornerType.bottomLeft.union(CornerType.bottomRight).union(CornerType.topLeft).union(CornerType.topRight)
            cell.textFied.placeholder = dataList[indexPath.section].contentName
            cell.delegate = self
            cell.textFied.tag = 12
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(QChatTextArrowCell.self)", for: indexPath) as! QChatTextArrowCell
            cell.titleLabel.text = dataList[indexPath.section].contentName
            cell.cornerType = CornerType.bottomLeft.union(CornerType.bottomRight).union(CornerType.topLeft).union(CornerType.topRight)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(QChatSectionView.self)") as! QChatSectionView
        sectionView.titleLable.text = dataList[section].sectionName
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            // select channel type
            let vc = QChatChannelTypeVC()
            vc.delegate = self
            vc.isPrivate = viewModel?.isPrivate ?? false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
//    MARK: event
    @objc func createChannel() {
        print(#function)
        viewModel?.createChannel({ error, channel in
            print("error:\(error?.localizedDescription) channel:\(channel)")
            if error == nil {
                // success to chatVC
                self.navigationController?.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: NotificationName.createChannel, object: channel)
                })
            }else {
                self.view.makeToast(error?.localizedDescription) { didTap in
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
    
    @objc func cancelEvent() {
        print(#function)
        self.dismiss(animated: true, completion: nil)
    }
    
//    MARK: QChatTextEditCellDelegate
    func textDidChange(_ textField: UITextField) {
        print("textFieldDidChangeSelection textField:\(textField.text)")
        if textField.tag == 11 {
            if textField.text?.count == 0 {
                self.navigationItem.rightBarButtonItem?.tintColor = .ne_greyText
            }else {
                if var str = textField.text, str.count > 50 {
                    str = str.substring(to: str.index(str.startIndex, offsetBy: 50))
                    print("str:\(str)")
                    textField.text = str
                }
                self.navigationItem.rightBarButtonItem?.tintColor = .ne_blueText
            }
            viewModel?.name = textField.text
        }else if textField.tag == 12 {
            if var str = textField.text, str.count > 64 {
                str = str.substring(to: str.index(str.startIndex, offsetBy: 64))
                print("str:\(str)")
                textField.text = str
            }
            viewModel?.topic = textField.text
        }
    }
    
//    MARK: QChatChannelTypeVCDelegate
    func didSelected(type: Int) {
        viewModel?.isPrivate = type == 0 ? false : true
        if dataList.count >= 3 {
            dataList.removeLast()
            dataList.append(Channel(sectionName: localizable("channel_type"), contentName: type == 0 ? localizable("public") : localizable("private")))
            self.tableView.reloadData()
        }
    }
    
}
