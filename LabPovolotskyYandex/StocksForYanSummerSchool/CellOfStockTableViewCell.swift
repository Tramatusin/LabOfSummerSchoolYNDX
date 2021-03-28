//
//  CellOfStockTableViewCell.swift
//  StocksForYanSummerSchool
//
//  Created by Виктор Поволоцкий on 22.03.2021.
//

import Foundation

import UIKit

class CellOfStockTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var changeOfPriceLbl: UILabel!
    @IBOutlet weak var imageOfCompany: UIImageView!
    @IBOutlet weak var nameOfCompanyLbl: UILabel!
    @IBOutlet weak var shortNameOfCompanyLbl: UILabel!
    @IBOutlet weak var priceOfCompanyLbl: UILabel!
    @IBOutlet weak var favoriteAddButton: UIButton!
    var company: Stock?
    var favouriteStockDelegate: FavouriteStockDelegate?
    
    @IBAction func favoritePressButton(_ sender: Any) {
        if let company = company, company.isFavourite == false {
            favoriteAddButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            favoriteAddButton.tintColor = .systemYellow
            favouriteStockDelegate?.addToFavourites(company: company)
        }else if let company = company, company.isFavourite{
            favouriteStockDelegate?.removeFavourite(company: company)
            favoriteAddButton.setImage(UIImage(systemName: "star"), for: .normal)
            favoriteAddButton.tintColor = .systemYellow
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if let company = company, company.isFavourite{
            favoriteAddButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            favoriteAddButton.tintColor = .systemYellow
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
