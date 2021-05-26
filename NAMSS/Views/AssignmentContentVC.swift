//
//  AssignmentContentVC.swift
//  NAMSS
//
//  Created by ITH on 25/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit
import SwiftyJSON
import PhotosUI
import MobileCoreServices
import UniformTypeIdentifiers

class AssignmentContentVC: UIViewController {
    
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    private var imagePicker:UIImagePickerController? = nil
    @IBOutlet weak var txtStatus: UILabel!
    @IBOutlet weak var assignmentView: UIView!
    @IBOutlet weak var txtSubjectName: UILabel!
    @IBOutlet weak var txtTeacher: UILabel!
    @IBOutlet weak var txtDeadline: UILabel!
    @IBOutlet weak var tblFiles: UICollectionView!
    @IBOutlet weak var tblNewFiles: UITableView!
    @IBOutlet weak var txtDescription: UITextView!
    
    
    
    var sectionData = [String]()
    var newFilesBase64 = [String]()
    var newFiles = [String]()
    
    var assignment:AssignmentV2 = AssignmentV2()
    var resouceFailList = [String]()
    var selectLimit = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(title: "Submit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.submitLink(sender:)))
        self.navigationItem.rightBarButtonItem = doneButton
        
        self.txtDescription.text = assignment.homeworkDescription
        self.txtDescription.layer.borderColor = UIColor.lightGray.cgColor;
        self.txtDescription.layer.borderWidth = 1.0;
        self.txtDescription.layer.cornerRadius = 8;
        
        self.tblFiles.delegate = self
        self.tblFiles.dataSource = self
        
        self.tblNewFiles.tableFooterView = UIView()
        
        self.tblFiles.layer.borderColor = UIColor.lightGray.cgColor;
        self.tblFiles.layer.borderWidth = 1.0;
        self.tblFiles.layer.cornerRadius = 8;
        
        self.assignmentView.layer.cornerRadius = 5
        self.txtStatus.text = assignment.status
        self.txtSubjectName.text = assignment.subjectName
        self.txtTeacher.text = "Assignee: \(assignment.teacherName)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-ddTHH:mm:ss"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        print(assignment.submissionDateEn)
        let convertedDate = formatter.date(from: assignment.submissionDateEn) ?? Date()
        formatter.dateFormat = "dd MMMM ',' h:mm a"
        self.txtDeadline.text = "Deadline : \(formatter.string(from: convertedDate))"
        
        tblFiles.layer.borderColor = UIColor.black.cgColor
        
        let images = assignment.imageUrl
        let splitImages = images.split(separator: ",")
        for i in splitImages {
            let imageUrl = i.replacingOccurrences(of: "~", with: baseUrl)
            sectionData.append(imageUrl)
        }
        
        self.tblFiles.reloadData()
        self.tblNewFiles.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.imagePicker = UIImagePickerController()
        self.imagePicker!.delegate = self
    }
    
