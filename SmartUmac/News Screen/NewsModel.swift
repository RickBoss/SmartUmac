//
//  Model.swift
//  umacapi
//
//  Created by Ricardo on 05/10/2018.
//  Copyright © 2018 Ricardo. All rights reserved.
//

import Foundation

class NewsData:Decodable{
    var _embedded:[News]?
    var _returned:Int?
    var _size:Int?
    var _total_pages:Int?
}

class News:Decodable{
    
    var _id:String?
    var itemId:Int?
    var lastModified:String?
    var common:Common?
    var details:[Detail]?
    
}

class Common:Decodable{
    var publishDate:String?
    var imageUrls:[String]?
}

class Detail:Decodable{
    var locale:String?
    var title:String?
    var content:String?
}

