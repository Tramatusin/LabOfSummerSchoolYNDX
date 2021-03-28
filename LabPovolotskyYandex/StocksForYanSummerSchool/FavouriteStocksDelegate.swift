//
//  FavouriteStocksDelegate.swift
//  StocksForYanSummerSchool
//
//  Created by Виктор Поволоцкий on 26.03.2021.
//

import Foundation


protocol FavouriteStockDelegate {
    func addToFavourites(company: Stock)
    
    func removeFavourite(company: Stock)
}
