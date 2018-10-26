//
//  EventsModel.swift
//  SmartUmac
//
//  Created by Ricardo on 26/10/2018.
//  Copyright © 2018 Ricardo. All rights reserved.
//

import Foundation

class EventsData:Decodable {
    var _embedded:[Event]?
    var _returned:Int?
}

class Event:Decodable {
    var _id:String?
    var itemId:Int?
    var lastModified:String?
    var common:CommonE?
    var details:[DetailE]?
    
}

class CommonE:Decodable {
    var publishDate:String?
    var dateFrom:String? //done
    var dateTo:String?
    var posterUrl:String? //done
    var timeFrom:String?//done
    var timeTo:String?//done
}

class DetailE:Decodable{
    var locale:String? //done
    var title:String? //done
    var contactEmail:String? //done
    var contactFax:String? //done
    var contactName:String? //done
    var contactPhone:String? //done
    var content:String?//done
    var dateString:String? //done
    var languages:[String]? //done
    var organizedBys:[String]? //done
    var speakers:[String]? //done
    var targetAudiences:[String]? //done
    var timeString:String? //done
    var venues:[String]?// done
    var coorganizers:[String]? //done
    var remark:String?
    var attachmentLangUrls:[String]?
    
    
}
