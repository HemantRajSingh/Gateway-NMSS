//
//  Common.swift
//  SchoolApp
//
//  Created by Hemant Raj  Singh on 2/20/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

let schoolName = "National Model Science School"
let schoolAddress = "Gongabu, Kathmandu, Nepal"
let appUrl = "http://202.51.74.57:908/api/AppData/"
let appUrlV2 = "http://202.51.74.57:908/api/AppDataV2/"
let baseUrl = "http://202.51.74.57:908/"
let exceptionMessage = "Something went Wrong!"
var firebaseToken = ""
class Common {
    
    static let shared = Common()
    var username = ""
    var userId = ""
    var userRole = ""
    var studentId = ""
    var staffId = ""
    var teacherId = ""
    var memberTypeId = ""
    var guardianId = ""
    var classId = ""
    var sectionId = ""
    var subjectId = ""
    var examId = ""
    var periodId = ""
    var userDetail = JSON().dictionary
    var parentId = ""
    
    init() {}

}

func openView(state:UIViewController,viewName:String){
    var storyboard = AppStoryboard.Main.instance
    if(viewName == "noticeVC" || viewName == "calendarVC"){
        storyboard = AppStoryboard.MainPage.instance
    } else if(viewName == "OnlineClassSubmitLinkVC") {
        storyboard = AppStoryboard.ClassActivity.instance
    }
    let VC =  storyboard.instantiateViewController(withIdentifier: viewName)
    state.navigationController?.pushViewController(VC, animated: true)
}

func displayAlertMessage(state:UIViewController,msg:String){
    let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertController.Style.alert);
    let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil);
    alert.addAction(okAction);
    state.present(alert,animated:true, completion: nil);
}

func showProgressBar(state:UIViewController,activityIndicator:UIActivityIndicatorView){
    activityIndicator.center = state.view.center
    activityIndicator.hidesWhenStopped = true
    activityIndicator.style = UIActivityIndicatorView.Style.gray
    activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
    activityIndicator.startAnimating()
    state.view.addSubview(activityIndicator)
//    UIApplication.shared.beginIgnoringInteractionEvents()
}

func showProgressBarIgnoringUserEvents(state:UIViewController,activityIndicator:UIActivityIndicatorView){
    activityIndicator.center = state.view.center
    activityIndicator.hidesWhenStopped = true
    activityIndicator.style = UIActivityIndicatorView.Style.gray
    activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
    activityIndicator.startAnimating()
    state.view.addSubview(activityIndicator)
    UIApplication.shared.beginIgnoringInteractionEvents()
}

func hideProgressBar(activityIndicator:UIActivityIndicatorView){
    activityIndicator.stopAnimating()
    UIApplication.shared.endIgnoringInteractionEvents()
}

func showToast(state:UIViewController,message: String) {
    let toastLabel = UITextView(frame: CGRect(x: state.view.frame.size.width/16, y: state.view.frame.size.height-150, width: state.view.frame.size.width * 7/8, height: 65))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = .center;
    toastLabel.text = "   \(message)   "
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    toastLabel.font = UIFont(name: (toastLabel.font?.fontName)!, size: 16)
    toastLabel.center.x = state.view.frame.size.width/2
    if let topController = UIApplication.shared.keyWindow?.rootViewController{
        topController.view.addSubview(toastLabel)
    }
    UIView.animate(withDuration: 5.0, delay: 0, options: .curveEaseOut, animations: {
        toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
}

