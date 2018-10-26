//
//  MainEventsScrollView.swift
//  SmartUmac
//
//  Created by Ricardo on 26/10/2018.
//  Copyright © 2018 Ricardo. All rights reserved.
//


import UIKit

class EventsScrollViewController:UIView, UIScrollViewDelegate{
    
    var scrollView:UIScrollView?
    
    var timer = Timer()
    
    var events:[Event]?
    
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
    
    var bannerView:UITextView = {
        let ul = UITextView()
        //ul.numberOfLines = 0
        ul.textAlignment = NSTextAlignment.center
        ul.font = UIFont.boldSystemFont(ofSize: 14.0)
        ul.textColor = .white
        ul.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        ul.text = ""
        return ul
    }()
    
    var index = 0
    
    var eventsTitles = [String]()
    var imageLinks = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        bannerView.backgroundColor = .lightGray
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.scrollView?.delegate = self
        self.scrollView?.showsHorizontalScrollIndicator = false
        
        self.scrollView?.isPagingEnabled = true
        self.scrollView?.isUserInteractionEnabled = true
        //loadFeatures()
        
        featurePageControl.numberOfPages = 3
        
        addSubview(scrollView!)
        bringSubview(toFront: scrollView!)
        addSubview(featurePageControl)
        bringSubview(toFront: featurePageControl)
        addSubview(bannerView)
        bringSubview(toFront: bannerView)
        self.addConstraintsWithFormat(format: "V:[v0(60)]|", views: bannerView)
        self.addConstraintsWithFormat(format: "H:|[v0]|", views: bannerView)
        
        
        featurePageControl.topAnchor.constraint(equalTo: self.topAnchor, constant: self.frame.height - (featurePageControl.frame.height) - 20).isActive = true
        featurePageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func downloadData(){
        
        if let totalEvents = events {
            for event in totalEvents[...2]{
                if let link = event.common?.posterUrl{
                    imageLinks.append(link)
                }
                if let title = event.details?[0].title{
                    eventsTitles.append(title)
                }
            }
        }
        
        featurePageControl.numberOfPages = imageLinks.count
        bannerView.text = eventsTitles[0]
        self.scrollView?.contentSize = CGSize(width: CGFloat(imageLinks.count) * self.frame.width, height: self.frame.height)
        print(imageLinks)
        //download the images
        
        for (index, link) in imageLinks.enumerated(){
            let url = URL(string: link)
            
            URLSession.shared.dataTask(with: url!) { (data, response, err) in
                
                guard let data  = data else {return}
                
                DispatchQueue.main.async {
                    
                    let image =  UIImage(data: data)
                    
                    let featureView = UIView(frame: CGRect(x:0, y:0, width: self.frame.width, height:self.frame.height))
                    let imageView = UIImageView(frame: CGRect(x:0, y:0, width:self.frame.width, height:self.frame.height))
                    imageView.image = image
                    imageView.contentMode = .scaleAspectFit
                    featureView.addSubview(imageView)
                    self.scrollView?.addSubview(featureView)
                    featureView.frame.size.width = self.bounds.size.width
                    featureView.frame.origin.x = CGFloat(index) * self.bounds.size.width
                    
                }
                
                }.resume()
        }
        
        
    }
    
    @objc func timerAction() {
        
        let position = (self.scrollView?.contentOffset.x)! + self.frame.width
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.scrollView?.scrollRectToVisible(CGRect(x:position, y:0, width:self.frame.width, height:self.frame.height), animated: true)
        }, completion: nil)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        featurePageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        bannerView.text = eventsTitles[ Int(scrollView.contentOffset.x / scrollView.frame.size.width)]
        
        
        
        
    }
}
