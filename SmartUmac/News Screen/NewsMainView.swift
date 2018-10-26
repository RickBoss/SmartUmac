//
//  NewsMainView.swift
//  SmartUmac
//
//  Created by Ricardo on 26/10/2018.
//  Copyright © 2018 Ricardo. All rights reserved.
//

import UIKit

import UIKit

class NewsTableViewController: UITableViewController{
    
    var news:[News]? // Variable to hold all the news downloaded from the API
    
    let dateFrom:UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor.lightGray
        tf.textAlignment = NSTextAlignment.center
        return tf
    }()
    
    let dateFromLabel:UILabel = {
        let label = UILabel()
        
        label.text = "Starting Date"
        return label
    }()
    
    let dateToLabel:UILabel = {
        let label = UILabel()
        label.text = "Ending Date"
        return label
    }()
    
    let dateTo:UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor.lightGray
        tf.text = "2018-03-31"
        tf.textAlignment = NSTextAlignment.center
        return tf
    }()
    
    var dateFromString:String = ""
    var dateToString:String = ""
    
    let searchButton:UIButton = {
        let button = UIButton()
        button.setTitle("Search", for: .normal)
        button.backgroundColor = .red
        return button
    }()
    
    lazy var datePicker:UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(datePickerChanged(_sender:)), for: .valueChanged)
        return picker
    }()
    
    lazy var datePicker2:UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(datePickerChanged(_sender:)), for: .valueChanged)
        return picker
    }()
    
    lazy var toolBar:UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width:  view.frame.width, height: 40))
        toolbar.barStyle = .blackTranslucent
        toolbar.tintColor = .white
        
        let todayButton = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(todayPressed(_sender:)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed(_sender:)))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width/3, height: 40))
        label.text = "Select a date"
        
        label.textColor = .yellow
        label.textAlignment = .center
        
        label.font = .systemFont(ofSize: 17)
        let labelButton = UIBarButtonItem(customView: label)
        
        toolbar.setItems([todayButton, flexButton, labelButton, flexButton, doneButton], animated: true)
        
        return toolbar
    }()
    
    lazy var dateFormatter:DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    var scrollView:MainNewsScrollViewController?
    
    let cellId = "cellId"
    
    var headerView:UIView = UIView()
    var expandButton = UIView()
    var expanded = false
    
    var expandButtonLabel:UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Press to open search"
        label.textAlignment = NSTextAlignment.center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    var link:String = ""
    
    var currentPage:Int = 1
    var size:Int = 0
    var total_pages:Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFrom.inputView = datePicker
        dateTo.inputView = datePicker2
        
        dateFrom.inputAccessoryView = toolBar
        dateTo.inputAccessoryView = toolBar
        
        tableView.rowHeight = 100
        tableView.register(newsCell.self, forCellReuseIdentifier: cellId)
        setHeaderView()
        
        searchButton.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
        
        
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFrom.text = dateFormatter.string(from: startOfMonth!)
        dateFromString = dateFormatter.string(from: startOfMonth!) + "T00:00:00"
        
        let comps2 = NSDateComponents()
        comps2.month = 1
        comps2.day = -1
        let endOfMonth = Calendar.current.date(byAdding: comps2 as DateComponents, to: startOfMonth!)
        dateTo.text = dateFormatter.string(from: endOfMonth!)
        dateToString = dateFormatter.string(from: endOfMonth!) + "T23:59:59"
        
        link = "https://api.data.umac.mo/service/media/news/v1.0.0/all?date_from=" + dateFromString  + "&date_to=" + dateToString + "&sort_by=-lastModified&count"
        
        readJson(link: link) { (data) in
            if let size = data._size {
                self.size = size
            }
            if let total_pages = data._total_pages{
                self.total_pages = total_pages
            }
            if let data = data._embedded{
                
                self.news = data
                self.scrollView?.news = data
                self.scrollView?.downloadImages()
                self.tableView.reloadData()
                
            }
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = news?.count{
            return count
        }
        else {
            return 0
        }
    }
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            as! newsCell
        if let totalNews = news {
            if let date = totalNews[indexPath.row].common?.publishDate{
                
                newsCell.newsDate.text = date.components(separatedBy: "T")[0]
            }
            if let details = totalNews[indexPath.row].details{
                if details.count > 0 {
                    if let title = details[0].title {
                        newsCell.newsTitle.text = title
                    }
                }
            }
            
            if let sampleImageURL = totalNews[indexPath.row].common?.imageUrls?[0]{
                let jsonString = sampleImageURL
                
                let url = URL(string: jsonString)
                
                newsCell.newsImage.image = UIImage(named: "placeholder")
                
                if let imageFromCache = imageCache.object(forKey: jsonString as AnyObject) as? UIImage {
                    newsCell.newsImage.image = imageFromCache
                }
                    
                else{
                    
                    
                    URLSession.shared.dataTask(with: url!) { (data, response, err) in
                        
                        guard let data  = data else {return}
                        
                        DispatchQueue.main.async {
                            
                            let imageToCache =  UIImage(data: data)
                            
                            self.imageCache.setObject(imageToCache!, forKey: jsonString as AnyObject)
                            
                            newsCell.newsImage.image = imageToCache
                        }
                        
                        }.resume()
                }
            }
        }
        return newsCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsScreen = NewsScreenController()
        if let totalNews = self.news {
            newsScreen.news = totalNews[indexPath.row]
        }
        self.navigationController?.pushViewController(newsScreen, animated: true)
    }
    
    //infinite scrolling
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if currentPage < total_pages{
            
            let lastSectionIndex = tableView.numberOfSections - 1
            let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
            if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
                // print("this is the last cell")
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                spinner.startAnimating()
                spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
                
                //organizationActivities += OrganizationActivity.getOrganizationActivities()
                
                currentPage += 1
                
                link = "https://api.data.umac.mo/service/media/news/v1.0.0/all?date_from=" + dateFrom.text! + "&date_to=" + dateTo.text! + "&sort_by=-lastModified&page=\(currentPage)"
                
                
                self.tableView.tableFooterView = spinner
                self.tableView.tableFooterView?.isHidden = false
                
                readJson(link: link) { (downloaded) in
                    if let data = downloaded._embedded{
                        for new in data{
                            self.news?.append(new)
                        }
                        
                        DispatchQueue.main.async {
                            tableView.reloadData()
                        }
                    }
                }
                
                
            }
        }
    }
    
    
    
    @objc func searchButtonPressed(){
        link = "https://api.data.umac.mo/service/media/news/v1.0.0/all?date_from=" + dateFromString + "&date_to=" + dateToString + "&sort_by=-lastModified&count"
        readJson(link: link) { (data) in
            
            if let size = data._size {
                self.size = size
            }
            if let total_pages = data._total_pages{
                self.total_pages = total_pages
            }
            
            if let data = data._embedded{
                
                self.news = data
                self.tableView.reloadData()
                
            }
        }
    }
    
    @objc func datePickerChanged(_sender: UIDatePicker){
        if _sender == datePicker{
            dateFrom.text = dateFormatter.string(from: _sender.date)
            dateFromString = dateFormatter.string(from: _sender.date) + "T00:00:00"
            
        }
        else if _sender == datePicker2{
            dateTo.text = dateFormatter.string(from: _sender.date)
            dateToString = dateFormatter.string(from: _sender.date) + "T23:59:59"
        }
    }
    
    @objc func todayPressed(_sender: UIToolbar){
        dateFrom.text = dateFormatter.string(from: Date())
        dateTo.text = dateFormatter.string(from: Date())
        dateFrom.resignFirstResponder()
        dateTo.resignFirstResponder()
    }
    
    @objc func donePressed(_sender: UIDatePicker){
        dateFrom.resignFirstResponder()
        
        dateTo.resignFirstResponder()
        
    }
    
    @objc func expandCollapse(){
        if expanded == false {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                var frame = self.headerView.frame
                frame.size.height = 480
                self.headerView.frame = frame
                self.tableView.tableHeaderView = self.headerView
                self.headerView.layoutIfNeeded()
                self.expandButton.frame = CGRect(x: 0, y: (self.scrollView?.frame.height)! + 150, width: self.view.frame.width, height: 30)
            },completion: nil)
            expanded = true
            expandButtonLabel.text = "Press to close search"
            
            headerView.addSubview(dateFromLabel)
            headerView.addSubview(dateFrom)
            headerView.addSubview(dateToLabel)
            headerView.addSubview(dateTo)
            headerView.addSubview(searchButton)
            headerView.addSubview(searchButton)
            
            dateFromLabel.frame = CGRect(x: 10, y: (self.scrollView?.frame.height)! + 10, width: 200, height: 30)
            dateFrom.frame = CGRect(x: dateFromLabel.frame.width + 10, y: (self.scrollView?.frame.height)! + 10, width: 150, height: 30)
            
            dateToLabel.frame = CGRect(x: 10, y: (self.scrollView?.frame.height)! + dateFromLabel.frame.height + 20, width: 200, height: 30)
            dateTo.frame = CGRect(x:  dateToLabel.frame.width + 10, y: (self.scrollView?.frame.height)! + dateFromLabel.frame.height + 20, width: 150, height: 30)
            
            searchButton.frame = CGRect(x:  dateToLabel.frame.width + 10, y: (self.scrollView?.frame.height)! + dateFromLabel.frame.height + dateToLabel.frame.height + 30, width: 100, height: 30)
            
            
        }
        else {
            dateFromLabel.removeFromSuperview()
            dateFrom.removeFromSuperview()
            dateToLabel.removeFromSuperview()
            dateTo.removeFromSuperview()
            searchButton.removeFromSuperview()
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                var frame = self.headerView.frame
                frame.size.height = 330
                self.headerView.frame = frame
                self.tableView.tableHeaderView = self.headerView
                self.headerView.layoutIfNeeded()
                self.expandButton.frame = CGRect(x: 0, y: (self.scrollView?.frame.height)!, width: self.view.frame.width, height: 30)
                
                
            },completion: nil)
            expanded = false
            expandButtonLabel.text = "Press to open search"
            
        }
    }
    
    //Create a header view
    
    func setHeaderView(){
        
        let rect = CGRect(x:0, y:0, width:self.view.frame.width, height:330)
        headerView = UIView(frame: rect)
        
        
        
        self.scrollView = MainNewsScrollViewController(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
        expandButton = UIView(frame: CGRect(x: 0, y: (self.scrollView?.frame.height)!, width: self.view.frame.width, height: 30))
        expandButton.backgroundColor = .red
        
        expandButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandCollapse)))
        expandButton.addSubview(expandButtonLabel)
        
        expandButton.addConstraintsWithFormat(format: "H:|[v0]|", views: expandButtonLabel)
        expandButton.addConstraintsWithFormat(format: "V:|[v0]|", views: expandButtonLabel)
        
        
        headerView.addSubview(self.scrollView!)
        headerView.addSubview(expandButton)
        
        
        headerView.backgroundColor = .clear
        tableView.tableHeaderView = headerView
    }
    
    
    func readJson(link:String, completion: @escaping (NewsData)->()){
        
        let jsonUrlString = link
        
        
        if let url = URL(string: jsonUrlString) {
            var request = URLRequest(url: url)
            // Set headers
            request.setValue("Bearer f0b642d6-6023-3421-a7e3-05d84aec3946", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else {
                    return
                }
                
                do{
                    let newsData = try JSONDecoder().decode(NewsData.self, from:data)
                    
                    DispatchQueue.main.async {
                        completion(newsData)
                    }
                    
                } catch let jsonErr{
                    print(jsonErr)
                }
                }.resume()
            
        }
    }
}

class newsCell:UITableViewCell{
    
    var newsDate:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var newsTitle:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    var newsImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(newsDate)
        addSubview(newsTitle)
        addSubview(newsImage)
        
        addConstraintsWithFormat(format: "H:|-10-[v0]-20-[v1]-10-|", views: newsDate, newsTitle)
        addConstraintsWithFormat(format: "V:|-10-[v0]-10-[v1(50)]", views: newsDate, newsImage)
        addConstraintsWithFormat(format: "H:|-10-[v0(50)]", views: newsImage)
        addConstraintsWithFormat(format: "V:|-10-[v0]-10-|", views: newsTitle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIView {
    
    func addConstraintsWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String:UIView]()
        
        for (index, view) in views.enumerated() {
            
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
        
    }
    
}




