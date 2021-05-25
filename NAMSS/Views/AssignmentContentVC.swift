//
//  AssignmentContentVC.swift
//  NAMSS
//
//  Created by ITH on 25/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit

class AssignmentContentVC: UIViewController {
    
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var txtStatus: UILabel!
    @IBOutlet weak var assignmentView: UIView!
    @IBOutlet weak var txtSubjectName: UILabel!
    @IBOutlet weak var txtTeacher: UILabel!
    @IBOutlet weak var txtDeadline: UILabel!
    @IBOutlet weak var tblFiles: UICollectionView!
    @IBOutlet weak var tblNewFiles: UICollectionView!
    @IBOutlet weak var txtDescription: UITextView!
    
    var sectionData = [String]()
    
    var assignment:AssignmentV2 = AssignmentV2()
    var resouceFailList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(title: "Submit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.submitLink(sender:)))
        self.navigationItem.rightBarButtonItem = doneButton
        
        self.txtDescription.text = assignment.description
        self.txtDescription.translatesAutoresizingMaskIntoConstraints = true
        self.txtDescription.sizeToFit()
        self.txtDescription.isScrollEnabled = false
        self.txtDescription.layer.borderColor = UIColor.lightGray.cgColor;
        self.txtDescription.layer.borderWidth = 1.0;
        self.txtDescription.layer.cornerRadius = 8;
        
        self.tblNewFiles.layer.borderColor = UIColor.lightGray.cgColor;
        self.tblNewFiles.layer.borderWidth = 1.0;
        self.tblNewFiles.layer.cornerRadius = 8;
        
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
        
        // Do any additional setup after loading the view.
    }
    
    @objc func submitLink(sender: UIBarButtonItem){
        
//        let selectedDate = getSelectedDate()
//        let joiningLink = self.txtLink.text ?? ""
//        let remark = self.txtRemarks.text ?? ""
//
//        let url = appUrl + "SubmitOnlineClassLink?userid=\(Common.shared.userId)&teacherid=\(Common.shared.teacherId)&classid=\(self.classId)&subjectid=\(self.subjectId)&onlineClassDateTime=\(selectedDate)&joiningLink=\(joiningLink)&remark=\(remark)"
//
//        fnPostApiWithUrlEcoding(url: url, completionHandler: {(res,json)->Void in
//            if(res){
//                showToast(state: self, message: "Online class link submitted successfully.")
//                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
//                    self.navigationController?.popViewController(animated: true)
//                }
//            }else{
//                showToast(state: self, message: "Error adding class link. Please Try again")
//            }
//        })
    }
    
    func showImage(url:String)
    {
        let plusIcon = UIImage(named: "new_attendance")
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
        if collectionView == self.tblNewFiles{
            return 1
        }
        return sectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileViewCell", for: indexPath) as! FileViewCell
        if collectionView == self.tblNewFiles{
            cell.imgFile.image = UIImage(named: "ic_plus")
            cell.imgFile.contentMode = .center
        } else {
            let url = sectionData[indexPath.section]
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
        }
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.tblNewFiles{
            let url = sectionData[indexPath.section]
            if(!self.resouceFailList.contains(String(indexPath.section))){
                showImage(url: url)
            }
        } else {
            //open gallery
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        //        let width = self.calculateWith()
//        return CGSize(width: CGFloat((collectionView.frame.size.width / 3) - 3), height: 110)
//    }

}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */
