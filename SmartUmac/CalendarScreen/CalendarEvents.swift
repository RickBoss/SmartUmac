//
//  CalendarEvents.swift
//  SmartUmac
//
//  Created by Ricardo on 26/10/2018.
//  Copyright © 2018 Ricardo. All rights reserved.
//

import UIKit

class EventsCalendarViewController:UITableViewController{
    
    
    
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
    
    
    var categoryData = [String:[Event]]()
    var totalOrganizers = [String]()
    let organizerCellId = "organizerCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(EventCell.self, forCellReuseIdentifier: cellId)        
        
        //tableView.rowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
     
        self.tableView.reloadData()
        self.buttonsCollectionView.reloadData()
                
     
        
    }
    
    //Organize Data
    
   
    
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
        cell.posterIcon.image = UIImage(named: "default")
        if let totalEvents = events {
            
            if let posterLink = totalEvents[indexPath.row].common?.posterUrl {
                //download poster
                let url = URL(string: posterLink)
                
                
                
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
    
   
    
    
    
    
    
    
    
    
    
}

