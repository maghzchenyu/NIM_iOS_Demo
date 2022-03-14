//
//  TitleBaseCell.swift
//  NEKitContactUI
//
//  Created by yuanyuan on 2022/1/18.
//

import UIKit

class TextBaseCell: UITableViewCell {
    public var titleLabel: UILabel = UILabel()
    public var line = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.titleLabel.font = UIFont.systemFont(ofSize: 16)
        self.titleLabel.textColor = UIColor(hexString: "#333333")
        self.contentView.addSubview(self.titleLabel)
        NSLayoutConstraint.activate([
            self.titleLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 20),
            self.titleLabel.widthAnchor.constraint(equalToConstant: 100),
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
            ])
        self.titleLabel.text = ""
        
        self.line.backgroundColor = UIColor(hexString: "#F5F8FC")
        self.line.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.line)
        NSLayoutConstraint.activate([
            self.line.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 20),
            self.line.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -20),
            self.line.heightAnchor.constraint(equalToConstant: 1.0),
            self.line.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
            ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setModel(model: UserItem) {
        self.titleLabel.text = model.title
    }
    
}
