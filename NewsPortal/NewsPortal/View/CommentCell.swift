//
//  CommentCell.swift
//  NewsPortal
//
//  Created by Kiss Levente on 2019. 04. 21..
//  Copyright © 2019. Kiss Levente. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    let commentTextLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        label.textColor = .white
        label.backgroundColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(){
        let backgoundView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        backgoundView.layer.cornerRadius = 10
        backgoundView.translatesAutoresizingMaskIntoConstraints = false
        backgoundView.backgroundColor = .black
        
        addSubview(backgoundView)
        
        addSubview(commentTextLabel)
        
        commentTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 100).isActive = true
        commentTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        commentTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        commentTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        
        backgoundView.leadingAnchor.constraint(equalTo: commentTextLabel.leadingAnchor, constant: -5).isActive = true
        backgoundView.trailingAnchor.constraint(equalTo: commentTextLabel.trailingAnchor, constant: 5).isActive = true
        backgoundView.topAnchor.constraint(equalTo: commentTextLabel.topAnchor, constant: -5).isActive = true
        backgoundView.bottomAnchor.constraint(equalTo: commentTextLabel.bottomAnchor, constant: 5).isActive = true
        
        
    }
    
}
