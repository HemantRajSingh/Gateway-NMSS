//
//  FrontPageVC.swift
//  MMIHS
//
//  Created by Hemant Raj  Singh on 9/22/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class FrontPageVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    private var list = [Notice]()
    private var tableViewData = [FrontPageSectionHeader]()
    @IBOutlet var tblNotice: UITableView!
    
    var created:Bool = false
    var plusButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        tblNotice.tableFooterView = UIView()
//        tblNotice.separatorColor = .clear
        self.fnDownloadDashboardNotifEvents(url:appUrl + "GetDashboardNotifEvents")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    @objc func back(sender: UIBarButtonItem){
        if Common.shared.userRole == ""{
            openView(state: self, viewName: "loginVC")
        }else{
            openView(state: self, viewName: "DashboardVC")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened == true{
            return tableViewData[section].sectionData.count + 1
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            cell?.textLabel?.text = tableViewData[indexPath.section].title
            cell?.textLabel?.textColor = UIColor.black
            cell?.textLabel?.textAlignment = .center
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
            cell?.backgroundView?.backgroundColor = UIColor.blue
            cell?.selectionStyle = UITableViewCell.SelectionStyle.none
            cell?.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            return (cell)!
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "frontPageViewCell") as? FrontPageViewCell else {
                return UITableViewCell()
            }
            let obj:FrontPage = tableViewData[indexPath.section].sectionData[indexPath.row - 1]
            cell.txtNotifDate.text = obj.notifDate
            cell.txtNotifTitle.text = obj.notifTitle.capitalizingFirstLetter()
            cell.txtNotifDesc.text = obj.notifDesc.capitalizingFirstLetter()
            cell.txtNotifDuration.text = obj.notifDuration
            cell.txtNotifType.text = obj.notifType
            if(obj.notifType.lowercased() == "notice"){
                cell.imgNotifType.image = UIImage(named: "ic_mini_notice")
            } else {
                cell.imgNotifType.image = UIImage(named: "ic_mini_calendar")
            }
            var imageUrl = obj.imageUrl
            if imageUrl != "" {
                imageUrl = imageUrl.replacingOccurrences(of: "~", with: baseUrl)
                cell.imgNotif.kf.setImage(with: URL(string: imageUrl))
            } else {
                cell.imgNotif.isHidden = true
                cell.imgNotifWidth.constant = 0
                cell.imgNotifHeight.constant = 0
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 40
        } else {
            let obj:FrontPage = tableViewData[indexPath.section].sectionData[indexPath.row - 1]
            if(obj.imageUrl == "" && obj.notifDesc == "") {
                return 80
            }
            if(obj.imageUrl == "") {
                return 120
            }
            return 120
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
//            if tableViewData[indexPath.section].opened == true{
//                tableViewData[indexPath.section].opened = false
//                let sections = IndexSet.init(integer: indexPath.section)
//                tableView.reloadSections(sections, with: .none)
//            }else{
//                tableViewData[indexPath.section].opened = true
//                let sections = IndexSet.init(integer: indexPath.section)
//                tableView.reloadSections(sections, with: .none)
//            }
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let VC =  storyboard.instantiateViewController(withIdentifier: "noticeContentVC") as! NoticeContentVC
            let obj:FrontPage = tableViewData[indexPath.section].sectionData[indexPath.row - 1]
            VC.noticeTitle = obj.notifTitle
            VC.desc = obj.notifDesc
            VC.title = obj.notifGroup
            if(obj.imageUrl != ""){
                let imageUrl = obj.imageUrl.replacingOccurrences(of: "~", with: baseUrl)
                VC.imageUrl = imageUrl
            }
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    func fnDownloadDashboardNotifEvents( url:String){
        showProgressBar(state: self, activityIndicator: activityIndicator)
        self.tableViewData.removeAll()
        Alamofire.request(url, method: .get)
            .validate { request, response, data in
                return .success
        }
        .responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    let todayNotice = json["notifToday"][0]["Notices"].array
                    let todayEvent = json["notifToday"][0]["CalanderEvents"].array
                    let upcomingNotice = json["notifUpcomming"][0]["Notices"].array
                    let upcomingEvent = json["notifUpcomming"][0]["CalanderEvents"].array
                    let pastNotice = json["notifPast"][0]["Notices"].array
                    let pastEvent = json["notifPast"][0]["CalanderEvents"].array
                    if(todayNotice?.count == 0 && todayEvent?.count == 0 && upcomingNotice?.count == 0 && upcomingEvent?.count == 0 && pastNotice?.count == 0 && pastEvent?.count == 0){
                        hideProgressBar(activityIndicator: self.activityIndicator)
                        showToast(state: self, message: "No any new notices available. Opening Login page.")
                        self.tblNotice.setEmptyMessage("")
                        self.tblNotice.reloadData()
                        self.tabBarController?.selectedIndex = 3
                        return ;
                    }
                    var notifType,notifDuration,notifDate,notifTitle,notifDesc,imageUrl,notifGroup : String
                    var list1  = [FrontPage](),list2 = [FrontPage](),list3 = [FrontPage]()
                    for (index,subJson):(String, JSON) in JSON(todayNotice){
                        notifType = "Notice"
                        notifGroup = "Today"
                        notifDuration = subJson["Duration"].stringValue
                        notifDate = subJson["NotifDateNp"].stringValue
                        notifTitle = subJson["NotifTitle"].stringValue
                        notifDesc = subJson["NotifDescription"].stringValue
                        imageUrl = subJson["ImagePath"].stringValue
                        list1.append(FrontPage(notifType: notifType, notifDuration: notifDuration, notifDate: notifDate, notifTitle: notifTitle, notifDesc: notifDesc, imageUrl: imageUrl, notifGroup: notifGroup))
                    }
                    for (index,subJson):(String, JSON) in JSON(todayEvent){
                        notifType = "Calendar Event"
                        notifGroup = "Today"
                        notifDuration = subJson["Duration"].stringValue
                        notifDate = subJson["EventDate"].stringValue
                        notifTitle = subJson["EventName"].stringValue
                        notifDesc = subJson["EventDescription"].stringValue
                        imageUrl = subJson["ImagePath"].stringValue
                        list1.append(FrontPage(notifType: notifType, notifDuration: notifDuration, notifDate: notifDate, notifTitle: notifTitle, notifDesc: notifDesc, imageUrl: imageUrl, notifGroup: notifGroup))
                    }
                    self.tableViewData.append(FrontPageSectionHeader(opened: true, title: "Today", sectionData: list1))
                    for (index,subJson):(String, JSON) in JSON(upcomingNotice){
                        notifType = "Notice"
                        notifGroup = "Today"
                        notifDuration = subJson["Duration"].stringValue
                        notifDate = subJson["NotifDateNp"].stringValue
                        notifTitle = subJson["NotifTitle"].stringValue
                        notifDesc = subJson["NotifDescription"].stringValue
                        imageUrl = subJson["ImagePath"].stringValue
                        list2.append(FrontPage(notifType: notifType, notifDuration: notifDuration, notifDate: notifDate, notifTitle: notifTitle, notifDesc: notifDesc, imageUrl: imageUrl, notifGroup: notifGroup))
                    }
                    for (index,subJson):(String, JSON) in JSON(upcomingEvent){
                        notifType = "Calendar Event"
                        notifGroup = "Today"
                        notifDuration = subJson["Duration"].stringValue
                        notifDate = subJson["EventDate"].stringValue
                        notifTitle = subJson["EventName"].stringValue
                        notifDesc = subJson["EventDescription"].stringValue
                        imageUrl = subJson["ImagePath"].stringValue
                        list2.append(FrontPage(notifType: notifType, notifDuration: notifDuration, notifDate: notifDate, notifTitle: notifTitle, notifDesc: notifDesc, imageUrl: imageUrl, notifGroup: notifGroup))
                    }
                    self.tableViewData.append(FrontPageSectionHeader(opened: true, title: "Upcoming", sectionData: list2))
                    for (index,subJson):(String, JSON) in JSON(pastNotice){
                        notifType = "Notice"
                        notifGroup = "Today"
                        notifDuration = subJson["Duration"].stringValue
                        notifDate = subJson["NotifDateNp"].stringValue
                        notifTitle = subJson["NotifTitle"].stringValue
                        notifDesc = subJson["NotifDescription"].stringValue
                        imageUrl = subJson["ImagePath"].stringValue
                        list3.append(FrontPage(notifType: notifType, notifDuration: notifDuration, notifDate: notifDate, notifTitle: notifTitle, notifDesc: notifDesc, imageUrl: imageUrl, notifGroup: notifGroup))
                    }
                    for (index,subJson):(String, JSON) in JSON(pastEvent){
                        notifType = "Calendar Event"
                        notifGroup = "Today"
                        notifDuration = subJson["Duration"].stringValue
                        notifDate = subJson["EventDate"].stringValue
                        notifTitle = subJson["EventName"].stringValue
                        notifDesc = subJson["EventDescription"].stringValue
                        imageUrl = subJson["ImagePath"].stringValue
                        list3.append(FrontPage(notifType: notifType, notifDuration: notifDuration, notifDate: notifDate, notifTitle: notifTitle, notifDesc: notifDesc, imageUrl: imageUrl, notifGroup: notifGroup))
                    }
                    self.tableViewData.append(FrontPageSectionHeader(opened: true, title: "Past", sectionData: list3))
                    hideProgressBar(activityIndicator: self.activityIndicator)
                    self.tblNotice.reloadData()
                }
            case .failure(let error):
                print(error)
                self.tblNotice.setEmptyMessage("")
                hideProgressBar(activityIndicator: self.activityIndicator)
                self.tblNotice.reloadData()
//                showToast(state:self, message: "Network error")
            }
        }
    }
}
