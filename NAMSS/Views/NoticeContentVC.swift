//
//  NoticeContentVC.swift
//  MMIHS
//
//  Created by Frost on 4/22/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class NoticeContentVC: UIViewController {
    
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var imgNotice: UIImageView!
    @IBOutlet weak var txtDesc: UITextView!
    var noticeTitle="",desc="",imageUrl = ""
    var imageData = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Detail"
        txtTitle.text = noticeTitle
        txtDesc.text = desc
        if imageUrl == "" {
            imgNotice.isHidden = true
            imgNotice.heightAnchor.constraint(equalToConstant: CGFloat(0)).isActive = true
        } else {
            imgNotice.kf.setImage(with: URL(string: imageUrl))
        } /* else{
            let split = imageUrl.split(separator: ",")
            if split.count > 1 {
                let image64Data = NSData(base64Encoded: String(split[1]))
                imageData = UIImage(data: image64Data! as Data)!
            }
            imgNotice.image = imageData
        } */
        
       let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(sender:)))
        imgNotice.isUserInteractionEnabled = true
        imgNotice.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc func imageTapped(sender: UITapGestureRecognizer)
    {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(Common.shared.userId == ""){
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
}
