//
//  EventsMainView.swift
//  SmartUmac
//
//  Created by Ricardo on 26/10/2018.
//  Copyright © 2018 Ricardo. All rights reserved.
//

import UIKit

class EventsTableViewController:UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    
    var events:[Event]?
    let cellId = "cellId"
    let cellId2 = "cellId2"
    let imageCache = NSCache<AnyObject, AnyObject>()
    let headerView:UIView = {
        let uv = UIView()
        return uv
    }()
    
    var mainEventsScrollView:EventsScrollViewController?
    
    let buttonsCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = true
        
        return cv
    }()
    
    let buttonLabels = ["chinese cultural center of chinese studies","CYTC","CKLC","CKYC","PJC","LCWC","MMK","MCMC", "SPC", "EAC"]
    
    var categoryData = [String:[Event]]()
    var totalOrganizers = [String]()
    let organizerCellId = "organizerCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(EventCell.self, forCellReuseIdentifier: cellId)
        buttonsCollectionView.register(ButtonCell.self, forCellWithReuseIdentifier: cellId2)
        buttonsCollectionView.dataSource = self
        buttonsCollectionView.delegate = self
        
        //tableView.rowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        setHeaderView()
        
        readJson { (downloaded) in
            if let data = downloaded._embedded {
                self.events = data
                
                self.mainEventsScrollView?.events = data
                self.mainEventsScrollView?.downloadData()
                self.reshapeData()
                self.tableView.reloadData()
                self.buttonsCollectionView.reloadData()
                
            }
        }
        
    }
    
    //Organize Data
    
    func reshapeData(){
        if let totalEvents = events {
            for event in totalEvents{
                if let organizers = event.details?[0].organizedBys {
                    for organizer in organizers {
                        if categoryData[organizer] != nil {
                            categoryData[organizer]?.append(event)
                        }
                        else {
                            var array = [Event]()
                            array.append(event)
                            categoryData[organizer] = array
                        }
                    }
                }
            }
        }
        
        let keys = categoryData.keys
        for key in keys {
            totalOrganizers.append(key)
        }
        totalOrganizers.append("All Events")
        categoryData["All Events"] = events
    }
    
    var organizerTableView = UITableView()
    
    //Tableview functions
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            
            if let totalEvents = events {
                return totalEvents.count
            }
            return 0
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EventCell
        cell.posterIcon.image = UIImage(named: "news_icon")
        cell.dateLabel.text = ""
        cell.languageLabel.text = ""
        cell.organizerLabel.text = ""
        cell.timeLabel.text = ""
        if let totalEvents = events {
            
            if let posterLink = totalEvents[indexPath.row].common?.posterUrl {
                //download poster
                let url = URL(string: posterLink)
                
                cell.posterIcon.image = nil
                
                if let imageFromCache = imageCache.object(forKey: posterLink as AnyObject) as? UIImage {
                    cell.posterIcon.image = imageFromCache
                }
                    
                else {
                    
                    
                    URLSession.shared.dataTask(with: url!) { (data, response, error) in
                        guard let data  = data else {return}
                        DispatchQueue.main.async {
                            let imageToCache =  UIImage(data: data)
                            
                            self.imageCache.setObject(imageToCache!, forKey: posterLink as AnyObject)
                            cell.posterIcon.image = imageToCache
                        }
                        }.resume()
                    
                }
                
            }
            
            if let details = totalEvents[indexPath.row].details {
                
                if let title = details[0].title {
                    cell.titleLabel.text = title
                }
            }
            
            if let dateString =  totalEvents[indexPath.row].common?.dateFrom{
                cell.dateLabel.text = "Date: " + dateString.components(separatedBy: "T")[0]
            }
            
            if let languages = totalEvents[indexPath.row].details?[0].languages{
                var activityLanguages = "Language(s): "
                for (index, language) in languages.enumerated() {
                    if index + 1 != languages.count{
                        activityLanguages += language + ", "
                    }
                    else{
                        activityLanguages += language
                    }
                }
                cell.languageLabel.text = activityLanguages
            }
            
            if let organizers = totalEvents[indexPath.row].details?[0].organizedBys{
                var activityOrganizers = "Organized by: "
                for (index, organizer) in organizers.enumerated() {
                    if index + 1 != organizers.count{
                        activityOrganizers += organizer + ", "
                    }
                    else{
                        activityOrganizers += organizer
                    }
                }
                cell.organizerLabel.text = activityOrganizers
            }
            if let timeString = totalEvents[indexPath.row].details?[0].timeString{
                cell.timeLabel.text = "Time: " + timeString
            }
            
        }
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventScreen = EventsScreenController()
        if let totalEvents = events {
            eventScreen.event = totalEvents[indexPath.row]
        }
        self.navigationController?.pushViewController(eventScreen, animated: true)
        
    }
    
    var seperator:UIView = UIView()
    var expanded = true
    
    @objc func closeOpenHeader(){
        
        if expanded == true {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                var frame = self.headerView.frame
                frame.size.height = 50
                self.headerView.frame = frame
                self.buttonsCollectionView.frame.size.height = 0
                self.seperator.frame.size.height = 0
                self.tableView.tableHeaderView = self.headerView
                self.headerView.layoutIfNeeded()
                
            }, completion:nil)
            expanded = false
            
        }
        else {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 350)
                self.buttonsCollectionView.frame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: 298)
                self.seperator.frame.size.height = 2
                self.tableView.tableHeaderView = self.headerView
                self.headerView.layoutIfNeeded()
                
            }, completion:nil)
            
            
            
            
            expanded = true
        }
        
    }
    
    var monthPicker = UIPickerView()
    let monthField = UITextField()
    var dateFrom:String = "2018-10-01"
    var dateTo:String = "2018-10-31"
    var months = ["January", "February", "March", "April", "May", "June", "July", "August","September", "October", "November", "December"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return months.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return months[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        monthField.text = months[row]
    }
    
    var daysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
    
    @objc func donePressed() {
        monthField.resignFirstResponder()
        let month = months.index(of: monthField.text!)!
        dateFrom = "2018-\(month+1)-01"
        dateTo = "2018-\(month+1)-\(daysInMonth[month])"
        print(dateFrom)
        print(dateTo)
        readJson { (downloaded) in
            if let data = downloaded._embedded{
                self.events = data
                self.categoryData = [String:[Event]]()
                self.totalOrganizers = []
                self.reshapeData()
                self.categoryData["All Events"] = self.events
                self.buttonsCollectionView.reloadData()
                self.tableView.reloadData()
                
            }
        }
        
        
    }
    
    lazy var toolBar:UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width:  view.frame.width, height: 40))
        toolbar.barStyle = .blackTranslucent
        toolbar.tintColor = .white
        
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width/3, height: 40))
        label.text = "Select a month"
        
        label.textColor = .yellow
        label.textAlignment = .center
        
        label.font = .systemFont(ofSize: 17)
        let labelButton = UIBarButtonItem(customView: label)
        
        toolbar.setItems([labelButton, flexButton, doneButton], animated: true)
        
        return toolbar
    }()
    
    func setHeaderView(){
        
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 350)
        buttonsCollectionView.frame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: 298)
        buttonsCollectionView.backgroundColor = .white
        
        seperator = UIView(frame: CGRect(x: 0, y: 348, width: self.view.frame.width, height: 2))
        
        
        let headerTopBar = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        headerTopBar.backgroundColor = .red
        monthPicker.delegate = self
        monthPicker.dataSource = self
        
        
        let openCloseButton = UIButton()
        openCloseButton.frame = CGRect(x: 0, y: 0, width: headerTopBar.frame.width/2-1, height: 50)
        openCloseButton.backgroundColor = .black
        openCloseButton.layer.borderWidth = 1
        openCloseButton.layer.cornerRadius = 5
        openCloseButton.setTitle("Organizer", for: .normal)
        openCloseButton.backgroundColor = .red
        openCloseButton.setTitleColor(.white, for: .normal)
        openCloseButton.addTarget(self, action: #selector(closeOpenHeader), for: .touchUpInside)
        openCloseButton.layer.borderWidth = 0.0
        
        monthField.inputView = monthPicker
        monthField.frame = CGRect(x: headerTopBar.frame.width/2, y: 0, width: headerTopBar.frame.width/2, height: 50)
        monthField.backgroundColor = .black
        monthField.textColor = .white
        monthField.inputAccessoryView = toolBar
        monthField.backgroundColor = .red
        monthField.textAlignment = .center
        monthField.text = "Month"
        headerTopBar.addSubview(openCloseButton)
        headerTopBar.addSubview(monthField)
        
        
        
        
        //headerTopBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeOpenHeader)))
        seperator.backgroundColor = .lightGray
        
        headerView.addSubview(headerTopBar)
        headerView.addSubview(buttonsCollectionView)
        headerView.addSubview(seperator)
        tableView.tableHeaderView = headerView
        
    }
    
    //Collection View Functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalOrganizers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = buttonsCollectionView.dequeueReusableCell(withReuseIdentifier: cellId2, for: indexPath) as! ButtonCell
        cell.organizerLabel.text = totalOrganizers[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 10, 0, 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ButtonCell
        
        events = categoryData[cell.organizerLabel.text!]
        tableView.reloadData()
        
        
    }
    
    
    func readJson(completion: @escaping (EventsData)->()){
        
        let jsonUrlString = "https://api.data.umac.mo/service/media/events/v1.0.0/all?date_from=\(dateFrom)&date_to=\(dateTo)"
        
        
        if let url = URL(string: jsonUrlString) {
            var request = URLRequest(url: url)
            // Set headers
            request.setValue("Bearer 20716610-7238-3cb2-88cc-25976bcbedbf", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else {
                    return
                }
                
                
                do{
                    let eventsData = try JSONDecoder().decode(EventsData.self, from:data)
                    
                    DispatchQueue.main.async {
                        
                        completion(eventsData)
                    }
                    
                } catch let jsonErr{
                    print(jsonErr)
                }
                }.resume()
            
        }
    }
}

