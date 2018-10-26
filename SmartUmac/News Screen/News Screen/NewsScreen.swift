//
//  NewsScreen.swift
//  SmartUmac
//
//  Created by Ricardo on 26/10/2018.
//  Copyright © 2018 Ricardo. All rights reserved.
//

import UIKit
import SwiftSoup

class NewsScreenController:UITableViewController {
    
    let cellId = "cellId"
    
    var news:News? {
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        tableView.register(NewsViewCell.self, forCellReuseIdentifier: cellId)
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100;
        setHeaderView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let news = news {
            if let details = news.details {
                return details.count
            }
        }
        else {
            return 0
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let newsContent = news {
            if newsContent.details != nil {
                return 1
            }
        }
        else {
            return 0
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let newsContent = news{
            if let details = newsContent.details {
                if let title = details[section].locale{
                    if  title == "en_US"{
                        return "Details (English)"
                    }
                    else if title == "pt_PT" {
                        return "Details (Portuguese)"
                    }
                    else if title == "zh_TW"{
                        return "Details (Chinese)"
                    }
                    
                }
            }
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NewsViewCell
        if let newsContent = news{
            if let details = newsContent.details {
                if let content = details[indexPath.section].content{
                    
                    do {
                        
                        let doc: Document = try SwiftSoup.parse(content)
                        let elems: Elements = try doc.select("p")
                        var totalContent = "\n"
                        
                        for elem in elems {
                            try print(elem.text())
                            try totalContent += elem.text()
                            totalContent += "\n"
                        }
                        
                        cell.detailsView.text = totalContent
                        
                    }catch Exception.Error(let type, let message) {
                        print("")
                    } catch {
                        print("")
                    }
                    
                }
            }
        }
        return cell
    }
    
    
    func setHeaderView(){
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 400))
        let scrollViewController = NewsScreenScrollViewController(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
        let titleView = UITextView(frame: CGRect(x: 0, y: scrollViewController.frame.height, width: self.view.frame.width, height: 100))
        
        
        //bannerView.numberOfLines = 0
        titleView.textAlignment = NSTextAlignment.center
        titleView.font = UIFont.boldSystemFont(ofSize: 12.0)
        titleView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        //bannerView.text
        
        //display images on banner
        
        var imageLinks = [String]()
        var titles = ""
        
        if let news = news {
            if let links = news.common?.imageUrls {
                for link in links{
                    imageLinks.append(link)
                }
            }
            if let details = news.details {
                for detail in details {
                    if let title = detail.title{
                        titles += title + "\n"
                    }
                }
            }
        }
        
        
        scrollViewController.scrollView?.contentSize = CGSize(width: CGFloat(imageLinks.count) * scrollViewController.frame.width, height: scrollViewController.frame.height)
        
        scrollViewController.featurePageControl.numberOfPages = imageLinks.count
        
        for (index, link) in imageLinks.enumerated(){
            
            let url = URL(string: link)
            
            URLSession.shared.dataTask(with: url!) { (data, response, err) in
                
                guard let data  = data else {return}
                
                DispatchQueue.main.async {
                    
                    let image =  UIImage(data: data)
                    
                    let featureView = UIView(frame: CGRect(x:0, y:0, width: scrollViewController.frame.width, height:scrollViewController.frame.height))
                    let imageView = UIImageView(frame: CGRect(x:0, y:0, width:scrollViewController.frame.width, height:scrollViewController.frame.height))
                    imageView.contentMode = .scaleAspectFit
                    imageView.image = image
                    featureView.addSubview(imageView)
                    scrollViewController.scrollView?.addSubview(featureView)
                    featureView.frame.size.width = scrollViewController.bounds.size.width
                    featureView.frame.origin.x = CGFloat(index) * scrollViewController.bounds.size.width
                    
                }
                
                }.resume()
        }
        
        titleView.text = titles
        
        header.addSubview(scrollViewController)
        header.addSubview(titleView)
        
        
        tableView.tableHeaderView = header
    }
}

class NewsViewCell:UITableViewCell{
    
    var detailsView:UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.numberOfLines = 0
        return tv
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(detailsView)
        addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: detailsView)
        addConstraintsWithFormat(format: "V:|-10-[v0]-10-|", views: detailsView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

