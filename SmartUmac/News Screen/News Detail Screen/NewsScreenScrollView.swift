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
    
    var imagesCount:Int = 0
    
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
    
    var pagesLabel:UILabel = {
        let label = UILabel()
        label.textColor = .white
        //label.text = "1/3"
        label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.scrollView?.delegate = self
        self.scrollView?.showsHorizontalScrollIndicator = false
        
        self.scrollView?.isPagingEnabled = true
        self.scrollView?.isUserInteractionEnabled = true
      
        addSubview(scrollView!)
        bringSubview(toFront: scrollView!)
     
        addSubview(pagesLabel)
        
        pagesLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 40).isActive = true
        pagesLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        pagesLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        pagesLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
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
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //featurePageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pagesLabel.text = String(Int(scrollView.contentOffset.x / scrollView.frame.size.width) +  1) + "/\(imagesCount)"
        
    }
}