class EventCell:UITableViewCell {
    
    var posterIcon:UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "news_icon")
        return iv
    }()
    
    var dateLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    var titleLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 14)
        label.text = "Testing the title label"
        return label
    }()
    
    var languageLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    var organizerLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    var timeLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(posterIcon)
        addSubview(dateLabel)
        addSubview(titleLabel)
        addSubview(languageLabel)
        addSubview(organizerLabel)
        addSubview(timeLabel)
        
        addConstraintsWithFormat(format: "H:|-10-[v0(150)]-20-[v1]-20-|", views: posterIcon, titleLabel)
        addConstraintsWithFormat(format: "H:|-10-[v0(150)]-20-[v1]-20-|", views: posterIcon, languageLabel)
        addConstraintsWithFormat(format: "H:|-10-[v0(150)]-20-[v1]-20-|", views: posterIcon, organizerLabel)
        addConstraintsWithFormat(format: "H:|-10-[v0(150)]-20-[v1]-20-|", views: posterIcon, timeLabel)
        addConstraintsWithFormat(format: "H:|-10-[v0(150)]-20-[v1]-20-|", views: posterIcon, dateLabel)
        
        
        addConstraintsWithFormat(format: "V:|-40-[v0]-10-[v1]-10-[v2]-20-[v3]-10-[v4]-40-|", views: titleLabel, languageLabel, organizerLabel, dateLabel, timeLabel)
        addConstraintsWithFormat(format: "V:|-30-[v0(250)]-30-|", views: posterIcon)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ButtonCell:UICollectionViewCell{
    
    let organizerLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let separator:UIView = {
        let uv = UIView()
        uv.backgroundColor = .lightGray
        return uv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(organizerLabel)
        addSubview(separator)
        addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: organizerLabel)
        addConstraintsWithFormat(format: "V:|[v0][v1(2)]|", views: organizerLabel, separator)
        addConstraintsWithFormat(format: "H:|[v0]|", views: separator)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
