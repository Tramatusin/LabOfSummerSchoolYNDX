//
//  Stock.swift
//  StocksForYanSummerSchool
//
//  Created by Виктор Поволоцкий on 19.03.2021.
//

import Foundation


class Stock {
    public let companyName:String
    public let companySybmol:String
    public let companyPrice:Double
    public var priceChange: Double
    public var percent: Double
    public var priceChangeText: String{
        return priceChange>=0 ?
            "+\(priceChange.rounding(count: 2))(+\(percent.rounding(count: 2))%)$" :
            "\(priceChange.rounding(count: 2))(\(percent.rounding(count: 2))%)$"
    }
    public var priceChangedUp: Bool{
        return priceChange>=0 ? true : false
    }
    public var imageString: String{
        return "https://storage.googleapis.com/iex/api/logos/\(companySybmol).png"
    }
    public var isFavourite: Bool = false
    
    init(comName: String, comSybmol: String,price: Double,priceChange: Double,percent: Double) {
        self.companyName=comName
        self.companySybmol=comSybmol
        self.companyPrice=price
        self.priceChange=priceChange
        self.percent = percent
    }
    
    public func getIndexElement(stockarr: [Stock])->Int{
        return stockarr.firstIndex(where: {element in
            return element.companyName == self.companyName
        }) ?? 0
    }
}
