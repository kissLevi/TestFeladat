//
//  TopMenubar.swift
//  NewsPortal
//
//  Created by Kiss Levente on 2019. 04. 21..
//  Copyright © 2019. Kiss Levente. All rights reserved.
//

import UIKit

class TopMenubar: UIView {
    var menuItems:[String] = []{
        didSet{
            for view in self.subviews{
                view.removeFromSuperview()
            }
            setupViews()
        }
    }
    
    var selctedMenuItem = 0
    
    var newMenuItemSelected:((Int,String)->())?
    
    var selectedMenuItemString:String{
        return menuItems[selctedMenuItem]
    }
    
    private var leadingConstraint:NSLayoutConstraint!
    
    var numberOfMenuItems:Int{
        return menuItems.count
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews(){
        var menuLabels:[UILabel] = []
        backgroundColor = .black
        for menuItem in menuItems{
            let menuLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            menuLabel.textColor = .white
            menuLabel.backgroundColor = .black
            menuLabel.text = menuItem
            menuLabel.textAlignment = .center
            menuLabels.append(menuLabel)
        }
        let stack = UIStackView(arrangedSubviews: menuLabels)
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        stack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: CGFloat(menuItems.count) / 2 ).isActive = true
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        let offset = CGFloat(selctedMenuItem) * 0.5 * frame.width
        leadingConstraint = stack.leadingAnchor.constraint(equalTo: centerXAnchor,constant: -offset - frame.width / 4)
        leadingConstraint.isActive = true
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe(gesture:)))
        rightSwipe.direction = .right
        
        addGestureRecognizer(rightSwipe)
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe(gesture:)))
        leftSwipe.direction = .left
        addGestureRecognizer(leftSwipe)
        stack.addGestureRecognizer(leftSwipe)
        stack.addGestureRecognizer(rightSwipe)
    }
    
    @objc func swipe(gesture:UISwipeGestureRecognizer){
        switch gesture.direction {
        case .left:
            if selctedMenuItem < menuItems.count - 1{
                selctedMenuItem += 1
                let offset = CGFloat(selctedMenuItem) * 0.5 * frame.width
                UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: { [weak self] in
                    if let self = self{
                        self.leadingConstraint.constant = -offset - self.frame.width / 4
                        self.layoutSubviews()
                    }
                }, completion:nil)
                newMenuItemSelected?(selctedMenuItem,selectedMenuItemString)
            }
        case .right:
            if selctedMenuItem > 0{
                selctedMenuItem -= 1
                let offset = CGFloat(selctedMenuItem) * 0.5 * frame.width
                UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: { [weak self] in
                    if let self = self{
                        self.leadingConstraint.constant = -offset - self.frame.width / 4
                        self.layoutSubviews()
                    }
                }, completion:nil)
                newMenuItemSelected?(selctedMenuItem,selectedMenuItemString)
            }
        default:
            break
        }
        
    }
}
