//
//  CalendarViewController.swift
//  SmartUmac
//
//  Created by Ricardo on 26/10/2018.
//  Copyright © 2018 Ricardo. All rights reserved.
//

import UIKit

enum MyTheme {
    case light
    case dark
}

class CalenderViewController: UIViewController {
    
    //var theme = MyTheme.dark
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "UM Calendar"
        self.navigationController?.navigationBar.isTranslucent=false
        self.view.backgroundColor=Style.bgColor
        
        view.addSubview(calenderView)
        calenderView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive=true
        calenderView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive=true
        calenderView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive=true
        calenderView.heightAnchor.constraint(equalToConstant: 365).isActive=true
        calenderView.parentViewController = self
        
        
 
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        calenderView.myCollectionView.collectionViewLayout.invalidateLayout()
    }

    let calenderView: CalenderView = {
        let v=CalenderView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
}

struct Colors {
    static var darkGray = #colorLiteral(red: 0.3764705882, green: 0.3647058824, blue: 0.3647058824, alpha: 1)
    static var darkRed = #colorLiteral(red: 0.5019607843, green: 0.1529411765, blue: 0.1764705882, alpha: 1)
}

struct Style {
    static var bgColor = UIColor.white
    static var monthViewLblColor = UIColor.white
    static var monthViewBtnRightColor = UIColor.white
    static var monthViewBtnLeftColor = UIColor.white
    static var activeCellLblColor = UIColor.white
    static var activeCellLblColorHighlighted = UIColor.black
    static var weekdaysLblColor = UIColor.white
    
    static func themeDark(){
        bgColor = Colors.darkGray
        monthViewLblColor = UIColor.white
        monthViewBtnRightColor = UIColor.white
        monthViewBtnLeftColor = UIColor.white
        activeCellLblColor = UIColor.white
        activeCellLblColorHighlighted = UIColor.black
        weekdaysLblColor = UIColor.white
    }
    
    static func themeLight(){
        bgColor = UIColor.white
        monthViewLblColor = UIColor.black
        monthViewBtnRightColor = UIColor.black
        monthViewBtnLeftColor = UIColor.black
        activeCellLblColor = UIColor.black
        activeCellLblColorHighlighted = UIColor.white
        weekdaysLblColor = UIColor.black
    }
}

class CalenderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MonthViewDelegate {
    
