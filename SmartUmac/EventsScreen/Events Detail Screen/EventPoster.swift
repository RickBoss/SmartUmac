//
//  EventPoster.swift
//  SmartUmac
//
//  Created by Ricardo on 26/10/2018.
//  Copyright © 2018 Ricardo. All rights reserved.
//

import UIKit

class PosterView:UIViewController, UIScrollViewDelegate{
    
    var image:UIImage?
    var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        if let zoomableImage = image {
            imageView.image = zoomableImage
        }
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        view.addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
        
    }
    
    
}
