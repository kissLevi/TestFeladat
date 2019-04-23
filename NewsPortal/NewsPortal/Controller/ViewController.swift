//
//  ViewController.swift
//  NewsPortal
//
//  Created by Kiss Levente on 2019. 04. 19..
//  Copyright © 2019. Kiss Levente. All rights reserved.
//

import UIKit

protocol MenuDelegate{
    func menuItems()->[String]
    func selectMenuItem(withName:String)
}

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,MenuDelegate {
    
    typealias CommentData = (title:String,id:String)
    
    enum DataType{
        case newData(News)
        case commentData(CommentData)
        case comment(String)
    }
    
    private struct StoryBoard{
        static let newsCell:String = "NewsCell"
        static let simpleCell:String = "SimpleCell"
        static let commentCell:String = "CommentCell"
        static let showNewSegueIdentifier = "ShowNew"
    }
    
    var newDataSource:NewsDataSource!
    
    var data:[String:[DataType]] = [:]
    
    //MARK:- SideMenu menuitems
    
    var selectedMenuItemName:String = "News list"
    
    var currentData:[DataType]?{ return data[selectedMenuItemName] }
    
    //MARK:- TopMenubar categories
    
    @IBOutlet weak var topbarMenu: TopMenubar!
    
    @IBOutlet weak var topMenuBarHeight: NSLayoutConstraint!
    
    var currentCategory:String { return topbarMenu.selectedMenuItemString }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newDataSource = NewsDataSource()
        
        setupNavigationItems()
        registerCells()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let new = sender as? News, let viewController = segue.destination as? NewsViewController{
            viewController.newsDataSource = newDataSource
            viewController.newId = new.id
        }
        if let menuViewController = segue.destination as? MenuViewController{
            menuViewController.modalPresentationStyle = .overFullScreen
            menuViewController.menuDelegate = self
        }
    }
    
    
    //MARK:- UITableViewDataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (currentData?.count ?? 0) != 0{
            loadingIndicator.stopAnimating()
        }
        return currentData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentData =  currentData?[indexPath.row]{
            if case DataType.newData(let news) = currentData {
                let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.newsCell, for: indexPath) as! NewsCell
                setup(cell: cell, withNew: news)
                return cell
            }
            else if case DataType.commentData(let comment) = currentData{
                let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.simpleCell, for: indexPath)
                cell.textLabel?.text = comment.title
                cell.textLabel?.numberOfLines = 0
                return cell
            }
            else if case DataType.comment(let comment) = currentData{
                let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.commentCell, for: indexPath) as! CommentCell
                cell.commentTextLabel.text = comment
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.simpleCell, for: indexPath)
        return cell
    }
    
    //MARK:- UITableViewDelegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentData = currentData?[indexPath.row]{
            if case DataType.newData(let news) = currentData {
                performSegue(withIdentifier: StoryBoard.showNewSegueIdentifier, sender: news)
            }
            else if case DataType.commentData(let commentData) = currentData {
                newDataSource.getComment(forNewWithId: commentData.id) {[weak self] (comments) in
                    DispatchQueue.main.async {
                        self?.data[commentData.title] = comments?.map({ (comment) -> DataType in
                            DataType.comment(comment)
                        })
                        self?.selectMenuItem(withName: commentData.title)
                    }
                }
            }
        }
    }
    
    //MARK:- menudelegate mathods
    
    func menuItems() -> [String] {
        let menuItems = ["News list","Comments"]
        return menuItems
    }
    
    func selectMenuItem(withName menuName: String) {
        selectedMenuItemName = menuName
        title = menuName
       
        if currentData?.count == 0{
             loadingIndicator.stopAnimating()
        }
        if let currentData = currentData,!currentData.isEmpty ,case DataType.comment(_) = currentData.first!  {
            tableView.backgroundColor = .white
            topMenuBarHeight.constant = 0
        }else if currentData == nil || currentData?.isEmpty ?? true{
            tableView.backgroundColor = .white
            topMenuBarHeight.constant = 0
        }
        else{
            if case DataType.commentData(_) = currentData!.first!{
                tableView.backgroundColor = .white
            }
            if case DataType.newData(_) = currentData!.first!{
                tableView.backgroundColor = .black
            }
            topMenuBarHeight.constant = 40
        }
        tableView.reloadData()
    }
    
    

    //MARK:- private methods
    
    private func setupNavigationItems(){
        title = "Newsfeed"
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .white
        navigationItem.backBarButtonItem = backItem
        setMenuBar()
    }
    
    private func setMenuBar(){
        topbarMenu.newMenuItemSelected = {[weak self] (index,name) in
            self?.newDataSource.getNews(forCategoryWithName: name, andDo: { newNews in
                if let newNews = newNews{
                    let newList  = newNews.map({ (new) -> DataType in
                        DataType.newData(new)
                    })
                    self?.data.updateValue(newList, forKey: "News list")
                    self?.data["Comments"] = newNews.map({ (news) -> DataType in
                        DataType.commentData(CommentData(title:news.title,id:news.id))
                    })
                    self?.tableView.reloadData()
                }
            })
        }
        newDataSource.getCategories {[weak self] (categories) in
            var menuItems:[String] = []
            for category in categories{
                if category.count > 0{
                    menuItems.append(category.name)
                }
            }
            if menuItems.count > 1 {
                menuItems.append("All")
            }
            menuItems.sort()
            self?.topbarMenu.menuItems = menuItems
            self?.newDataSource.getNews(forCategoryWithName: (self?.topbarMenu.selectedMenuItemString)!, andDo: { newNews in
                if let newNews = newNews{
                    DispatchQueue.main.async {
                        self?.data["News list"] = newNews.map({ (new) -> DataType in
                            DataType.newData(new)
                        })
                        self?.data["Comments"] = newNews.map({ (news) -> DataType in
                            DataType.commentData(CommentData(title:news.title,id:news.id))
                        })
                        self?.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    private func registerCells(){
        tableView.register(NewsCell.self, forCellReuseIdentifier: StoryBoard.newsCell)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: StoryBoard.simpleCell)
        tableView.register(CommentCell.self, forCellReuseIdentifier: StoryBoard.commentCell)
    }
    
    private func setup(cell:NewsCell,withNew new:News){
        cell.newImageView.image = new.image
        cell.newTitleLabel.text = new.title
        cell.authorLabel.text = new.author
    }
    
    private func setupLoadingIndicator(toDataloading dataLoading:Bool){
        
    }

}

