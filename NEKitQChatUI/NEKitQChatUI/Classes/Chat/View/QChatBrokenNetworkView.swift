//
//  QChatBrokenNetworkView.swift
//  NEKitQChatUI
//
//  Created by vvj on 2022/3/7.
//

import UIKit

public class QChatBrokenNetworkView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonUI(){
        self.backgroundColor = HexRGB(0xFEE3E6)
        self.addSubview(content)
        NSLayoutConstraint.activate([
            content.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15),
            content.centerYAnchor.constraint(equalTo:  self.centerYAnchor),
            content.rightAnchor.constraint(equalTo:  self.rightAnchor, constant: -15),
        ])
    }
    
    private lazy var content:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DefaultTextFont(14)
        label.textColor = HexRGB(0xFC596A)
        label.textAlignment = .center
        label.text = "当前网络不可用，请检查你当网络设置。"
        return label
    }()
    

}
