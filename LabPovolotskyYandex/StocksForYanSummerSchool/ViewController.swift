//
//  ViewController.swift
//  StocksForYanSummerSchool
//
//  Created by Виктор Поволоцкий on 19.03.2021.
//

import UIKit

enum PageType{
    case allStocks
    case favouriteStocks
}

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBarController: UISearchBar!
    @IBOutlet weak var StocksListButton: UIButton!
    @IBOutlet weak var favouriteListButton: UIButton!
    @IBOutlet weak var tableViewForStock: UITableView!
    
    var companies: [Stock] = []
    var listOfFavoritesCompanies: [Stock] = []
    var searchStock: [Stock] = []
    var searchFavouriteStock: [Stock] = []
    var searching = false
    var searchingFavourite = false
    var pageType: PageType = .allStocks
    var refreshController = UIRefreshControl()
    var stockCell = CellOfStockTableViewCell()
    
    @IBAction func allStockAction(_ sender: Any) {
        pageType = .allStocks
        StocksListButton.setTitleColor(UIColor.black, for: .normal)
        StocksListButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 28)
        favouriteListButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 18)
        favouriteListButton.setTitleColor(UIColor.systemGray3, for: .normal)
        self.tableViewForStock.reloadData()
        tableViewForStock.refreshControl=refreshController
    }
    
    @IBAction func favouriteStockAction(_ sender: Any) {
        pageType = .favouriteStocks
        favouriteListButton.setTitleColor(UIColor.black, for: .normal)
        favouriteListButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 28)
        StocksListButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 18)
        StocksListButton.setTitleColor(UIColor.systemGray3, for: .normal)
        self.tableViewForStock.reloadData()
        tableViewForStock.refreshControl = nil
    }
    
    override func viewDidLoad() {
        tableViewForStock.showsVerticalScrollIndicator = false
        searchBarController.delegate=self
        refreshController.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableViewForStock.refreshControl = refreshController
        super.viewDidLoad()
        loadSearchBar()
        //в последнее время происходят страшные вещи и АПИ начало переодически падать, если вдруг вы не получите динамический список компаний, всегда будет подгружаться дефолтный список из двух компаний. Если не работает, ни то, ни то, просто оцените код и умоляю, увидьте, что оно должно работать. Так же можно проверить ссылку и увидеть, что что-то не так с получаемыми данными. Так же у этого API бывают сбои с получением изображений компаний. Поэтому если что-то не загрузится поставится заглушка-изображение
        getAllCompanies()
        standartStockList()
        print(companies)
    }
    
    @objc
    func refresh(_ sender: Any){
        loadFromAPI()
    }
    
    func loadFromAPI(){
        companies = []
        getAllCompanies()
        standartStockList()
        tableViewForStock.reloadData()
        refreshController.endRefreshing()
    }
    
    func addToFavouriteAfterUpdate(){
        for i in 0..<listOfFavoritesCompanies.count{
            for j in 0..<companies.count {
                if(listOfFavoritesCompanies[i].companyName.lowercased() == companies[j].companyName.lowercased()){
                    companies[j]=listOfFavoritesCompanies[i]
                }
            }
        }
    }
    
    func standartStockList(){
        requestQuote(symbol: "YNDX")
        requestQuote(symbol: "MSFT")
        requestQuote(symbol: "GOOGL")
        requestQuote(symbol: "TSLA")
    }
    
    private func requestQuote(symbol: String){
        //я использую iex cloud API
        let apiKey:String="pk_d703a122c34047b18637c3fe86a1f2ae"
        guard let myURL = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=\(apiKey)") else {
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: myURL){[weak self](data,response,error) in
            if let dataRes=data,(response as? HTTPURLResponse)?.statusCode==200,error==nil{
                print(dataRes)
                self?.parseQuote(from: dataRes)
            }
            else{
                print("we have problems with HTTP response. Please check your network connection")
            }
        }
        dataTask.resume()
    }
    
    private func parseQuote(from data:Data){
        do{
            let jsonObj = try JSONSerialization.jsonObject(with: data)
            guard
                let json = jsonObj as? [String:Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double,
                let percent = json["changePercent"] as? Double
            
            else{
                print("invalid data")
                return
            }
            DispatchQueue.main.async {
                let company: Stock = Stock(comName: companyName, comSybmol: companySymbol, price: price, priceChange: priceChange,percent: percent)
                self.companies.append(company)
                print("company name:\(companyName)")
                print(self.companies)
                self.addToFavouriteAfterUpdate()
                DispatchQueue.main.async {
                    [weak self] in
                    self?.tableViewForStock.reloadData()
                }
            }
        }catch{
            print("JSON parsing ERROR")
        }
    }
    
    private func getAllCompanies(){
        let apiKey:String="pk_d703a122c34047b18637c3fe86a1f2ae"
        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/market/list/mostactive?token=\(apiKey)") else {return}
        let dataTask = URLSession.shared.dataTask(with: url)
        {[weak self](data,response,error) in
            if let myData = data,(response as? HTTPURLResponse)?.statusCode == 200,
               error == nil{
                self?.parseAllCompanies(from: myData)
            }else{
                self?.showError("Server connection error.Please cheeck your network connection")
            }
        }
        dataTask.resume()
    }
    
    private func parseAllCompanies(from data:Data){
        do{
            let jsonObj = try JSONSerialization.jsonObject(with: data)
            guard
                let json = jsonObj as? [Any]
                else {
                showError("invalid JSON")
                return
            }
            DispatchQueue.main.async {
                for item in json{
                    if let company = item as? [String:Any],
                       let companyName = company["companyName"] as? String,
                       let companySymbol = company["symbol"] as? String,
                       let price = company["latestPrice"] as? Double,
                       let priceChange = company["change"] as? Double,
                       let percent = company["changePercent"] as? Double{
                        let company: Stock = Stock(comName: companyName, comSybmol: companySymbol, price: price, priceChange: priceChange,percent: percent)
                        self.companies.append(company)
                    }else{
                        self.showError("invalid JSON")
                    }
                }
                self.addToFavouriteAfterUpdate()
                DispatchQueue.main.async {
                    [weak self] in
                    self?.tableViewForStock.reloadData()
                }
            }
            
        }catch{
            showError("invalid JSON format")
        }
    }
    
    /// Отображение окна с ошибкой пользователю
    private func showError(_ message: String){
        DispatchQueue.main.async {
        [weak self] in
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
            self?.present(alert, animated: true)
            
        }
    }
    
    func loadSearchBar(){
        StocksListButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 28)
        favouriteListButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 18)
        favouriteListButton.setTitleColor(UIColor.systemGray3, for: .normal)
        searchBarController.layer.borderWidth=1
        searchBarController.layer.borderColor = UIColor.white.cgColor
        if let textfield = searchBarController.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.white
            textfield.layer.borderColor=UIColor.black.cgColor
            textfield.layer.borderWidth = 1
            textfield.layer.cornerRadius = 15
            textfield.borderStyle = .none
            textfield.autoresizingMask =  UIView.AutoresizingMask.flexibleHeight
            textfield.frame = CGRect(x: 20, y: 44, width: 374, height: 100)
        }
        searchBarController.searchBarStyle = .default
        tableViewForStock.separatorStyle = .none
    }
    
    func initCell(cell: CellOfStockTableViewCell, stock: Stock,count: Int){
        if stock.isFavourite{
            cell.favoriteAddButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            cell.favoriteAddButton.tintColor = .systemYellow
        }else if !stock.isFavourite{
            cell.favoriteAddButton.setImage(UIImage(systemName: "star"), for: .normal)
            cell.favoriteAddButton.tintColor = .systemYellow
        }
        cell.layer.cornerRadius = 40
        cell.imageOfCompany.layer.cornerRadius=10
        let backGroundView = UIView()
        cell.nameOfCompanyLbl?.text = stock.companySybmol
        cell.nameOfCompanyLbl.font = UIFont(name: "Arial Rounded MT Bold", size: 18)
        cell.shortNameOfCompanyLbl.font = UIFont(name: "Arial", size: 11)
        cell.priceOfCompanyLbl.font = UIFont(name: "Arial Rounded MT Bold", size: 17)
        cell.shortNameOfCompanyLbl.text = stock.companyName
        cell.priceOfCompanyLbl.text = String(stock.companyPrice)+"$"
        cell.changeOfPriceLbl.text = stock.priceChangeText
        cell.changeOfPriceLbl.textColor = .systemGreen
        
        if !stock.priceChangedUp{
            cell.changeOfPriceLbl.text = stock.priceChangeText
            cell.changeOfPriceLbl.textColor = .red
        }
        
        if count % 2 == 0{
            backGroundView.backgroundColor = UIColor(named: "myWhite")
            cell.backgroundView = backGroundView
        }else{
            backGroundView.backgroundColor = UIColor.white
            cell.backgroundView=backGroundView
        }
        
        cell.imageOfCompany.load(url: URL(string: stock.imageString)!)
    }
}


