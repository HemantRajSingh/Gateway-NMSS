//
//  LearningMaterialsVC.swift
//  NAMSS
//
//  Created by ITH on 25/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LearningMaterialsVC: UIViewController {
    
    var list = [LearningMaterial]()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var tblMaterials: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tblMaterials.tableFooterView = UIView()
        fnGetLearningMaterials()
    }
    
    func fnGetLearningMaterials(){
        let url:String = appUrl + "GetLearningMaterials?userid=\(Common.shared.userId)"
        showProgressBar(state: self, activityIndicator: self.activityIndicator)
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
                            for (_,subJson):(String, JSON) in json {
                                self.list.append(LearningMaterial(facultyName: subJson["FacultyName"].stringValue, programmeName: subJson["ProgramName"].stringValue, className: subJson["ClassName"].stringValue, subjectName: subJson["SubjectName"].stringValue, submitBy: subJson["SubmitBy"].stringValue, documentTitle: subJson["DocumentTitle"].stringValue, documentUrl: subJson["DocumentUrl"].stringValue, materialType: subJson["MaterialType"].stringValue, remarks: subJson["Remarks"].stringValue))
                            }
                            
                            hideProgressBar(activityIndicator: self.activityIndicator)
                            self.tblMaterials.reloadData()
                        }else{
//                            showToast(state: self, message: "No any books")
                            hideProgressBar(activityIndicator: self.activityIndicator)
                            self.tblMaterials.reloadData()
                        }
                    }
                case .failure( _):
                    hideProgressBar(activityIndicator: self.activityIndicator)
                    showToast(state: self, message: "Network failure")
                }
        }
    }

}

extension LearningMaterialsVC : UITableViewDelegate, UITableViewDataSource, URLSessionDownloadDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(list.count == 0){
            tblMaterials.setEmptyMessage("")
        } else {
            tblMaterials.restore()
        }
        return list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MaterialViewCell", for: indexPath) as? MaterialViewCell else{
            return UITableViewCell()
        }
        let obj:LearningMaterial = list[indexPath.row]
        
        cell.txtTitle.text = obj.documentTitle
        cell.txtSubject.text = "Subject: \(obj.subjectName)"
        cell.txtSubmitBy.text = "Submit By: \(obj.submitBy)"
        cell.txtType.text = obj.materialType.uppercased()
        cell.txtDescription.text = obj.remarks
        
        if(obj.documentUrl != "" && obj.documentUrl != "null"){
            cell.imgDownload.image = UIImage(named: "ic_download")
        } else {
            cell.imgDownload.image = UIImage(named: "")
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj:LearningMaterial = list[indexPath.row]
        if(obj.documentUrl != "" && obj.documentUrl != "null"){
            guard let downloadUrl = URL(string: obj.documentUrl.replacingOccurrences(of: "~", with: baseUrl)) else {return}
            let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let destinationUrl = documentsPath.appendingPathComponent(downloadUrl.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: destinationUrl.absoluteString) {
                DispatchQueue.main.async {
                    let pdfViewController = PDFViewController(pdfUrl: destinationUrl)
//                    pdfViewController.pdfURL = destinationUrl
                    self.present(pdfViewController, animated: true, completion: nil)
                }
            } else {
                showProgressBar(state: self, activityIndicator: self.activityIndicator)
                let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
                let downloadTask = urlSession.downloadTask(with: downloadUrl)
                downloadTask.resume()
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadLocation:", location)
        guard let downloadUrl = downloadTask.originalRequest?.url else {return}
        let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let destinationUrl = documentsPath.appendingPathComponent(downloadUrl.lastPathComponent)
        
        //delete original copy
        try? FileManager.default.removeItem(at: destinationUrl)
        //copy frorm temp to Document
        do {
            try FileManager.default.copyItem(at: location, to: destinationUrl)
            DispatchQueue.main.async {
                let pdfViewController = PDFViewController(pdfUrl: destinationUrl)
//                pdfViewController.pdfURL = destinationUrl
                hideProgressBar(activityIndicator: self.activityIndicator)
                self.present(pdfViewController, animated: true, completion: nil)
            }
        } catch let error {
            print("Copy Error: \(error.localizedDescription)")
            hideProgressBar(activityIndicator: self.activityIndicator)
        }
    }
}
