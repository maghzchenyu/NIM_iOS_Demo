//
//  CreateServiceViewController.swift
//  QChatKit-UI
//
//  Created by vvj on 2022/1/22.
// Create server options

import UIKit

import ContactKit

 class CreateServerViewController: NEBaseViewController {
    
    public var serverViewModel = CreateServerViewModel()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initializeConfig()
        setupSubviews()
    }
    
     func initializeConfig() {
         self.title = localizable("qchat_add_Server")
         addLeftAction(localizable("close"), #selector(closeAction), self)
     }
     
    func setupSubviews() {

        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor,constant: KStatusBarHeight+CGFloat(kNavigationHeight)+52),
            tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }



    private lazy var tableView:UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NECreateServerCell.self, forCellReuseIdentifier: "\(NSStringFromClass(NECreateServerCell.self))")
        tableView.rowHeight = 60
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        return tableView
    }()
}

extension CreateServerViewController {

    @objc func closeAction(sender:UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension CreateServerViewController:UITableViewDelegate,UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverViewModel.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(NSStringFromClass(NECreateServerCell.self))", for: indexPath) as! NECreateServerCell
        let model = serverViewModel.dataArray[indexPath.row]
        cell.model = model
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let mineCreateCtrl = MineCreateServerController()
            self.navigationController?.pushViewController(mineCreateCtrl, animated: true)
        }else if indexPath.row == 1{
            let otherCtrl = JoinOtherServiceController()
            self.navigationController?.pushViewController(otherCtrl, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    
}
