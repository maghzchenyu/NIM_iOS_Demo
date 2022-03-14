//
//  ContactBaseViewCell.swift
//  NEKitContactUI
//
//  Created by yu chen on 2022/1/19.
//

import UIKit

public class ContactBaseViewCell: UITableViewCell {
    
    public lazy var avatarImage: UIImageView = {
        let avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.addSubview(nameLabel)
        avatar.clipsToBounds = true
        avatar.backgroundColor = UIColor.colorWithNumber(number: 0)
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: avatar.leftAnchor, constant: 1),
            nameLabel.rightAnchor.constraint(equalTo: avatar.rightAnchor, constant: -1),
            nameLabel.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor)
        ])
        return avatar
    }()
    
    public lazy var nameLabel: UILabel = {
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textColor = .white
        name.textAlignment = .center
        name.font = UIFont.systemFont(ofSize: 14.0)
        return name
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor(hexString: "333333")
        return label
    }()
    
    var leftConstraint: NSLayoutConstraint?

    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupCommonCircleHeader(){
        avatarImage.layer.cornerRadius = 18
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarImage)
        leftConstraint = avatarImage.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 20)
        leftConstraint?.isActive = true

        NSLayoutConstraint.activate([
            avatarImage.widthAnchor.constraint(equalToConstant: 36),
            avatarImage.heightAnchor.constraint(equalToConstant: 36),
            avatarImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0)
        ])
    }
    
    func showNameOnCircleHeader(_ name: String) {
        nameLabel.text = name.count > 2 ? String(name[name.index(name.endIndex, offsetBy: -2)...]) : name
    }

}