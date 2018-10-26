//
//  EventsScreen.swift
//  SmartUmac
//
//  Created by Ricardo on 26/10/2018.
//  Copyright © 2018 Ricardo. All rights reserved.
//

import UIKit

class EventsScreenController:UITableViewController{
    
    var event:Event?
    var posterImage:UIImage?
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(EventScreenCell.self, forCellReuseIdentifier: cellId)
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        setHeaderView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let details = event?.details{
            return details.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EventScreenCell
        
        let myAttribute = [ NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14) ]
        let myString = NSMutableAttributedString(string: "", attributes: myAttribute )
        
        let brownAttribute = [NSAttributedStringKey.foregroundColor: UIColor.brown]
        
        if let details = event?.details{
            let detail = details[indexPath.section]
            
            if let title = detail.title{
                
                let redAttribute = [ NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.black ]
                let titleString = NSMutableAttributedString(string: title + "\n\n", attributes: redAttribute)
                
                myString.append(titleString)
                
                cell.eventLabel.attributedText = myString
                
                
            }
            
            var langs = ""
            var orgs = ""
            var coorgs = ""
            var speakers = ""
            var targets = ""
            var venues = ""
            var time = ""
            var dateString = ""
            var content = ""
            var contactName = ""
            var contactPhone = ""
            var contactEmail = ""
            var contactFax = ""
            var remark = ""
            
            
            if let sectionTitle = detail.locale{
                if sectionTitle == "en_US"{
                    langs = "Languages: "
                    orgs = "Organizers: "
                    coorgs = "Coorganizers: "
                    speakers = "Speakers: "
                    targets = "Targeted Audience: "
                    venues = "Venues: "
                    time = "Time: "
                    dateString = "Date: "
                    content = "Details: "
                    contactName = "Contact Person: "
                    contactPhone = "Phone Number: "
                    contactEmail = "Contact Email: "
                    contactFax = "Contact Fax: "
                }
                else if sectionTitle == "pt_PT"{
                    langs =  "Linguas: "
                    orgs = "Organizadores: "
                    coorgs = "Corganizadores: "
                    speakers = "Locutores: "
                    targets = "Audiencia: "
                    venues = "Local: "
                    time = "Horario: "
                    dateString = "Data: "
                    content = "Detalhes: "
                    contactName = "Contato: "
                    contactPhone = "Numero de Telefone: "
                    contactEmail = "Email: "
                    contactFax = "Fax: "
                }
                else if sectionTitle == "zh_TW" {
                    langs = "語言: "
                    orgs = "組織者: "
                    coorgs = "協組織者: "
                    speakers = "議長: "
                    targets = "對象: "
                    venues = "地點"
                    time = "時間: "
                    dateString = "日期: "
                    content = "细节: "
                    contactName = "聯繫人: "
                    contactPhone = "電話號碼: "
                    contactEmail = "郵件: "
                    contactFax = "傳真: "
                }
            }
            
            if let t = event?.common?.timeFrom{
                time.append(t.components(separatedBy: "T")[1].components(separatedBy: "+")[0])
                //let blueAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.blue ]
                //let timeString = NSMutableAttributedString(string: time, attributes: blueAttribute)
                //myString.append(timeString)
                
                //cell.eventLabel.attributedText = myString
                
            }
            
            if let t = event?.common?.timeTo{
                time.append("-" + t.components(separatedBy: "T")[1].components(separatedBy: "+")[0])
                let blueAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.blue ]
                let timeString = NSMutableAttributedString(string: time + "\n\n", attributes: blueAttribute)
                myString.append(timeString)
                
                cell.eventLabel.attributedText = myString
                
            }
            
            if let date = event?.common?.dateFrom {
                dateString.append(date.components(separatedBy: "T")[0])
                let blueAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.blue ]
                let dateStringAttr = NSMutableAttributedString(string: dateString + "\n\n", attributes: blueAttribute)
                myString.append(dateStringAttr)
                
                cell.eventLabel.attributedText = myString
            }
            
            
            if let languages = detail.languages{
                
                
                
                for (i, language) in languages.enumerated() {
                    if i != languages.count - 1{
                        langs.append(language)
                        langs.append(", ")
                    }
                    else {
                        langs.append(language)
                    }
                }
                let languagesString = NSMutableAttributedString(string: langs + "\n\n", attributes: brownAttribute)
                myString.append(languagesString)
                
                cell.eventLabel.attributedText = myString
                
            }
            
            if let organizers = detail.organizedBys{
                
                for (i, organizer) in organizers.enumerated() {
                    if i != organizers.count - 1{
                        orgs.append(organizer)
                        orgs.append(", ")
                    }
                    else {
                        orgs.append(organizer)
                    }
                }
                
                let organizersString = NSMutableAttributedString(string: orgs + "\n\n", attributes: brownAttribute)
                myString.append(organizersString)
                
                cell.eventLabel.attributedText = myString
                
            }
            
            if let coorganizers = detail.organizedBys{
                
                for (i, coorganizer) in coorganizers.enumerated() {
                    if i != coorganizers.count - 1{
                        coorgs.append(coorganizer)
                        coorgs.append(", ")
                    }
                    else {
                        coorgs.append(coorganizer)
                    }
                }
                
                let coorganizersString = NSMutableAttributedString(string: coorgs + "\n\n", attributes: brownAttribute)
                myString.append(coorganizersString)
                
                cell.eventLabel.attributedText = myString
                
            }
            
            if let eventSpeakers = detail.speakers{
                
                for (i, speaker) in eventSpeakers.enumerated() {
                    if i != eventSpeakers.count - 1{
                        speakers.append(speaker)
                        speakers.append(", ")
                    }
                    else {
                        speakers.append(speaker)
                    }
                }
                
                let speakersString = NSMutableAttributedString(string: speakers + "\n\n", attributes: brownAttribute)
                myString.append(speakersString)
                
                cell.eventLabel.attributedText = myString
                
            }
            
            if let targetAudiences = detail.targetAudiences{
                
                for (i, target) in targetAudiences.enumerated() {
                    if i != targetAudiences.count - 1{
                        targets.append(target)
                        targets.append(", ")
                    }
                    else {
                        targets.append(target)
                    }
                }
                
                let targetAudienceString = NSMutableAttributedString(string: targets + "\n\n", attributes: brownAttribute)
                myString.append(targetAudienceString)
                
                cell.eventLabel.attributedText = myString
                
            }
            
            if let eventVenues = detail.venues{
                
                for (i, venue) in eventVenues.enumerated() {
                    if i != eventVenues.count - 1{
                        venues.append(venue)
                        venues.append(", ")
                    }
                    else {
                        venues.append(venue)
                    }
                }
                
                let venuesString = NSMutableAttributedString(string: venues + "\n\n", attributes: brownAttribute)
                myString.append(venuesString)
                
                cell.eventLabel.attributedText = myString
                
            }
            
            if let eventContent = detail.content{
                content.append(eventContent)
                let boldAttribute = [ NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedStringKey.foregroundColor: UIColor.black ]
                let contentString = NSMutableAttributedString(string: content + "\n\n", attributes: boldAttribute)
                myString.append(contentString)
                
                cell.eventLabel.attributedText = myString
            }
            
            if let eventContact = detail.contactName{
                contactName.append(eventContact)
                let grayAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.gray]
                let eventContactString =  NSMutableAttributedString(string: contactName + "\n\n", attributes: grayAttribute)
                myString.append(eventContactString)
                
                cell.eventLabel.attributedText = myString
            }
            
            if let eventPhone = detail.contactPhone{
                contactPhone.append(eventPhone)
                let grayAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.gray]
                let eventContactPhoneString =  NSMutableAttributedString(string: contactPhone + "\n\n", attributes: grayAttribute)
                myString.append(eventContactPhoneString)
                
                cell.eventLabel.attributedText = myString
            }
            
            if let eventEmail = detail.contactEmail{
                contactEmail.append(eventEmail)
                let grayAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.gray]
                let eventContactEmailString =  NSMutableAttributedString(string: contactEmail + "\n\n", attributes: grayAttribute)
                myString.append(eventContactEmailString)
                
                cell.eventLabel.attributedText = myString
            }
            
            if let eventFax = detail.contactFax{
                contactFax.append(eventFax)
                let grayAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.gray]
                let eventContactFaxString =  NSMutableAttributedString(string: contactFax + "\n\n", attributes: grayAttribute)
                myString.append(eventContactFaxString)
                
                cell.eventLabel.attributedText = myString
            }
            
            if let eventRemark = detail.remark{
                remark.append(eventRemark)
                let redAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.red]
                let eventRemarkString = NSMutableAttributedString(string: remark + "\n\n", attributes: redAttribute)
                myString.append(eventRemarkString)
                
                cell.eventLabel.attributedText = myString
            }
            
            
            
            
            
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let details = event?.details{
            if let sectionTitle = details[section].locale{
                if sectionTitle == "en_US"{
                    return "English"
                }
                else if sectionTitle == "pt_PT"{
                    return "Portuguese"
                }
                else if sectionTitle == "zh_TW" {
                    return "中文 (台灣)"
                }
            }
        }
        return ""
    }
    
    @objc func didTouchImage(){
        let posterView = PosterView()
        if let image = posterImage{
            posterView.image = image
        }
        self.navigationController?.pushViewController(posterView, animated: true)
    }
    
    func setHeaderView(){
        let headerView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 400))
        let headerImageVIew = UIImageView()
        
        headerView.addSubview(headerImageVIew)
        
        headerView.addConstraintsWithFormat(format: "H:|[v0]|", views: headerImageVIew)
        headerView.addConstraintsWithFormat(format: "V:|-10-[v0]-10-|", views: headerImageVIew)
        
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTouchImage)))
        
        if let posterURL = event?.common?.posterUrl{
            let url = URL(string: posterURL)
            URLSession.shared.dataTask(with: url!) { (data, response, err) in
                guard let data  = data else {return}
                print(data)
                DispatchQueue.main.async {
                    headerImageVIew.image = UIImage(data: data)
                    self.posterImage = UIImage(data: data)
                    headerImageVIew.contentMode = .scaleAspectFit
                    self.tableView.reloadData()
                }
                }.resume()
            
        }else {
            headerImageVIew.image = UIImage(named: "default")
            self.posterImage = UIImage(named: "default")
            headerImageVIew.contentMode = .scaleAspectFit
            self.tableView.reloadData()
        }
        
        tableView.tableHeaderView = headerView
        
        
    }
    
}

class EventScreenCell:UITableViewCell{
    
    let eventLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(eventLabel)
        addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: eventLabel)
        addConstraintsWithFormat(format: "V:|-10-[v0]-10-|", views: eventLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

