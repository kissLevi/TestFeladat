//
//  NewsCell.swift
//  NewsPortal
//
//  Created by Kiss Levente on 2019. 04. 21..
//  Copyright © 2019. Kiss Levente. All rights reserved.
//

import UIKit

class NewsCell : UITableViewCell{
    var newImageView:UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var newTitleLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        label.font = .boldSystemFont(ofSize: 15)
        label.numberOfLines = 2
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var authorLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        label.font = .boldSystemFont(ofSize:12)
        label.textColor = .gray
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        backgroundColor = .black
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = .black
        selectedBackgroundView = bgColorView
        
        addSubview(newImageView)
        newImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        newImageView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -5).isActive = true
        newImageView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -10).isActive = true
        newImageView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 10).isActive = true
        newImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        newImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 532).isActive = true
        newImageView.clipsToBounds = true
        
        addSubview(authorLabel)
        authorLabel.bottomAnchor.constraint(equalTo: newImageView.bottomAnchor, constant: -10).isActive = true
        authorLabel.trailingAnchor.constraint(equalTo: newImageView.trailingAnchor, constant: -15).isActive = true
        authorLabel.leadingAnchor.constraint(equalTo: newImageView.leadingAnchor, constant: 15).isActive = true
        
        addSubview(newTitleLabel)
        newTitleLabel.bottomAnchor.constraint(equalTo: authorLabel.topAnchor, constant: -5).isActive = true
        newTitleLabel.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor).isActive = true
        newTitleLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor).isActive = true
    }
}
