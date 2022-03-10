//
//  inviteMemberView.swift
//  QChatKit-UI
//
//  Created by vvj on 2022/3/4.
//

import UIKit

class InviteMemberView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(content)
        self.addSubview(successImageView)
        self.layer.cornerRadius = 26
        self.layer.borderWidth = 1
        self.layer.borderColor =  HexRGB(0xE3E3E3).cgColor
        self.layer.masksToBounds = true
        self.backgroundColor = .white

        NSLayoutConstraint.activate([
            successImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: kScreenInterval),
            successImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            successImageView.widthAnchor.constraint(equalToConstant: kScreenInterval),
            successImageView.heightAnchor.constraint(equalToConstant: kScreenInterval),
        ])
        
        NSLayoutConstraint.activate([
            content.leftAnchor.constraint(equalTo: successImageView.rightAnchor, constant: 6),
            content.centerYAnchor.constraint(equalTo: successImageView.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    public func showSuccessView(){
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.removeFromSuperview()
        }
    }
    
    //MARK: lazyMethod
    private lazy var content:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localizable("请求已发送")
        label.font = DefaultTextFont(16)
        label.textColor = UIColor.ne_darkText
        return label
    }()
    
    private lazy var successImageView:UIImageView = {
        let imageView = UIImageView.init(image: UIImage.ne_imageNamed(name: "invitemember_success"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

}