    var parentViewController:CalenderViewController?
    var numOfDaysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
    var currentMonthIndex: Int = 0
    var currentYear: Int = 0
    var presentMonthIndex = 0
    var presentYear = 0
    var todaysDate = 0
    var firstWeekDayOfMonth = 0   //(Sunday-Saturday 1-7)
    var holidays:[Holiday]?
    var dateFrom:String = ""
    var dateTo:String = ""
    var events:[Event]?
    var jsonUrlString = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeView()
    }
    
    convenience init(theme: MyTheme) {
        self.init()
        
        if theme == .dark {
            Style.themeDark()
        } else {
            Style.themeLight()
        }
        
        initializeView()
    }
    
    func changeTheme() {
        myCollectionView.reloadData()
        
        monthView.lblName.textColor = Style.monthViewLblColor
        monthView.btnRight.setTitleColor(Style.monthViewBtnRightColor, for: .normal)
        monthView.btnLeft.setTitleColor(Style.monthViewBtnLeftColor, for: .normal)
        
        for i in 0..<7 {
            (weekdaysView.myStackView.subviews[i] as! UILabel).textColor = Style.weekdaysLblColor
        }
    }

    
    
    func initializeView() {
        
        monthView.lblName.textColor = .black
        monthView.btnRight.setTitleColor(.black, for: .normal)
        monthView.btnLeft.setTitleColor(.black, for: .normal)
        
        
        currentMonthIndex = Calendar.current.component(.month, from: Date())
        currentYear = Calendar.current.component(.year, from: Date())
        todaysDate = Calendar.current.component(.day, from: Date())
        firstWeekDayOfMonth=getFirstWeekDay()
        
        
        
        //for leap years, make february month of 29 days
        if currentMonthIndex == 2 && currentYear % 4 == 0 {
            numOfDaysInMonth[currentMonthIndex-1] = 29
        }
        //end
        
        dateFrom = "\(currentYear)-\(String(format: "%02d", currentMonthIndex))-01"
        dateTo = "\(currentYear)-\(String(format: "%02d", currentMonthIndex))-\(numOfDaysInMonth[currentMonthIndex-1])"
        
        readJson { (downloaded) in
            if let holidays = downloaded._embedded{
                self.holidays = holidays
                self.myCollectionView.reloadData()
            }
        }
        
        
        jsonUrlString = "https://api.data.umac.mo/service/media/events/v1.0.0/all?date_from=\(dateFrom)&date_to=\(dateTo)&sort_by=-lastModified&count"
        
        readJsonEvents { (downloaded) in
            if let downloadedEvents = downloaded._embedded{
                self.events = downloadedEvents
                self.myCollectionView.reloadData()
            }
            if let count = downloaded._total_pages{
                if count == 2{
                    self.jsonUrlString = "https://api.data.umac.mo/service/media/events/v1.0.0/all?date_from=\(self.dateFrom)&date_to=\(self.dateTo)&sort_by=-lastModified&page=2"
                    self.readJsonEvents(completion: { (downloaded2) in
                        if let downloadedEvents2 = downloaded2._embedded{
                            for event in downloadedEvents2{
                                self.events?.append(event)
                            }
                            self.myCollectionView.reloadData()
                        }
                    })
                }
            }
        }
 
        presentMonthIndex=currentMonthIndex
        presentYear=currentYear
        
        setupViews()
        
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(dateCVCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numOfDaysInMonth[currentMonthIndex-1] + firstWeekDayOfMonth - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! dateCVCell
        cell.backgroundColor=UIColor.clear
        cell.lbl.textColor = .black
        
        if indexPath.item <= firstWeekDayOfMonth - 2 {
            cell.isHidden=true
        } else {
            let calcDate = indexPath.row-firstWeekDayOfMonth+2
            cell.isHidden=false
            
            if let holidays = self.holidays{
                for holiday in holidays{
                    if let date = holiday.date{
                        if date.components(separatedBy: "T")[0].components(separatedBy: "-")[2] == String(format: "%02d", calcDate){
                            cell.lbl.textColor = .red
                            //print(date)
                        }
                    }
                    
                }
            }
            
            
            cell.lbl.text="\(calcDate)"
            
            var dailyEvents:[Event] = []
            
            dateFrom = "\(currentYear)-\(String(format: "%02d", currentMonthIndex))-\(String(format: "%02d", calcDate))"
            dateTo = "\(currentYear)-\(String(format: "%02d", currentMonthIndex))-\(String(format: "%02d", calcDate))"
            
            if let allEvents = events{
                for event in allEvents{
                    if let df = event.common?.dateFrom, let dt = event.common?.dateTo{
                        if df.components(separatedBy: "T")[0] == dateFrom {
                            dailyEvents.append(event)
                        }
                    }
                }
                if dailyEvents.count > 0 {
                    if cell.lbl.textColor == UIColor.red{
                        cell.lbl.textColor = .green
                    }
                    else{
                        cell.lbl.textColor = .blue
                    }
                }
                
            }
            
            
            
            
        }
        return cell
    }
    
    func readJsonEvents(completion: @escaping (EventsData)->()){

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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell=collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor=Colors.darkRed
        let lbl = cell?.subviews[1] as! UILabel
        //lbl.textColor=UIColor.white
        
        dateFrom = "\(currentYear)-\(String(format: "%02d", currentMonthIndex))-\((String(format: "%02d", Int(lbl.text!)!)))"
        dateTo = "\(currentYear)-\(String(format: "%02d", currentMonthIndex))-\((String(format: "%02d", Int(lbl.text!)!)))"
        print(dateFrom)
        print(dateTo)
        
        var dailyEvents:[Event] = []
        
        jsonUrlString = "https://api.data.umac.mo/service/media/events/v1.0.0/all?date_from=\(dateFrom)&date_to=\(dateTo)&sort_by=-lastModified"
        
        readJsonEvents { (downloaded) in
            if let events = downloaded._embedded{
                
                for event in events {
                    if let dateFrom = event.common?.dateFrom, let dateTo = event.common?.dateTo{
                        if dateFrom.components(separatedBy: "T")[0] == self.dateFrom {
                            dailyEvents.append(event)
                        }
                    }
                }
                
                if dailyEvents.count > 0 {
                    let eventsView = EventsCalendarViewController()
                    eventsView.events = dailyEvents
                    self.parentViewController?.navigationController?.pushViewController(eventsView, animated: true)
                }

                
                
            }
            print(dailyEvents)
            
        }
        
        
        
        
        
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell=collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor=UIColor.clear
        //let lbl = cell?.subviews[1] as! UILabel
        //lbl.textColor = .black
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/7 - 8
        let height: CGFloat = 40
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func getFirstWeekDay() -> Int {
        let day = ("\(currentYear)-\(currentMonthIndex)-01".date?.firstDayOfTheMonth.weekday)!
        //return day == 7 ? 1 : day
        return day
    }
    
    func didChangeMonth(monthIndex: Int, year: Int) {
        
        currentMonthIndex=monthIndex+1
        currentYear = year
        
        //for leap year, make february month of 29 days
        if monthIndex == 1 {
            if currentYear % 4 == 0 {
                numOfDaysInMonth[monthIndex] = 29
            } else {
                numOfDaysInMonth[monthIndex] = 28
            }
        }
        //end
        
        
        
        dateFrom = "\(currentYear)-\(String(format: "%02d", currentMonthIndex))-01"
        dateTo = "\(currentYear)-\(String(format: "%02d", currentMonthIndex))-\(numOfDaysInMonth[currentMonthIndex-1])"
        
        readJson { (downloaded) in
            if let holidays = downloaded._embedded{
                self.holidays = holidays
                self.myCollectionView.reloadData()
            }
        }
        
        jsonUrlString = "https://api.data.umac.mo/service/media/events/v1.0.0/all?date_from=\(dateFrom)&date_to=\(dateTo)&sort_by=-lastModified&count"
        
        self.events = []
        
        readJsonEvents { (downloaded) in
            if let downloadedEvents = downloaded._embedded{
                for event in downloadedEvents{
                  self.events?.append(event)
                }
                self.myCollectionView.reloadData()
            }

        }
        
        self.jsonUrlString = "https://api.data.umac.mo/service/media/events/v1.0.0/all?date_from=\(self.dateFrom)&date_to=\(self.dateTo)&sort_by=-lastModified&page=2"
        
        readJsonEvents { (downloaded) in
            if let downloadedEvents3 = downloaded._embedded{
                
                for event in downloadedEvents3{
                    self.events?.append(event)
                    self.myCollectionView.reloadData()
                }
                
            }
        }
        
        
        
      
        
        
        firstWeekDayOfMonth=getFirstWeekDay()
        //myCollectionView.reloadData()
        
        //monthView.btnLeft.isEnabled = !(currentMonthIndex == presentMonthIndex && currentYear == presentYear)
    }
    
    func setupViews() {
        addSubview(monthView)
        monthView.topAnchor.constraint(equalTo: topAnchor).isActive=true
        monthView.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        monthView.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        monthView.heightAnchor.constraint(equalToConstant: 35).isActive=true
        monthView.delegate=self
        
        addSubview(weekdaysView)
        weekdaysView.topAnchor.constraint(equalTo: monthView.bottomAnchor).isActive=true
        weekdaysView.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        weekdaysView.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        weekdaysView.heightAnchor.constraint(equalToConstant: 30).isActive=true
        
        addSubview(myCollectionView)
        myCollectionView.topAnchor.constraint(equalTo: weekdaysView.bottomAnchor, constant: 0).isActive=true
        myCollectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive=true
        myCollectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive=true
        myCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive=true
    }
    
    func readJson(completion: @escaping (HolidaysData)->()){
        
        let jsonUrlString = "https://api.data.umac.mo/service/aboutum/public_holidays/v1.0.0/all?date_from=\(dateFrom)&date_to=\(dateTo)"
        
        
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
                    let holidaysData = try JSONDecoder().decode(HolidaysData.self, from:data)
                    
                    DispatchQueue.main.async {
                        completion(holidaysData)
                    }
                    
                } catch let jsonErr{
                    print(jsonErr)
                }
                }.resume()
            
        }
    }
    
    
    let monthView: MonthView = {
        let v=MonthView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let weekdaysView: WeekdaysView = {
        let v=WeekdaysView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let myCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let myCollectionView=UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        myCollectionView.showsHorizontalScrollIndicator = false
        myCollectionView.translatesAutoresizingMaskIntoConstraints=false
        myCollectionView.backgroundColor=UIColor.clear
        myCollectionView.allowsMultipleSelection=false
        return myCollectionView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class dateCVCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor=UIColor.clear
        layer.cornerRadius=5
        layer.masksToBounds=true
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(lbl)
        lbl.topAnchor.constraint(equalTo: topAnchor).isActive=true
        lbl.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        lbl.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        lbl.bottomAnchor.constraint(equalTo: bottomAnchor).isActive=true
    }
    
    let lbl: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .center
        label.font=UIFont.systemFont(ofSize: 16)
        label.textColor=Colors.darkGray
        label.translatesAutoresizingMaskIntoConstraints=false
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//get first day of the month
extension Date {
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    var firstDayOfTheMonth: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
    }
}

//get date from string
extension String {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var date: Date? {
        return String.dateFormatter.date(from: self)
    }
}
