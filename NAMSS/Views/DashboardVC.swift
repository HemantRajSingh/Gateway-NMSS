//
//  DashboardVC.swift
//  MMIHS
//
//  Created by Hemant Raj  Singh on 2/24/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DashboardVC: UIViewController {
    
    private var menus = [Menu]()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imgSchoolPic: UIImageView!
    @IBOutlet weak var imgProfilePic: UIImageView!
    
    @IBAction func btnLogout(_ sender: Any) {
        let alert = UIAlertController(title: "Sure to Logout?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { _ in
            self.clearLocalStorage()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender as! UIView
            alert.popoverPresentationController?.sourceRect = (sender as AnyObject).bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    var estimatedWidth = 160.0
    var cellMarginSize = 7.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userRole = UserDefaults.standard.string(forKey: "userRole") ?? "'"
        if(userRole == ""){
            openView(viewName: "loginVC")
        }
        
        menus.append(Menu(menuId:1,view:"noticeVC", menuImage: #imageLiteral(resourceName: "ic_notice"), menuTitle: "Notice", menuDesc: "Notice"))
        menus.append(Menu(menuId:2,view:"calendarVC", menuImage: #imageLiteral(resourceName: "ic_calendar"), menuTitle: "Events", menuDesc: "Events"))
//        menus.append(Menu(menuId:3,view:"personalAttendanceVC", menuImage: #imageLiteral(resourceName: "ic_attendance2"), menuTitle: "Attendance", menuDesc: "Personal Attendance"))
        if(userRole == "AppAdmin"){
            menus.append(Menu(menuId:3,view:"personalAttendanceVC", menuImage: #imageLiteral(resourceName: "ic_attendance2"), menuTitle: "Attendance", menuDesc: "Personal Attendance"))
            menus.append(Menu(menuId:1,view:"attendanceReportVC", menuImage: #imageLiteral(resourceName: "ic_attendance2"), menuTitle: "Attendance", menuDesc: "Attendance Report"))
            menus.append(Menu(menuId:4,view:"attendanceVC", menuImage: #imageLiteral(resourceName: "ic_attendance2"), menuTitle: "Attendance", menuDesc: "Class Attendance"))
            menus.append(Menu(menuId:2,view:"parentFeedbackVC", menuImage: #imageLiteral(resourceName: "ic_assignment"), menuTitle: "Parent Feedback", menuDesc: "Feedbacks"))
            menus.append(Menu(menuId:3,view:"leaveRequestVC", menuImage: #imageLiteral(resourceName: "ic_assignment"), menuTitle: "Leave Requests", menuDesc: "Leave Requests"))
            menus.append(Menu(menuId:3,view:"aboutVC", menuImage: #imageLiteral(resourceName: "staff"), menuTitle: "Staffs", menuDesc: "Staff Details"))
        }else if userRole == "AppTeacher"{
            menus.append(Menu(menuId:3,view:"personalAttendanceVC", menuImage: #imageLiteral(resourceName: "ic_attendance2"), menuTitle: "Attendance", menuDesc: "Personal Attendance"))
            menus.append(Menu(menuId:4,view:"attendanceVC", menuImage: #imageLiteral(resourceName: "ic_attendance2"), menuTitle: "Attendance", menuDesc: "Class Attendance"))
            menus.append(Menu(menuId:8,view:"OnlineClassVC", menuImage: #imageLiteral(resourceName: "ic_onlineclass"), menuTitle: "Online Classroom", menuDesc: "Online Classroom"))
            menus.append(Menu(menuId:5,view:"assignmentVC", menuImage: #imageLiteral(resourceName: "ic_invoice"), menuTitle: "Assignment", menuDesc: "Add Assignment"))
            menus.append(Menu(menuId:9,view:"AssignmentTeacherVC", menuImage: #imageLiteral(resourceName: "ic_invoice"), menuTitle: "View Assignment", menuDesc: "View Assignment"))
            menus.append(Menu(menuId:9,view:"SubmitLearningMaterialVC", menuImage: #imageLiteral(resourceName: "ic_download"), menuTitle: "Learning Materials", menuDesc: "Add Learning Materials"))
            menus.append(Menu(menuId:6,view:"leaveRequestVC", menuImage: #imageLiteral(resourceName: "ic_assignment"), menuTitle: "Leave Requests", menuDesc: "Leave Requests"))
            menus.append(Menu(menuId:8,view:"messageVC", menuImage: #imageLiteral(resourceName: "ic_student"), menuTitle: "Message", menuDesc: "Send Message"))
            menus.append(Menu(menuId:2,view:"parentFeedbackVC", menuImage: #imageLiteral(resourceName: "ic_assignment"), menuTitle: "Parent Feedback", menuDesc: "Feedbacks"))
        }else if userRole == "AppStudent"{
            menus.append(Menu(menuId:3,view:"personalAttendanceVC", menuImage: #imageLiteral(resourceName: "ic_attendance2"), menuTitle: "Attendance", menuDesc: "Personal Attendance"))
            menus.append(Menu(menuId:8,view:"messageViewVC", menuImage: #imageLiteral(resourceName: "ic_student"), menuTitle: "Inbox", menuDesc: "Messages"))
            menus.append(Menu(menuId:8,view:"OnlineClassVC", menuImage: #imageLiteral(resourceName: "ic_onlineclass"), menuTitle: "Online Classroom", menuDesc: "Online Classroom"))
            menus.append(Menu(menuId:8,view:"invoiceVC", menuImage: #imageLiteral(resourceName: "ic_invoice-1"), menuTitle: "Fee Details", menuDesc: "Fee Details"))
            menus.append(Menu(menuId:4,view:"parentFeedbackVC", menuImage: #imageLiteral(resourceName: "ic_assignment"), menuTitle: "Parent Feedback", menuDesc: "Feedbacks"))
            menus.append(Menu(menuId:9,view:"assignmentVC", menuImage: #imageLiteral(resourceName: "ic_invoice"), menuTitle: "Assignment", menuDesc: "Assignment"))
            menus.append(Menu(menuId:9,view:"LearningMaterialsVC", menuImage: #imageLiteral(resourceName: "ic_download"), menuTitle: "Learning Materials", menuDesc: "View Learning Materials"))
            menus.append(Menu(menuId:10,view:"resultVC", menuImage: #imageLiteral(resourceName: "ic_results"), menuTitle: "Result", menuDesc: "Result"))
            DispatchQueue.main.async {
                self.fnGetStudentInfo(url: appUrl + "GetStudentInfo?id=" + Common.shared.studentId)
            }
        }else if userRole == "AppParent"{
            menus.append(Menu(menuId:0,view:"personalAttendanceVC", menuImage: #imageLiteral(resourceName: "ic_attendance2"), menuTitle: "Attendance", menuDesc: "Attendance Report"))
            menus.append(Menu(menuId:2,view:"invoiceVC", menuImage: #imageLiteral(resourceName: "ic_invoice-1"), menuTitle: "Fee Details", menuDesc: "Fee Details"))
            menus.append(Menu(menuId:4,view:"parentFeedbackVC", menuImage: #imageLiteral(resourceName: "ic_assignment"), menuTitle: "Parent Feedback", menuDesc: "Feedbacks"))
            menus.append(Menu(menuId:7,view:"assignmentVC", menuImage: #imageLiteral(resourceName: "ic_invoice"), menuTitle: "Assignment", menuDesc: "Assignment"))
            menus.append(Menu(menuId:9,view:"resultVC", menuImage: #imageLiteral(resourceName: "ic_results"), menuTitle: "Result", menuDesc: "Result"))
            DispatchQueue.main.async {
                self.fnGetStudentInfo(url: appUrl + "GetStudentInfo?id=" + Common.shared.studentId)
            }
        }
        menus.append(Menu(menuId:5,view:"routineVC", menuImage: #imageLiteral(resourceName: "ic_classrountine"), menuTitle: "Routine", menuDesc: "Exam/Class Routine"))
//        menus.append(Menu(menuId:8,view:"parentFeedbackVC", menuImage: #imageLiteral(resourceName: "ic_library"), menuTitle: "Feedback", menuDesc: "Parents Feedback"))
        menus.append(Menu(menuId:8,view:"libraryVC", menuImage: #imageLiteral(resourceName: "ic_library"), menuTitle: "Book Search", menuDesc: "Library"))
        menus.append(Menu(menuId:11,view:"galleryVC", menuImage: #imageLiteral(resourceName: "gallery"), menuTitle: "Gallery", menuDesc: "Gallery"))
        menus.append(Menu(menuId:12,view:"videosVC", menuImage: #imageLiteral(resourceName: "video"), menuTitle: "Videos", menuDesc: "Videos"))
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.setupGridView()
        imgProfilePic.setRounded()
        let encoded64 = UserDefaults.standard.string(forKey: "userimage") ?? ""
//        if(encoded64 != ""){
//            let split = encoded64.split(separator: ",")
//            if(split.count > 1){
//                let imageData = NSData(base64Encoded: String(split[1]))
//                imgProfilePic.image = UIImage(data: imageData! as Data)
//            }
//        }
        if(encoded64 != ""){
            var imageUrl = encoded64.replacingOccurrences(of: "~", with: baseUrl)
            imgProfilePic.kf.setImage(with: URL(string: imageUrl))
        }
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        imgProfilePic.isUserInteractionEnabled = true
        imgProfilePic.addGestureRecognizer(singleTap)
        
        DispatchQueue.main.async {
            self.fnGetOrganizationInfo()
        }
        
    }
    
    func clearLocalStorage(){
        UserDefaults.standard.set("",forKey:"username")
        UserDefaults.standard.set("",forKey:"password")
        UserDefaults.standard.set("",forKey:"userId")
        UserDefaults.standard.set("",forKey:"userRole")
        UserDefaults.standard.set(false,forKey: "rememberMe")
        UserDefaults.standard.set("",forKey:"userimage")
        Common.shared.userId = ""
        Common.shared.userRole = ""
        Common.shared.classId = ""
        Common.shared.staffId = ""
        Common.shared.studentId = ""
//        openView(viewName: "loginVC")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func removeFromMenu(menuId:Int){
        var index = 0
        for i in menus{
            if i.menuId == menuId{
                index = index + 1
            }
        }
        menus.remove(at: index)
    }
    
    
    @objc func tapDetected() {
        openView(viewName: "profileVC")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupGridView()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func setupGridView() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        if(viewName == "no"){
            showToast(message: "Still under construction!")
        } else if(viewName == "assignmentVC"){
            if(UserDefaults.standard.string(forKey: "userRole") == "AppStudent" || UserDefaults.standard.string(forKey: "userRole") == "AppParent"){
                storyboard = AppStoryboard.ClassActivity.instance
                let VC =  storyboard.instantiateViewController(withIdentifier: "AssignmentV2VC")
                self.navigationController?.pushViewController(VC, animated: true)
            }else{
                let VC =  storyboard.instantiateViewController(withIdentifier: "newAssignmentVC")
                self.navigationController?.pushViewController(VC, animated: true)
            }
        } else if(viewName == "galleryVC"){
            let VC =  storyboard.instantiateViewController(withIdentifier: "galleryVC") as! GalleryVC
            VC.type = "gallery"
            VC.title = "Gallery"
            self.navigationController?.pushViewController(VC, animated: true)
        } else if(viewName == "videosVC"){
            let VC =  storyboard.instantiateViewController(withIdentifier: "galleryVC") as! GalleryVC
            VC.type = "videos"
            VC.title = "Videos"
            self.navigationController?.pushViewController(VC, animated: true)
        } else if(viewName == "noticeVC" || viewName == "calendarVC"){
            let storyboard2 = UIStoryboard(name: "MainPage", bundle: nil)
            let VC = storyboard2.instantiateViewController(withIdentifier: viewName)
            self.navigationController?.pushViewController(VC, animated: true)
        } else if(viewName == "OnlineClassVC" || viewName == "LearningMaterialsVC" || viewName == "SubmitLearningMaterialVC" || viewName == "AssignmentTeacherVC"){
            storyboard = AppStoryboard.ClassActivity.instance
            let VC = storyboard.instantiateViewController(withIdentifier: viewName)
            self.navigationController?.pushViewController(VC, animated: true)
        } else {
            let VC = storyboard.instantiateViewController(withIdentifier: viewName)
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    func fnGetStudentInfo( url:String){
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
                            for (key,value) in json {
                                Common.shared.classId = String(json["ClassId"].int ?? 0)
                                Common.shared.sectionId = String(json["SectionId"].int ?? 0)
                            }
                        }
                    }
                case .failure(let error):
                    break
                }
        }
    }
    
    func fnGetOrganizationInfo(){
        let url:String = appUrl + "GetOrganizationInformation?OrganizationId=2"
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
                            let encoded64 = json["imgUrl"].stringValue
                            if(encoded64 != ""){
                                let split = encoded64.split(separator: ",")
                                if(split.count > 1){
                                    let imageData = NSData(base64Encoded: String(split[1]))
                                    if imageData != nil{
                                        self.imgSchoolPic.contentMode = UIView.ContentMode.scaleToFill
                                        self.imgSchoolPic.image = UIImage(data: imageData! as Data)
                                    }
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
}

extension DashboardVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.menus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuTableViewCell", for: indexPath) as? MenuTableViewCell else {
            return UICollectionViewCell()
        }
        cell.imgMenu.image = menus[indexPath.row].menuImage
        cell.imgMenu.clipsToBounds = true
        cell.txtMenuTitle.text = menus[indexPath.row].menuTitle
        cell.txtMenuDesc.text = menus[indexPath.row].menuDesc
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        let view = menus[row].view
        self.showToast(message: menus[row].menuDesc)
        if(view != ""){
            self.openView(viewName: view)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = self.calculateWith()
        return CGSize(width: CGFloat((collectionView.frame.size.width / 3) - 6), height: 85)
    }
    
    func calculateWith() -> CGFloat {
        let estimateWidth = CGFloat(estimatedWidth)
        var cellCount = floor(CGFloat(self.view.frame.size.width / estimateWidth))
        cellCount = 3
        
        let margin = CGFloat(cellMarginSize * Double(cellCount))
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}

extension UIImageView{
    func setRounded() {
        self.layer.cornerRadius = (self.frame.width / 2)
        self.layer.masksToBounds = true
    }
}
