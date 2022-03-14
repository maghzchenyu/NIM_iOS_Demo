//
//  DetailTextCell.swift
//  NEKitContactUI
//
//  Created by yuanyuan on 2022/1/18.
//

import UIKit

class TextWithDetailTextCell: TextBaseCell {
    public var detailTitleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.detailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.detailTitleLabel.font = UIFont.systemFont(ofSize: 12)
        self.detailTitleLabel.textColor = UIColor(hexString: "#A6ADB6")
        self.contentView.addSubview(self.detailTitleLabel)
        NSLayoutConstraint.activate([
            self.detailTitleLabel.leftAnchor.constraint(equalTo: self.titleLabel.rightAnchor, constant: 20),
            self.detailTitleLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -20),
            self.detailTitleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.detailTitleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
            ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
