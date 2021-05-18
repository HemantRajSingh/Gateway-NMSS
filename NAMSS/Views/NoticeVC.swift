//
//  NoticeVC.swift
//  MMIHS
//
//  Created by Frost on 3/23/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NoticeVC:UIViewController,UITableViewDelegate,UITableViewDataSource {
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    private var list = [Notice]()
    @IBOutlet var tblNotice: UITableView!
    @IBOutlet weak var btnNew: UIButton!
    
    var created:Bool = false
    var plusButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Notices"
        tblNotice.tableFooterView = UIView()
        if(Common.shared.userRole != "AppAdmin" ){
            self.btnNew.isHidden = true
        }else{
            self.btnNew.layer.cornerRadius = 30
            self.btnNew.clipsToBounds = true
        }
        showProgressBar()
        var url = "GetAppNotification?studentId=0"
        if(Common.shared.userId != ""){
            if(Common.shared.userRole.lowercased() == "appstudent" || Common.shared.userRole.lowercased() == "appparent"){
                url = "GetAppNotification?studentId=\(Common.shared.studentId)&isStudent=true&isStaff=false"
            }else{
                url = "GetAppNotification?studentId=\(Common.shared.staffId)&isStudent=false&isStaff=true"
            }
            
        }
        self.fnDownloadNotice(url:appUrl + url)
    }
    
    
    //    override func viewDidLayoutSubviews() {
    //        tblNotice.frame = CGRect(x: tblNotice.frame.origin.x, y: tblNotice.frame.origin.y, width: tblNotice.frame.size.width, height: tblNotice.contentSize.height)
    //        tblNotice.reloadData()
    //    }
    
    //    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 145
    //    }
    
    //    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
    //
    //        let label = UILabel()
    //        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width, height: 50)
    //        label.text = tableViewData[section].title
    //        label.font = UIFont.boldSystemFont(ofSize: 20.0)
    //        label.textColor = UIColor.black
    //        label.backgroundColor = UIColor.blue
    //        headerView.addSubview(label)
    //
    //        return headerView
    //    }
    //
    //    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return 50
    //    }
    //
    //    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return "Notice"
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(list.count == 0){
            self.tblNotice.setEmptyMessage("")
        } else {
            self.tblNotice.restore()
        }
        
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "noticeViewCell") as? NoticeViewCell else {
            return UITableViewCell()
        }
        let obj:Notice = list[indexPath.row]
        //            let date:String = obj.date
        //            let dateArr = date.components(separatedBy: "-")
        //            if dateArr.count > 2 {
        //                let monthNumber = Int(dateArr[1])! - 1
        //                let monthName = DateFormatter().monthSymbols[monthNumber]
        //                cell.txtNotifDay.text = monthName.prefix(4) + ", " + dateArr[2]
        //            }
        cell.txtNotifDuration.text = obj.duration
        cell.txtNotifGroup.text = obj.type
        if(obj.type == "Past"){
            cell.txtNotifGroup.textColor = UIColor.systemBlue
        } else if(obj.type == "Upcoming"){
            cell.txtNotifGroup.textColor = UIColor.green
        }
        cell.txtNotifDate.text = obj.date
        cell.txtNotifTitle.text = obj.title.capitalizingFirstLetter()
        cell.txtNotifDesc.text = obj.desc.capitalizingFirstLetter()
        var imageUrl = obj.imageUrl
        if imageUrl != "" {
            imageUrl = imageUrl.replacingOccurrences(of: "~", with: baseUrl)
            cell.imgNotice.kf.setImage(with: URL(string: imageUrl))
        } else {
            cell.imgNotice.isHidden = true
            cell.imgNoticeWidth.constant = 0
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let obj:Notice = list[indexPath.row]
        if(obj.imageUrl == "" && obj.desc == "") {
            return 60
        }
        if(obj.imageUrl == "") {
            return 95
        }
        return 95
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC =  storyboard.instantiateViewController(withIdentifier: "noticeContentVC") as! NoticeContentVC
        let obj:Notice = list[indexPath.row]
        VC.noticeTitle = obj.title
        VC.desc = obj.desc
        if(obj.imageUrl != ""){
            VC.imageUrl = obj.imageUrl.replacingOccurrences(of: "~", with: baseUrl)
        }
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func showToast(message: String) {
        let toastLabel = UITextView(frame: CGRect(x: self.view.frame.size.width/16, y: self.view.frame.size.height-150, width: self.view.frame.size.width * 7/8, height: 45))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.text = "   \(message)   "
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.font = UIFont(name: (toastLabel.font?.fontName)!, size: 16)
        toastLabel.center.x = self.view.frame.size.width/2
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func openView(viewName:String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC =  storyboard.instantiateViewController(withIdentifier: viewName)
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func fnDownloadNotice( url:String){
        self.list.removeAll()
        Alamofire.request(url, method: .get)
            .validate { request, response, data in
                return .success
        }
        .responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    if(json["ExceptionType"].stringValue == "" && json["Message"].stringValue == ""){
                        let notifTodayArray = json["notifToday"].array
                        let notifUpcomingArray = json["notifUpcomming"].array
                        let notifPastArray = json["notifPast"].array
                        var count = 0
                        var count1 = 0
                        var count2 = 0
                        var noticeId,title,content,date,imageUrl,type,duration : String
                        while(count2 < notifTodayArray?.count ?? 0){
                            let JO = JSON(notifTodayArray![count2])
                            noticeId = JO["ID"].stringValue
                            title = JO["NotifTitle"].stringValue
                            content = JO["NotifDescription"].stringValue
                            date = JO["NotifDateNp"].stringValue
                            imageUrl = JO["ImagePath"].stringValue
                            type = "Today"
                            duration = JO["Duration"].stringValue
                            self.list.append(Notice(day: "21", date: date, type: type, title: title, desc: content, imageUrl: imageUrl,duration: duration))
                            count2 = count2 + 1
                        }
                        while(count1 < notifUpcomingArray?.count ?? 0){
                            let JO = JSON(notifUpcomingArray![count1])
                            noticeId = JO["ID"].stringValue
                            title = JO["NotifTitle"].stringValue
                            content = JO["NotifDescription"].stringValue
                            date = JO["NotifDateNp"].stringValue
                            imageUrl = JO["ImagePath"].stringValue
                            type = "Upcoming"
                            duration = JO["Duration"].stringValue
                            self.list.append(Notice(day: "21", date: date, type: type, title: title, desc: content, imageUrl: imageUrl,duration: duration))
                            count1 = count1 + 1
                        }
                        while(count < notifPastArray?.count ?? 0){
                            let JO = JSON(notifPastArray![count])
                            noticeId = JO["ID"].stringValue
                            title = JO["NotifTitle"].stringValue
                            content = JO["NotifDescription"].stringValue
                            date = JO["NotifDateNp"].stringValue
                            imageUrl = JO["ImagePath"].stringValue
                            type = "Past"
                            duration = JO["Duration"].stringValue
                            self.list.append(Notice(day: "21", date: date, type: type, title: title, desc: content, imageUrl: imageUrl,duration: duration))
                            count = count + 1
                        }
                        self.hideProgressBar()
                        self.tblNotice.reloadData()
                        //                        self.fnCreateNewButton()
                    } else {
                        self.hideProgressBar()
                        self.tblNotice.reloadData()
                        self.showToast(message: exceptionMessage)
                    }
                }
            case .failure(let error):
                print(error)
                self.hideProgressBar()
                self.tblNotice.reloadData()
                self.showToast(message: exceptionMessage)
            }
        }
    }
    
    func showProgressBar(){
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
    }
    
    func hideProgressBar(){
        activityIndicator.stopAnimating()
    }
    
    
    @IBAction func btnNewfn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        openView(viewName: "newNoticeVC")
    }
    
    //    override func viewDidLayoutSubviews() {
    //        self.plusButton.center = CGPoint(x: view.bounds.size.width - 50,
    //                                         y: view.bounds.size.height - 110)
    //        if created == false {
    //            if(Common.shared.userRole == "AppAdmin" ){
    //                self.fnCreateNewButton()
    //            }
    //        }
    //    }
    
    //    func fnCreateNewButton(){
    //        self.created = true
    //        self.plusButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
    //
    //        self.plusButton.setBackgroundImage(#imageLiteral(resourceName: "new_attendance"), for: .normal)
    //        self.plusButton.contentMode = UIView.ContentMode.scaleAspectFit
    //        self.plusButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    //        self.view.addSubview(self.plusButton)
    //
    //        self.plusButton.translatesAutoresizingMaskIntoConstraints = false
    ////        let horizontalConstraint = button.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ////        let verticalConstraint = button.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ////        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 70)
    ////        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 70)
    ////        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    //
    //
    //    }
    
    //    @objc func buttonAction(sender: UIButton!) {
    //        self.dismiss(animated: true, completion: nil)
    //        openView(viewName: "newNoticeVC")
    //    }
    
}
