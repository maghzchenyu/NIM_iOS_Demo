//
//  QChatImageTextOnlineCell.swift
//  NEKitQChatUI
//
//  Created by yuanyuan on 2022/2/9.
//

import UIKit

class QChatImageTextOnlineCell: QChatImageTextCell {
    var online:Bool {
        get {
            return onlineView.isHidden
        }
        set {
            onlineView.isHidden = !newValue
            self.alpha = newValue ? 1.0 : 0.5
        }
        
    }
    private var onlineView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        onlineView.backgroundColor = .ne_greenColor
        onlineView.layer.borderColor = UIColor.white.cgColor
        onlineView.layer.borderWidth = 2
        onlineView.clipsToBounds = true
        onlineView.layer.cornerRadius = 6
        onlineView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(onlineView)
        NSLayoutConstraint.activate([
            onlineView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor, constant: 16),
            onlineView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor, constant: 16),
            onlineView.widthAnchor.constraint(equalToConstant: 12),
            onlineView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
