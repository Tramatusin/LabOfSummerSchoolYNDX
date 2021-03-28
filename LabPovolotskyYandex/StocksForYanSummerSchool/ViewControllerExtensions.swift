//
//  ViewControllerExtensions.swift
//  StocksForYanSummerSchool
//
//  Created by Виктор Поволоцкий on 26.03.2021.
//

import Foundation
import UIKit


extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
                else{
                    // Отображение ихображения по умолчанию
                    DispatchQueue.main.async {
                        self?.image = UIImage(named: "defaultStockImage.png")
                    }
                }
            } else{
                // Отображение ихображения по умолчанию
                DispatchQueue.main.async {
                    self?.image = UIImage(named: "defaultStockImage.png")
                }
            }
        }
    }
}

extension Double{
    func rounding(count: Int)->String{
        return String(format: "%.\(count)f", self)
    }
}

extension ViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        switch pageType {
        case .allStocks:
            searchStock=companies.filter({$0.companyName.lowercased().prefix(searchText.count) == searchText.lowercased() || $0.companySybmol.lowercased().prefix(searchText.count)==searchText.lowercased()})
            searching = true
        case .favouriteStocks:
            searchFavouriteStock = listOfFavoritesCompanies.filter({$0.companyName.lowercased().prefix(searchText.count) == searchText.lowercased() ||
                $0.companySybmol.lowercased().prefix(searchText.count) == searchText.lowercased()})
            searchingFavourite = true
        }
        self.tableViewForStock.reloadData()
    }
}

extension ViewController: FavouriteStockDelegate {
    func addToFavourites(company: Stock) {
        company.isFavourite = true
        listOfFavoritesCompanies.append(company)
    }
    
    func removeFavourite(company: Stock) {
        company.isFavourite = false
        listOfFavoritesCompanies.remove(at: company.getIndexElement(stockarr: listOfFavoritesCompanies))
    }
}

extension ViewController: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch pageType {
            case .allStocks:
                if searching{
                    return searchStock.count
                }else{
                    return companies.count
                }
            case .favouriteStocks:
                if searchingFavourite{
                    return searchFavouriteStock.count
                }else{
                    return listOfFavoritesCompanies.count
                    
                }
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentidier", for: indexPath) as! CellOfStockTableViewCell
        switch pageType{
            case .allStocks:
                let stock: Stock = searching ? searchStock[indexPath.row] : companies[indexPath.row]
                cell.company = stock
                initCell(cell: cell, stock: stock, count: indexPath.row)
            case .favouriteStocks:
                let favouriteStock = searchingFavourite ? searchFavouriteStock[indexPath.row] : listOfFavoritesCompanies[indexPath.row]
                cell.company = favouriteStock
                initCell(cell: cell, stock: favouriteStock, count: indexPath.row)
        }
        
        cell.favouriteStockDelegate = self
        
        return cell
    }
}
