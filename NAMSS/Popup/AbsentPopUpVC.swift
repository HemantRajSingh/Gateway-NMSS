//
//  AbsentPopUpVC.swift
//  MMIHS
//
//  Created by Frost on 5/26/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit

class AbsentPopUpVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var list = [NewStudentLog]()
    var list1 = [String]()
    @IBOutlet weak var tblAbsent: UITableView!
    @IBOutlet weak var txtTitle: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        if list1.count > 0 {
//            txtTitle.text = "Device Logs"
//        }
        tblAbsent.tableFooterView = UIView()
        tblAbsent.reloadData()
    }
    
    
    @IBAction func btnDone(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(list.count > 0){
            return list.count
        }else{
            return list1.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "absentViewCell", for: indexPath) as? AbsentViewCell else{
            return UITableViewCell()
        }
        if list.count > 0 {
            let obj:NewStudentLog = list[indexPath.row]
            cell.txtName.text = obj.name
            cell.txtPhone.text = obj.mobile
        }else{
            let obj:String = list1[indexPath.row]
            cell.textLabel?.text = obj
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
}