    @IBAction func selectFile(_ sender: Any) {
        let alert = UIAlertController(title: "Select File", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction(title: "Open Files", style: .default, handler: { _ in
            self.selectFiles()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender as! UIView
            alert.popoverPresentationController?.sourceRect = (sender as AnyObject).bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
//        if selectLimit > 2 {
//            showToast(state: self, message: "Please select only 2 files at a fime to upload!")
//            return
//        }
        self.present(alert, animated: true, completion: nil)
        selectLimit += 1
    }
    
    func selectFiles() {
        let types: [String] = [kUTTypePDF as String, kUTTypeText as String]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker!.sourceType = UIImagePickerController.SourceType.camera
//            imagePicker!.allowsEditing = true
            self.present(imagePicker!, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary(){
        
        //        if #available(iOS 14, *) {
        //            var config = PHPickerConfiguration()
        //            config.selectionLimit = 1
        //            config.filter = PHPickerFilter.images
        //            let pickerViewController = PHPickerViewController(configuration: config)
        //            pickerViewController.delegate = self
        //            self.present(pickerViewController, animated: true, completion: nil)
        //        } else {
        //            // Fallback on earlier versions
        //        }
        
        imagePicker!.sourceType = UIImagePickerController.SourceType.photoLibrary
//        imagePicker!.allowsEditing = true
        self.present(imagePicker!, animated: true, completion: nil)
    }
    
    @objc func submitLink(sender: UIBarButtonItem){
        
        showProgressBar(state: self, activityIndicator: self.activityIndicator)
        var valuesArray = [Dictionary<String, String>]()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        for i in self.newFilesBase64 {
            var json = [String:String]()
            json["SubmittedHomeWorkId"] = assignment.homeworkId
            json["SubmissionDate"] = dateFormatter.string(from: Date())
            json["DocumentUrl"] = i
            json["Remarks"] = self.txtDescription.text
            valuesArray.append(json)
        }
        
        let finalJson = ["StudentUserId":JSON("\(Common.shared.userId)"),"StudentId":JSON("\(Common.shared.studentId)"),"ClassHomeworkId":JSON("\(assignment.homeworkId)"),"SubmissionDate":JSON("\(dateFormatter.string(from: Date()))"),"homeWorkFile":JSON(valuesArray)]
        
        fnPostApiWithJsonEncoding(url: appUrl + "SubmitHomeworkSubmission?userid=\(Common.shared.userId)", json: JSON(finalJson), completionHandler: {(res,json)->Void in
            hideProgressBar(activityIndicator: self.activityIndicator)
            if(res){
                showToast(state: self, message: "Assignment submitted!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.navigationController?.popViewController(animated: true)
                }
                
            }else{
                showToast(state: self, message: "Error adding Assignment. Please Try again")
            }
        })
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
    
}

extension AssignmentContentVC : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileViewCell", for: indexPath) as! FileViewCell
        let url = sectionData[indexPath.row]
        cell.imgFile.kf.setImage(with: URL(string: url), completionHandler:  {
            result in
            switch result {
            case  .success(_):
                cell.imgFile.contentMode = .scaleAspectFit
                print("Image set")
            case .failure(_):
                cell.imgFile.image = UIImage(named: "ic_nofile")
                self.resouceFailList.append(String(indexPath.section))
            }
        })
        cell.imgFile.clipsToBounds = true
        cell.imgFile.layer.cornerRadius = 5
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = sectionData[indexPath.row]
        if self.resouceFailList.contains(url) {
            self.showImage(url: url)
        } else {
            showToast(state: self, message: "No any files!")
        }
    }
    
}

extension AssignmentContentVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tblNewFiles.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = newFiles[indexPath.row]
        cell?.textLabel?.textColor = UIColor.darkGray
        cell?.textLabel?.textAlignment = .left
        cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 12.0)
        cell?.backgroundView?.backgroundColor = UIColor.blue
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        cell?.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return (cell)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 15
    }
    
}

extension AssignmentContentVC : UITextFieldDelegate, UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var imageName = ""
        if let asset = info[.imageURL] as? URL {
            imageName = asset.lastPathComponent as! String
        }
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let imageData:Data = pickedImage.pngData()!
            let fileExtension = imageName.split(separator: ".").last ?? "jpeg"
            let base64String = "data:image/\(fileExtension);base64," + imageData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            self.newFilesBase64.append(base64String)
            imageName = imageName.isEmpty ? "new image" : imageName.prefix(18) + "...." + fileExtension
            self.newFiles.append("\(imageName) added")
            self.tblNewFiles.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AssignmentContentVC : UIDocumentMenuDelegate,UIDocumentPickerDelegate{
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        
        do {
            let fileData:Data = try Data.init(contentsOf: myURL)
            let base64String = "data:application/pdf;base64," + fileData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            self.newFilesBase64.append(base64String)
            self.newFiles.append("\(myURL.lastPathComponent) added")
            self.tblNewFiles.reloadData()
        } catch {
            showToast(state: self, message: "Failed to load selected File!")
        }
    }
    
}
