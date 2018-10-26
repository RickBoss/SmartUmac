//
//  HolidaysModel.swift
//  SmartUmac
//
//  Created by Ricardo on 26/10/2018.
//  Copyright © 2018 Ricardo. All rights reserved.
//

import Foundation

class HolidaysData:Decodable{
    var _embedded:[Holiday]?
    var _returned:Int?
}

class Holiday:Decodable {
    var _id:String?
    var date:String?
    var holiday:String?
}
