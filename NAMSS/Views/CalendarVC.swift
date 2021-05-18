//
//  CalendarVC.swift
//  MMIHS
//
//  Created by Frost on 3/24/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Alamofire
import SwiftyJSON

class CalendarVC: UIViewController {
    
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var list = [Event]()
    var dateFormatter = DateFormatter()
    var today = String()
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var tblEvents: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showToast(state: self, message: "Scroll the calendar sideways to change month.")
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        calendarView.showsHorizontalScrollIndicator = false
        calendarView.scrollToDate(Date())
        tblEvents.delegate = self
        tblEvents.dataSource = self
        tblEvents.tableFooterView = UIView()
        tblEvents.rowHeight = 75
        dateFormatter.dateFormat = "YYYY-MM-dd"
        today = dateFormatter.string(from: Date())
        self.fnDisplayEvents(date: today, completionHandler: {(res) in
            if res == true{
                self.tblEvents.reloadData()
                if self.list.count > 0{
                    self.calendarView.reloadData()
                }
            }else{
                self.tblEvents.reloadData()
                self.calendarView.reloadData()
                showToast(state: self, message: exceptionMessage)
            }
            hideProgressBar(activityIndicator: self.activityIndicator)
        })
    }
    
    func fnDisplayEvents(date:String, completionHandler : @escaping (Bool)->Void){
        self.list.removeAll()
        let url = appUrl + "GetSchoolEvents?yearmonth=\(date)"
        showProgressBar(state:self, activityIndicator: self.activityIndicator)
        Alamofire.request(url, method: .get)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        for (index,subJson):(String, JSON) in json {
                            self.list.append(Event(id: String(subJson["EventTypeId"].int ?? 0), name: subJson["EventName"].stringValue, desc: subJson["EventDescription"].stringValue, date: subJson["EventDate"].stringValue, imageUrl: subJson["ImagePath"].stringValue))
                        }
                        completionHandler(true)
                    }else{
                        completionHandler(false)
                    }
                case .failure(let error):
                    print(error)
                   completionHandler(false)
                }
        }
    }
    
    
}

extension CalendarVC:JTAppleCalendarViewDataSource{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .iso8601)
        let startDate = formatter.date(from: "2021 01 01")!
        let endDate = formatter.date(from: "2019 01 01")!
        return ConfigurationParameters(startDate: endDate, endDate: startDate,generateInDates: .forAllMonths,
                                       generateOutDates: .tillEndOfGrid)
    }
}

extension CalendarVC: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! CalendarViewCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? CalendarViewCell  else { return }
        cell.dateLabel.text = cellState.text
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleEventCellTextColor(cell: cell, cellState: cellState)
    }
    
    func handleCellTextColor(cell: CalendarViewCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.isHidden = false
        } else {
            cell.isHidden = true
        }
    }
    
    func handleEventCellTextColor(cell: CalendarViewCell, cellState: CellState) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        if self.list.count > 0{
            for i in list{
                if formatter.string(from: cellState.date) ==  i.date {
                    cell.selectedView.layer.cornerRadius = 70
                    cell.selectedView.isHidden = false
                }
            }
        }
        if formatter.string(from: cellState.date) ==  formatter.string(from: Date()) {
            cell.selectedView.layer.cornerRadius = 10
            cell.selectedView.isHidden = false
        }
    }
    
    func handleCellSelected(cell: CalendarViewCell, cellState: CellState) {
        cell.selectedView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        if cellState.isSelected {
//            cell.selectedView.layer.cornerRadius =  10
//            cell.selectedView.layer.backgroundColor = UIColor.green.cgColor
            cell.selectedView.isHidden = false
        } else {
//            cell.selectedView.layer.cornerRadius = 70
//            cell.selectedView.layer.backgroundColor = UIColor.red.cgColor
            cell.selectedView.isHidden = true
        }
//        let formatter = DateFormatter()
//        formatter.dateFormat = "YYYY-MM-dd"
//        if formatter.string(from: cellState.date) ==  formatter.string(from: Date()) {
//            cell.selectedView.layer.cornerRadius = 10
//            cell.selectedView.isHidden = false
//        }
    }
    
    func handleEvents(calendar: JTAppleCalendarView, visibleDates: DateSegmentInfo){
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM"
        let date = visibleDates.monthDates[5].date
        self.fnDisplayEvents(date: formatter.string(from: date), completionHandler: {(res) in
            if res == true{
                self.tblEvents.reloadData()
                if self.list.count > 0{
                    self.calendarView.reloadData()
                }
            }else{
                self.tblEvents.reloadData()
                self.calendarView.reloadData()
                showToast(state: self, message: exceptionMessage)
            }
            hideProgressBar(activityIndicator: self.activityIndicator)
        })
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.handleEvents(calendar:calendar,visibleDates: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
//        configureCell(view: cell, cellState: cellState)
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        for i in list{
            if i.date == formatter.string(from: date){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let VC =  storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailVC
                VC.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                VC.txtDate.text = i.date
                VC.txtTitle.text = i.name
                VC.txtDesc.text = i.desc
                self.addChild(VC)
                self.view.addSubview(VC.view)
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeader
        header.monthTitle.text = String.init(formatter.string(from: range.start)).uppercased()
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
    
}

extension CalendarVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(list.count == 0){
            self.tblEvents.setEmptyMessage("No any calendar Events.")
        } else {
            self.tblEvents.restore()
        }
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "calendarEventViewCell", for: indexPath) as? CalendarEventViewCell else{
            return UITableViewCell()
        }
        if list.count > 0 {
            let obj:Event = list[indexPath.row]
            let date:String = obj.date
            let dateArr = date.components(separatedBy: "-")
            if dateArr.count > 2 {
                let monthNumber = Int(dateArr[1])! - 1
                let monthName = DateFormatter().monthSymbols[monthNumber]
                cell.txtDate.text = monthName.prefix(3) + " " + dateArr[2] + ", " + dateArr[0]
            }
//            cell.txtDate.text = obj.date
            cell.txtTitle.text = obj.name
            cell.txtDesc.text = obj.desc
            var imageUrl = obj.imageUrl
            if imageUrl != "" {
                imageUrl = imageUrl.replacingOccurrences(of: "~", with: baseUrl)
                cell.img.kf.setImage(with: URL(string: imageUrl))
            } else {
                cell.imgWidth.constant = 0
            }
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
}
