//
//  NewsViewController.swift
//  NewsPortal
//
//  Created by Kiss Levente on 2019. 04. 20..
//  Copyright © 2019. Kiss Levente. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController,UITextViewDelegate {

    var newId:String?{
        didSet{
            if let newId = newId{
                newsDataSource?.getNew(withID: newId, andDo: {[weak self] (news) in
                    if let new = news{
                        self?.new = new
                        self?.setupViews()
                    }
                })
            }
        }
    }
    
    private func setupViews(){
        imageView.image = new.image
        authorLabel.text = new.author
        titleLabel.text = new.title
        textView.text = new.content
    }
    
    var newsDataSource:NewsDataSource?
    
    private var new:News!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var textView: UITextView!{
        didSet{
            textView.delegate = self
            textView.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    
    @IBOutlet weak var imageHeighConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationItems()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < abs(112)
        {
            let newConstant = 88 + 122 - abs(scrollView.contentOffset.y)
            imageHeighConstraint.constant = newConstant
        }
    }
    
    @IBAction func commentButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Komment írása", message: "Írja meg megjegyzését a cikkel kapcsolatban", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Komment szövege"
        }
        alert.addAction(UIAlertAction(title: "Megosztás", style: .default, handler: { [weak alert,self] (_) in
            let textField = alert?.textFields![0]
            self.commentAdded(withText: textField!.text!)
        }))
        alert.addAction(UIAlertAction(title: "Mégse", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func commentAdded(withText commentText:String){
        if let newDatasource = newsDataSource{
            newDatasource.add(Comment: commentText, toNewWithId: new.id)
        }
    }
    
    private func setupNavigationItems(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationItem.backBarButtonItem?.title = ""
    }
}
