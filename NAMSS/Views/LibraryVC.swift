//
//  LibraryVC.swift
//  MMIHS
//
//  Created by Frost on 4/15/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LibraryVC: UIViewController {

    var list = [Library]()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtAuthor: UITextField!
    @IBOutlet weak var txtPublisher: UITextField!
    @IBOutlet weak var txtKeywords: UITextField!
    @IBOutlet weak var tblLibrary: UITableView!
    
    
    @IBAction func btnSearch(_ sender: Any) {
        self.view.endEditing(true)
        var url:String = appUrlV2 + "GetBookDetailSearch?booktitle=%@&author=%@&publisher=%@&keywords=%@"
        url = String(format: url, txtTitle.text ?? "",txtAuthor.text ?? "",txtPublisher.text ?? "",txtKeywords.text ?? "")
        
        fnBookSearch(url: url)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblLibrary.delegate = self
        tblLibrary.dataSource = self
        tblLibrary.sectionHeaderHeight = 50
        tblLibrary.tableFooterView = UIView()
        tblLibrary.keyboardDismissMode = .onDrag
        
        fnBookSearch(url: appUrlV2 + "GetBookDetailSearch?booktitle=a&author=&publisher=&keywords=")

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func fnBookSearch( url:String){
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
                                self.list.append(Library(id: subJson["BookCatalogId"].stringValue, name: subJson["BookName"].stringValue, author: subJson["Author"].stringValue, a1: subJson["Author1"].stringValue, a2: subJson["Author2"].stringValue, publisher: subJson["Publisher"].stringValue, circularBookCount: subJson["CircularBookCount"].stringValue, issuedBookCount: subJson["IssuedBookCount"].stringValue, availableBookCount: subJson["AvailableBookCount"].stringValue, edition: subJson["Edition"].stringValue, publishedYear: subJson["PublishedYear"].stringValue, bookDownloadUrl: subJson["BookDownloadUrl"].stringValue))
                            }
                            
                            hideProgressBar(activityIndicator: self.activityIndicator)
                            self.tblLibrary.reloadData()
                        }else{
//                            showToast(state: self, message: "No any books")
                            hideProgressBar(activityIndicator: self.activityIndicator)
                            self.tblLibrary.reloadData()
                        }
                    }
                case .failure( _):
                    hideProgressBar(activityIndicator: self.activityIndicator)
                    showToast(state: self, message: "Network failure")
                }
        }
    }

}


extension LibraryVC : UITableViewDelegate, UITableViewDataSource, URLSessionDownloadDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(list.count == 0){
            tblLibrary.setEmptyMessage("")
        } else {
            tblLibrary.restore()
        }
        return list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "libraryViewCell", for: indexPath) as? LibraryViewCell else{
            return UITableViewCell()
        }
        let obj:Library = list[indexPath.row]
        var author = obj.author
        if(obj.a1 != ""){
            author += obj.a1
            if(obj.a2 != ""){
                author += obj.a2
            }
        }
        cell.txtAuthor.text = "Author : " + author
        cell.txtTitle.text = obj.name + "," + obj.edition
        cell.txtPublisher.text = "Publisher : " + obj.publisher + "," + obj.publishedYear
        cell.txtAvailable.text = "Available : " + obj.availableBookCount
        cell.txtIssued.text = "Issued : " + obj.issuedBookCount
        
        if(obj.bookDownloadUrl != "" && obj.bookDownloadUrl != "null"){
            cell.imgDownload.image = UIImage(named: "ic_download")
        } else {
            cell.imgDownload.image = UIImage(named: "")
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj:Library = list[indexPath.row]
        if(obj.bookDownloadUrl != "" && obj.bookDownloadUrl != "null"){
            guard let downloadUrl = URL(string: obj.bookDownloadUrl.replacingOccurrences(of: "~", with: baseUrl)) else {return}
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
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
//
//        let label = UILabel()
//        label.frame = CGRect.init(x: tableView.frame.width/2, y: tableView.frame.height/2, width: headerView.frame.width-10, height: headerView.frame.height-10)
//        label.text = "No Data found!"
//        label.font = UIFont.boldSystemFont(ofSize: 20.0)
//        label.textColor = UIColor.black
//
//        headerView.addSubview(label)
//
//        return headerView
//    }
    
}


