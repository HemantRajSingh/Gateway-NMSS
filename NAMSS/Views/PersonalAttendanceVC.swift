//
//  PersonalAttendanceVC.swift
//  MMIHS
//
//  Created by Frost on 3/24/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Alamofire
import SwiftyJSON

class PersonalAttendanceVC: UIViewController {
    
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var list = [Event]()
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    let common = Common.shared
    var dateFormatter = DateFormatter()
    
    @IBOutlet weak var txtTotalSchoolDays: UILabel!
    @IBOutlet weak var txtAbsentDays: UILabel!
    @IBOutlet weak var txtPresentDays: UILabel!
    @IBOutlet weak var imgPercent: UIImageView!
    @IBOutlet weak var txtPercent: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgPercent.setRounded()
        imgPercent.layer.borderWidth = 1
        imgPercent.layer.borderColor = UIColor.blue.cgColor
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        calendarView.showsHorizontalScrollIndicator = false
        calendarView.scrollToDate(Date())
        dateFormatter.dateFormat = "YYYY-MM-dd"
        self.fnDisplayEvents(date: dateFormatter.string(from: Date()), completionHandler: {(res) in
            if res == true{
                if self.list.count > 0{
                    self.calendarView.reloadData()
                }
            }else{
                self.calendarView.reloadData()
                showToast(state: self, message: "Exception occurred.")
            }
            hideProgressBar(activityIndicator: self.activityIndicator)
        })
    }
    
    func fnDisplayEvents(date:String, completionHandler : @escaping (Bool)->Void){
        self.list.removeAll()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        var startDate = formatter.date(from: date) ?? Date()
        var interval = TimeInterval()
        Calendar.current.dateInterval(of: .month, start: &startDate, interval: &interval, for: startDate)
        let endDate = Calendar.current.date(byAdding: .second, value: Int(interval) - 1, to: startDate)!

        let fromDate = formatter.string(from: startDate)
        let toDate = formatter.string(from: endDate)
        
        var url = appUrl + "StaffAttendanceDetail?staffid=\(common.staffId)&startDateEn=\(fromDate)&endDateEn=\(toDate)"
        if common.userRole == "AppStudent" {
            url = appUrl + "GetStudentAttendanceRecord?studentid=\(common.studentId)&classid=\(common.classId)&sectionid=\(common.sectionId)&date=\(date)"
        }
        showProgressBar(state:self, activityIndicator: self.activityIndicator)
        Alamofire.request(url, method: .post)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result {
                case .success:
                    var count = 0
                    var totalDays = "0"
                    if let value = response.result.value {
                        let json = JSON(value)
                        if(json["ExceptionType"].stringValue == "" && json["Message"].stringValue == ""){
                            if(self.common.userRole == "AppStudent"){
                                let JA = JSON(json["AttendanceRecord"].array)
                                for (index,subJson):(String, JSON) in JA {
                                    if subJson["AttendanceStatus"].stringValue.lowercased() == "p" {
                                        count += 1
                                        self.list.append(Event(id: "", name: "", desc: "", date: subJson["AttendanceDateAD"].stringValue, imageUrl: ""))
                                    }
                                    totalDays = String(json["schoolDaysInMonth"].int ?? 0)
                                }
                            } else {
                                let JA = JSON(json["logDateFrequency"].array)
                                let totalDaysArr = json["daysInMonthEn"].array
                                for (i,j) in JA {
                                    count += 1
                                    self.list.append(Event(id: "", name: "", desc: "", date: j.stringValue, imageUrl: ""))
                                }
                                totalDays = String(totalDaysArr?.count ?? 0)
                            }
                            self.txtTotalSchoolDays.text = totalDays
                            self.txtPresentDays.text = String(count)
                            self.txtAbsentDays.text = String(Int(totalDays)! - count)
                            var percent:Double = 0.00000
                            percent = Double(count) / Double(totalDays)!
                            percent = percent * 100
                            self.txtPercent.text = String(format: "%.2f", percent) + " %"
                            completionHandler(true)
                        }else{
                            completionHandler(false)
                        }
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

extension PersonalAttendanceVC:JTAppleCalendarViewDataSource{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "yyyy MM dd"
        let startDate = formatter.date(from: "2021 01 01")!
        let endDate = formatter.date(from: "2019 01 01")!
        return ConfigurationParameters(startDate: endDate, endDate: startDate,generateInDates: .forAllMonths,
                                       generateOutDates: .tillEndOfGrid)
    }
}

extension PersonalAttendanceVC: JTAppleCalendarViewDelegate {
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
                    cell.selectedView.layer.cornerRadius = 10
                    cell.selectedView.layer.backgroundColor = UIColor.green.cgColor
                    cell.selectedView.isHidden = false
                }
            }
        }
//        if formatter.string(from: cellState.date) ==  formatter.string(from: Date()) {
//            cell.selectedView.layer.cornerRadius = 10
//            cell.selectedView.isHidden = false
//        }
    }
    
    func handleCellSelected(cell: CalendarViewCell, cellState: CellState) {
        cell.selectedView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        if cellState.isSelected {
//            cell.selectedView.layer.cornerRadius =  10
//            cell.selectedView.layer.backgroundColor = UIColor.green.cgColor
//            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.layer.cornerRadius = 70
            cell.selectedView.layer.backgroundColor = UIColor.red.cgColor
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
        formatter.dateFormat = "YYYY-MM-dd"
        let date = visibleDates.monthDates[5].date
        showProgressBar(state: self, activityIndicator: self.activityIndicator)
        self.fnDisplayEvents(date: formatter.string(from: date), completionHandler: {(res) in
            if res == true{
                if self.list.count > 0{
                    self.calendarView.reloadData()
                }
            }else{
                self.calendarView.reloadData()
                showToast(state: self, message: "Exception occurred.")
            }
            hideProgressBar(activityIndicator: self.activityIndicator)
        })
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.handleEvents(calendar:calendar,visibleDates: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
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
