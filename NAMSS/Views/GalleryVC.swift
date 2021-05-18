//
//  GalleryVC.swift
//  MMIHS
//
//  Created by Frost on 6/18/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import AVKit
import SafariServices

private let reuseIdentifier = "Cell"

class GalleryVC: UIViewController {
    
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    var sectionHeaders = [String]()
    var sectionData = [String:[Media]]()
    var estimatedWidth = 75.0
    var cellMarginSize = 0.0
    var type = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        showProgressBar(state: self, activityIndicator: activityIndicator)
        fnDownloadGallery()
    }
    
    
    func fnDownloadGallery(){
        self.sectionData.removeAll()
        self.sectionHeaders.removeAll()
        var url = appUrl + "GetMedia?type=image"
        if(type.lowercased() == "videos"){
            url = appUrl + "GetMedia?type=video"
        }
        Alamofire.request(url, method: .get)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        for (index,subJson):(String, JSON) in json {
                            var group = subJson["Group"].stringValue
                            if group == "" {
                                group = subJson["Date"].stringValue
                            }
                            var list:[Media] = [Media]()
                            for (index,subJson):(String, JSON) in json {
                                var group2 = subJson["Group"].stringValue
                                if group2 == "" {
                                    group2 = subJson["Date"].stringValue
                                }
                                if(group == group2){
                                    var thumbnail = ""
                                    if(self.type.lowercased() == "videos"){
                                        thumbnail = subJson["thumbnail"].stringValue
                                        if(thumbnail == ""){
                                            thumbnail = "https://cdn0.iconfinder.com/data/icons/social-messaging-ui-color-shapes-3/3/72-512.png"
                                        }else{
                                            thumbnail = thumbnail.replacingOccurrences(of: "~", with: baseUrl)
                                        }
                                    }
                                    var mediaUrl:String = subJson["MediaLink"].stringValue
                                    if(mediaUrl != ""){
                                        mediaUrl = mediaUrl.replacingOccurrences(of: "~", with: baseUrl)
                                    }
                                    let media = Media(id: subJson["Id"].stringValue, title: subJson["Title"].stringValue, desc: subJson["Description"].stringValue, url: mediaUrl, type: subJson["MediaType"].stringValue, status: subJson["Status"].stringValue, group: subJson["Group"].stringValue, date: subJson["Date"].stringValue, thumbnail: thumbnail)
                                    list.append(media)
                                }
                            }
                            if(self.sectionHeaders.index(of: group) == nil){
                                self.sectionHeaders.append(group)
                                self.sectionData[group] = list
                            }
                            
                        }
                        hideProgressBar(activityIndicator: self.activityIndicator)
                        self.galleryCollectionView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                    hideProgressBar(activityIndicator: self.activityIndicator)
                    self.galleryCollectionView.reloadData()
                    showToast(state:self, message: "Network error")
                }
        }
    }

}

extension GalleryVC : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemCount:[Media] = sectionData[sectionHeaders[section]] ?? []
        return itemCount.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryViewCell", for: indexPath) as? GalleryViewCell else {
            return UICollectionViewCell()
        }
        let key = sectionHeaders[indexPath.section]
        let mediaList:[Media] = sectionData[key] ?? []
        if type.lowercased() == "videos"{
            cell.imgView.kf.setImage(with: URL(string: mediaList[indexPath.row].thumbnail))
        }else{
            cell.imgView.kf.setImage(with: URL(string: mediaList[indexPath.row].url))
        }
        cell.imgView.clipsToBounds = true
        cell.txtTitle.text = mediaList[indexPath.row].title

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if type.lowercased() == "videos"{
            let key = sectionHeaders[indexPath.section]
            let mediaList:[Media] = sectionData[key] ?? []
            let obj:Media = mediaList[indexPath.row]
//            let player = AVPlayer(url: URL(string:obj.url)!)
//            let playerViewController = AVPlayerViewController()
//            playerViewController.player = player
//            present(playerViewController,animated: true){
//                player.play()
//            }
            //Commenting AVPlayer as it only supports local videos
            let svc = SFSafariViewController(url: URL(string: obj.url)!)
            present(svc, animated: true, completion: nil)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let VC =  storyboard.instantiateViewController(withIdentifier: "noticeContentVC") as! NoticeContentVC
            let key = sectionHeaders[indexPath.section]
            let mediaList:[Media] = sectionData[key] ?? []
            let obj:Media = mediaList[indexPath.row]
            VC.noticeTitle = obj.title
            VC.desc = obj.desc
            VC.imageUrl =  obj.url
            VC.title = obj.title
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        let width = self.calculateWith()
        return CGSize(width: CGFloat((collectionView.frame.size.width / 3) - 3), height: 130)
    }
    
    func calculateWith() -> CGFloat {
        let estimateWidth = CGFloat(estimatedWidth)
        var cellCount = floor(CGFloat(self.view.frame.size.width / estimateWidth))
        cellCount = 3
        
        let margin = CGFloat(cellMarginSize * Double(cellCount))
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // 1
        switch kind {
        // 2
        case UICollectionView.elementKindSectionHeader:
            // 3
            guard
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "galleryHeaderView",
                    for: indexPath) as? GalleryHeaderView
                else {
                    fatalError("Invalid view type")
            }
            
            headerView.txtTitle.text = self.sectionHeaders[indexPath.section]
            return headerView
        default:
            // 4
            assert(false, "Invalid element type")
            return UICollectionReusableView()
        }
    }
}
