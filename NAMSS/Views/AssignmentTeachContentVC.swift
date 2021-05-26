//
//  AssignmentTeachContentVC.swift
//  NAMSS
//
//  Created by ITH on 26/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class AssignmentTeachContentVC: UIViewController {
    
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    private var imagePicker:UIImagePickerController? = nil
    
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var txtStatus: UILabel!
    @IBOutlet weak var txtClass: UILabel!
    @IBOutlet weak var txtSection: UILabel!
    @IBOutlet weak var txtSubject: UILabel!
    @IBOutlet weak var txtSubmttedBy: UILabel!
    @IBOutlet weak var txtSubmissionDate: UILabel!
    @IBOutlet weak var teacherFeedbackDate: UILabel!
    @IBOutlet weak var tblFiles: UICollectionView!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var imgAssignment: UIImageView!
    
    var files = [String]()
    
    var assignment:AssignmentContent = AssignmentContent()
    var assignmentUrl = ""
    var resouceFailList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Assignment Detail"
        self.txtStatus.text = ""
        self.imgAssignment.kf.setImage(with: URL(string: assignmentUrl), completionHandler:  {
            result in
            switch result {
            case  .success(_):
                print("Image set")
            case .failure(let error):
                self.resouceFailList.append(self.assignmentUrl)
                self.imgAssignment.image = UIImage(named: "ic_nofile")
                print(error)
            }
        })
        
        let tapGesture = UITapGestureRecognizer(target:self,action:#selector(viewTapped(gestureRecognizer:)))
        self.imgAssignment.isUserInteractionEnabled = true
        self.imgAssignment.addGestureRecognizer(tapGesture)
        
        self.displayAssignmentContent(assignment: assignment)
    }
    
    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
        if self.resouceFailList.contains(assignmentUrl) {
            showToast(state: self, message: "Failed to open file!")
        } else {
            self.showImage(url: assignmentUrl)
        }
    }
    
    func displayAssignmentContent(assignment:AssignmentContent){
        showProgressBar(state: self, activityIndicator: self.activityIndicator)
        
        self.files = assignment.filesList
        tblFiles.reloadData()
        
        self.viewStatus.layer.cornerRadius = 5
        self.txtStatus.text = "SUBMITTED"
        self.txtClass.text = "Class: " + assignment.className
        self.txtSection.text = "Section: " + assignment.sectionName.lowercased().capitalizingFirstLetter()
        self.txtSubject.text = "Subject: \(assignment.homeworkName)"
        self.txtSubmissionDate.text = "Submisson Date: " + assignment.submissionDate
        self.teacherFeedbackDate.text = assignment.teacherFeedbackDate
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let convertedDate = formatter.date(from: assignment.submissionDate) ?? Date()
        formatter.dateFormat = "dd MMMM ',' h:mm a"
        self.txtSubmissionDate.text = "Submisson Date: \(formatter.string(from: convertedDate))"
        
        self.tblFiles.layer.borderColor = UIColor.lightGray.cgColor;
        self.tblFiles.layer.borderWidth = 1.0;
        self.tblFiles.layer.cornerRadius = 8;
        
        self.txtDescription.text = assignment.teacherMarks + " " + assignment.remarks
        self.txtDescription.layer.borderColor = UIColor.lightGray.cgColor;
        self.txtDescription.layer.borderWidth = 1.0;
        self.txtDescription.layer.cornerRadius = 8;
        hideProgressBar(activityIndicator: self.activityIndicator)
    }
    
    func showImage(url:String)
    {
        let plusIcon = UIImage(named: "")
        let newImageView = UIImageView(image: plusIcon)
        newImageView.kf.setImage(with: URL(string: url))
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage(sender:)))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    func openPdf(path:String){
        let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let downloadUrl = URL(string: path)
        let destinationUrl = documentsPath.appendingPathComponent(downloadUrl!.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: destinationUrl.absoluteString) {
            DispatchQueue.main.async {
                let pdfViewController = PDFViewController(pdfUrl: destinationUrl)
//                    pdfViewController.pdfURL = destinationUrl
                self.present(pdfViewController, animated: true, completion: nil)
            }
        } else {
            showProgressBar(state: self, activityIndicator: self.activityIndicator)
            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
            let downloadTask = urlSession.downloadTask(with: downloadUrl!)
            downloadTask.resume()
        }
    }
    
}

extension AssignmentTeachContentVC : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileViewCell", for: indexPath) as! FileViewCell
        let path = files[indexPath.row]
        let fileUrl = URL(string: path)!
        if fileUrl.lastPathComponent.split(separator: ".")[1] == "pdf" {
            cell.imgFile.image = UIImage(named: "ic_assignment")
        } else {
            let resizingProcessor = ResizingImageProcessor(referenceSize: CGSize(width: 90, height: 95))
            cell.imgFile.kf.setImage(with: fileUrl, options: [.processor(resizingProcessor)],completionHandler:  {
                result in
                switch result {
                case  .success(_):
                    print("Image set")
                case .failure(_):
                    cell.imgFile.image = UIImage(named: "ic_nofile")
                    self.resouceFailList.append(path)
                }
            })
        }
//        cell.imgFile.clipsToBounds = true
//        cell.imgFile.layer.cornerRadius = 5
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 98)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let path = files[indexPath.row]
        let fileUrl = URL(string: path)!
        if fileUrl.lastPathComponent.split(separator: ".")[1] == "pdf" {
            self.openPdf(path: path)
        } else {
            if self.resouceFailList.contains(path) {
                showToast(state: self, message: "Failed to open file!")
            } else {
                self.showImage(url: path)
            }
        }
    }
    
}

extension AssignmentTeachContentVC: URLSessionDownloadDelegate {
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
