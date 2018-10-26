//
//  NewsScrollView.swift
//  SmartUmac
//
//  Created by Ricardo on 26/10/2018.
//  Copyright © 2018 Ricardo. All rights reserved.
//

import UIKit

class NewsScreenScrollViewController:UIView, UIScrollViewDelegate{
    
    var scrollView:UIScrollView?
    
    var timer = Timer()
    
    var news:[News]?
    
    var featurePageControl:UIPageControl = {
        var pg=UIPageControl()
        pg = UIPageControl(frame: CGRect(x:0, y:0, width: 30, height: 10))
        pg.translatesAutoresizingMaskIntoConstraints = false
        pg.currentPage = 1
        pg.backgroundColor = UIColor.clear
        pg.transform = CGAffineTransform(scaleX: 2, y: 2)
        pg.isUserInteractionEnabled = false
        return pg
    }()
    
    var index = 0
    
    var newsTitles = [String]()
    var imageLinks = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.scrollView?.delegate = self
        self.scrollView?.showsHorizontalScrollIndicator = false
        
        self.scrollView?.isPagingEnabled = true
        self.scrollView?.isUserInteractionEnabled = true
        //loadFeatures()
        
        //featurePageControl.numberOfPages = 3
        
        addSubview(scrollView!)
        bringSubview(toFront: scrollView!)
        addSubview(featurePageControl)
        bringSubview(toFront: featurePageControl)
            
        
        featurePageControl.topAnchor.constraint(equalTo: self.topAnchor, constant: self.frame.height - (featurePageControl.frame.height) - 40).isActive = true
        featurePageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func timerAction() {
        
        let position = (self.scrollView?.contentOffset.x)! + self.frame.width
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.scrollView?.scrollRectToVisible(CGRect(x:position, y:0, width:self.frame.width, height:self.frame.height), animated: true)
        }, completion: nil)
    }
    
    func downloadImages(){
        
        
        if let newsArray = news{
            for new in newsArray[...2]{
                print(new)
                if let link = new.common?.imageUrls?[0]{
                    imageLinks.append(link)
                }
                if let details = new.details {
                    
                    if let title = details[0].title{
                        newsTitles.append(title)
                    }
                    
                }
            }
        }
        
        self.scrollView?.contentSize = CGSize(width: CGFloat(imageLinks.count) * self.frame.width, height: self.frame.height)
        
        //download from links
        for (index, link) in imageLinks.enumerated(){
            
            let url = URL(string: link)
            
            URLSession.shared.dataTask(with: url!) { (data, response, err) in
                
                guard let data  = data else {return}
                
                DispatchQueue.main.async {
                    
                    let image =  UIImage(data: data)
                    
                    let featureView = UIView(frame: CGRect(x:0, y:0, width: self.frame.width, height:self.frame.height))
                    let imageView = UIImageView(frame: CGRect(x:0, y:0, width:self.frame.width, height:self.frame.height))
                    imageView.image = image
                    featureView.addSubview(imageView)
                    self.scrollView?.addSubview(featureView)
                    featureView.frame.size.width = self.bounds.size.width
                    featureView.frame.origin.x = CGFloat(index) * self.bounds.size.width
                    
                }
                
                }.resume()
        }
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        featurePageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
    }
}
