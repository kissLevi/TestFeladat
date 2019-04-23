//
//  NewsDataSource.swift
//  NewsPortal
//
//  Created by Kiss Levente on 2019. 04. 19..
//  Copyright © 2019. Kiss Levente. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class NewsDataSource : NSObject {
    
    typealias NewsDataComplitionHandler = (([News]?)->())
    
    typealias NewDataComplitionHandler = ((News?)->())
    
    var ref: DatabaseReference
    
    private let imageCache = NSCache<AnyObject,AnyObject>()
    
    private let semaphore = DispatchSemaphore(value: 1)
    
    override init() {
        ref = Database.database().reference()
    }
    
    func getCategories(andDo complitionHandler:@escaping (([Category])->())){
        ref.child("categories").observeSingleEvent(of: .value,with:  {(data) in
            let snapshotValue = data.value as! [String:[String:AnyObject]]
            let categoryKeys = snapshotValue.keys
            var categories:[Category] = []
            for key in categoryKeys{
                if let category = snapshotValue[key]{
                    categories.append(Category(id: key, name: category["name"] as! String, count : category["count"] as! Int))
                }
            }
            complitionHandler(categories)
        },withCancel: { error in
            print("error")
        })
    }
    
    func getComment(forNewWithId id:String, andDo complitionHandler:@escaping (([String]?)->())){
        ref.child("comments").queryOrdered(byChild: "new_id").queryEqual(toValue: id).observeSingleEvent(of: .value,with:  { (data) in
            if let snapshotValue = data.value as? [String:[String:AnyObject]]{
                let categoryKeys = snapshotValue.keys
                var comments:[String] = []
                for key in categoryKeys{
                    if let comment = snapshotValue[key]{
                        if let commentContent = comment["comment"] as? String{
                            comments.append(commentContent)
                        }
                    }
                }
                complitionHandler(comments)
            }else{
                complitionHandler(nil)
            }
            
        },withCancel: { error in
            print("error")
        })
    }
    
    func getAllNews(andDo complitionHandler:@escaping NewsDataComplitionHandler){
        ref.child("news").observeSingleEvent(of: .value,with: {(data) in
            if let news = self.pareseNews(fromDataSnapshot: data){
                complitionHandler(news)
            }
            else{
                complitionHandler(nil)
            }
            
        },withCancel: { error in
            print("error")
        })
    }
    
    func getNews(forCategoryWithName categoryName:String,andDo complitionHandler:@escaping NewsDataComplitionHandler){
        ref.removeAllObservers()
        if categoryName == "All"{
            getAllNews(andDo: complitionHandler)
        }
        else{
            getCategories {(categories) in
                let category = categories.first(where: {$0.name == categoryName})
                if let id = category?.id{
                    self.ref.child("news").queryOrdered(byChild: "create").observeSingleEvent(of: .value,with: {(data) in
                        data.ref.queryOrdered(byChild:"category_id").queryEqual(toValue: id).observe(.value, with: { (data) in
                            if let news = self.pareseNews(fromDataSnapshot: data){
                                complitionHandler(news)
                            }
                            else{
                                complitionHandler(nil)
                            }
                        })
                        
                    },withCancel: { error in
                        print("error")
                    })
                }
            }
        }
    }
    
    func getNew(withID id:String,andDo complitionHandler:@escaping NewDataComplitionHandler){
        ref.removeAllObservers()
        ref.child("news/\(id)").observe(.value) { (data) in
            if let new = data.value as? [String:AnyObject]{
                let url = new["image"] as! String
                self.getImage(forUrl: URL(string:url)!, andDo: { (image) in
                    if let image = image{
                        let author = new["author"] as! String
                        let content = new["content"] as! String
                        let category = new["category_id"] as! String
                        let create = new["create"] as! String
                        let title = new["title"] as! String
                        complitionHandler(News(id:id,author: author, category: category, content: content, create: self.stringToDate(string: create), image: image, title: title))
                    }
                })
            }
            else{
                complitionHandler(nil)
            }
        }
    }
    
    func add(Comment comment:String,toNewWithId newId:String){
        ref.child("comments").childByAutoId().setValue(["comment":comment,"new_id":newId])
    }
    
    func getImage(forUrl url:URL,andDo complitionHandler:@escaping ((UIImage?)->())){
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            complitionHandler(imageFromCache)
        }
        else{
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request){[weak self] data,response,error in
                if let data = data,let image = UIImage(data: data){
                    self?.imageCache.setObject(image, forKey: url.absoluteString as AnyObject)
                    complitionHandler(image)
                }
                else{
                    complitionHandler(nil)
                }
            }.resume()
        }
       
    }
    
    private func stringToDate(string:String)->Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd.' 'HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from:string)!
    }
    
    
    private func pareseNews(fromDataSnapshot snapshot:DataSnapshot)->[News]?{
        if let snapshotValue = snapshot.value as? [String:[String:AnyObject]]{
            let categoryKeys = snapshotValue.keys
            var news:[News] = []
            for key in categoryKeys{
                self.semaphore.wait()
                if let new = snapshotValue[key]{
                    let url = new["image"] as! String
                    self.getImage(forUrl: URL(string:url)!, andDo: { (image) in
                        if let image = image{
                            let author = new["author"] as! String
                            let content = new["content"] as! String
                            let category = new["category_id"] as! String
                            let create = new["create"] as! String
                            let title = new["title"] as! String
                            news.append(News(id:key,author: author, category: category, content: content, create: self.stringToDate(string: create), image: image, title: title))
                        }
                        self.semaphore.signal()
                    })
                }
            }
            news.sort(by: { (new1, new2) -> Bool in
                return new1.create > new2.create
            })
            return news
        }
        else{
            return nil
        }
    }
}

struct Category{
    var id:String
    var name:String
    var count:Int
}

struct News {
    var id:String
    var author:String
    var category:String
    var content:String
    var create:Date
    var image:UIImage
    var title:String
}
