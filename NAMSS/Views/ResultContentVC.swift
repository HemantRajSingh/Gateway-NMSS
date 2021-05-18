//
//  ResultContentVC.swift
//  MMIHS
//
//  Created by Frost on 4/13/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON

class ResultContentVC: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var examTitle = String()
    var examId = String()
    var totalMarks = 0.00,totalObtainedMarks = 0.00, percent = 0.00
    @IBOutlet weak var txtSchoolName: UILabel!
    @IBOutlet weak var txtSchoolAddress: UILabel!
    var type = String()
    var finalGrade = ""
    var apiResponse : [Result] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.scrollView.bounces = false;
        txtSchoolName.text = schoolName
        txtSchoolAddress.text = schoolAddress
        showProgressBar(state: self, activityIndicator: activityIndicator)
//        loadAndDisplayResult(url:appUrl + "GetResultOfExam?userid=\(Common.shared.userId)&examid=\(examId)")
        if(type == "result"){
//            let showStyle = UIBarButtonItem(title: "View in Mark", style: .plain, target: self, action: #selector(self.showMarksheet(sender:)))
//            self.navigationItem.rightBarButtonItem = showStyle
            loadAndDisplayExamResult(url:appUrl + "GetResultOfExam?userid=\(Common.shared.userId)&examid=\(examId)")
        } else {
            self.title = "Exam Routine"
            loadExamRoutine(url:appUrl + "GetExamRoutine?userid=\(Common.shared.userId)&examid=\(examId)")
        }
    }
    
    @objc func showMarksheet(sender:UIBarButtonItem){
        var html = ""
        if(self.navigationItem.rightBarButtonItem?.title == "View in Mark"){
            self.navigationItem.rightBarButtonItem?.title = "View in Grade"
            html = self.showMarkView(res: apiResponse)
        } else {
            self.navigationItem.rightBarButtonItem?.title = "View in Mark"
            html = self.showGradeView(res: apiResponse)
        }
        
        if let path = Bundle.main.path(forResource: "bootstrap.min", ofType: "css"){
            html = String(format: html, path, self.examTitle)
            html = html.replacingOccurrences(of: "\n", with: "")
            print(html)
            let baseUrl = URL(fileURLWithPath: path)
            self.webView.loadHTMLString(html, baseURL: baseUrl)
            hideProgressBar(activityIndicator: self.activityIndicator)
        }
    }
    
    func loadAndDisplayExamResult(url:String){
        loadData(url: url, completionHandler: {(status,res) -> Void in
            if(status == true){
                if(res.count > 0){
                    self.apiResponse = res
                    var html = ""
                    if let path = Bundle.main.path(forResource: "bootstrap.min", ofType: "css"){
                        html = self.showGradeView(res: res)
//                        if(self.navigationItem.rightBarButtonItem?.title == "View in Grade"){
//                            html = self.showMarkView(res: res)
//                        } else {
//                            html = self.showGradeView(res: res)
//                        }
                        html = String(format: html, path, self.examTitle)
                        html = html.replacingOccurrences(of: "\n", with: "")
                        print(html)
                        let baseUrl = URL(fileURLWithPath: path)
                        self.webView.loadHTMLString(html, baseURL: baseUrl)
                        hideProgressBar(activityIndicator: self.activityIndicator)
                    }
                }else{
                    var html = "<html><head><link rel='stylesheet' type='text/css' href='%@'></head><body><label>No Data found!</label></body></html>"
                    let path = Bundle.main.path(forResource: "styles", ofType: "css")
                    html = String(format: html, path!)
                    html = html.replacingOccurrences(of: "\n", with: "")
                    self.webView.loadHTMLString(html, baseURL: URL(fileURLWithPath: path!))
                    showToast(state:self, message: "No data found")
                    hideProgressBar(activityIndicator: self.activityIndicator)
                }
            }else{
                showToast(state:self, message: "Something error")
                hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    func loadData(url:String, completionHandler:@escaping (Bool,[Result]) -> Void){
        var dataList = [Result]()
        fnGetApi(url: url, completionHandler: {(res,json)->Void in
            if(res == true){
                let resultArray = json["result"].array
                self.finalGrade = json["cgpa"].stringValue
                for (index,subJson):(String, JSON) in JSON(resultArray) {
                    let gpaGrade = subJson["gpaGrademark"]
                    let examDetail = gpaGrade["examDetail"]
                    dataList.append(Result(subject: subJson["subject"].stringValue, fullMarkTheory: subJson["fullMarkTheroy"].stringValue, fullMarkPractical: subJson["fullMarkPractical"].stringValue, obtainedMark: subJson["obtainedMark"].stringValue, obtainedTheoryMark: subJson["obtainedTheoryMark"].stringValue, obtainedPracticalMark: subJson["obtainedPracticalMark"].stringValue, highestMark: subJson["highestMark"].stringValue, highestTheoryMark: subJson["highestTheoryMark"].stringValue, highestPracticalMark: subJson["highestPracticalMark"].stringValue, rank: subJson["rank"].stringValue, gpa: gpaGrade["GPA"].stringValue, grade: gpaGrade["Grading"].stringValue))
                    let fullMarkTheory = subJson["fullMarkTheroy"].stringValue
                    let fullMarkPractival = subJson["fullMarkPractical"].stringValue
                    let obtainedMark = subJson["obtainedMark"].stringValue
                    if(fullMarkTheory != "" && fullMarkPractival != ""){
                        self.totalMarks = self.totalMarks + Double(fullMarkTheory)! + Double(fullMarkPractival)!
                    }
                    if(obtainedMark != ""){
                        self.totalObtainedMarks = Double(self.totalObtainedMarks) + Double(obtainedMark)!
                    }
                    
                }
                completionHandler(true,dataList)
                
            }else{
                completionHandler(false,dataList)
            }
        })
    }
    
    func showGradeView(res:[Result]) -> String{
        
                    var html = """
                        <html>
                        <head>
                        <link rel='stylesheet' type='text/css' href='%@'>
                            <style>
                                thead th{
                                    text-align: center;
                                }
                                thead td,thead th{
                                    font-size: 28px !important;
                                    text-align : left;
                                    vertical-align: top !important;
                                    border-bottom: 1px solid #ddd;
                                    padding: 0.3em !important;
                                }
                                table{
                                    padding : 0 5% !important;
                                }
                                tbody td{
                                    font-size : 28px;
                                }
                                .title{
                                    text-align:center;
                                    font-size : 37px;
                                    display : block;
                                    font-weight : bold;
                                }
                            </style>
                        </head>
                        <body>
                        <table class="table table-striped" style="margin-top: 20px;">
                            <thead>
                                <tr>
                                    <label class="title">%@</label>
                                </tr>
                                <tr>
                                    <th rowspan="2">#</th>
                                    <th rowspan="2">Subject</th>
                                    <th rowspan="2">Obtained Grade</th>
                                    <th rowspan="2">Grade Point</th>
                                    <th rowspan="2">Rank</th>
                                </tr>
                        </thead>
                        <tbody>
                        """;
                    var i = 1;
                            for items in res{
                                let subject = items.subject
                                let obtainedGrade = items.grade
                                let gpa = items.gpa
                                let rank = items.rank
                                html += "<tr class='subject'>";
                                html += "<td class='id'>"+String(i)+"</td>";
                                html += "<td class='nsubject'>"+subject+"</td>";
                                //Grade and GPA
                                html += "<td class='obtainedGrade'>"+obtainedGrade+"</td>";
                                html += "<td class='gpa'>"+gpa+"</td>";
                                //rank
                                html += "<td class='singlemark'>"+rank+"</td>";
                                html += "</tr>";
                                i += 1
                            }
                    html += "</tbody></table>"
                    html += "<h2 style='margin-top:20px;margin-bottom:40px;'>CGPA: " + finalGrade + "</h3>"
//                    html += """
//                            <table class="table table-striped" style="margin-top: 20px;">
//                                <thead>
//                                    <tr>
//                                        <label class="title">Grading System</label>
//                                    </tr>
//                                    <tr>
//                                        <th rowspan="2">Interval</th>
//                                        <th rowspan="2">Grade Point</th>
//                                        <th rowspan="2">Grade</th>
//                                        <th rowspan="2">Remarks</th>
//                                    </tr>
//                            </thead>
//                            <tbody>
//                                    <tr>
//                                        <td>90%% - 100%%</td>
//                                        <td>3.60 - 4.00</td>
//                                        <td>A+</td>
//                                        <td>Outstanding</td>
//                                    </tr>
//                                    <tr>
//                                        <td>75%% - 89.99%%</td>
//                                        <td>3.00 - 3.59</td>
//                                        <td>A</td>
//                                        <td>Excellent</td>
//                                    </tr>
//                                    <tr>
//                                        <td>60%% - 74.99%%</td>
//                                        <td>2.40 - 2.99</td>
//                                        <td>B+</td>
//                                        <td>Very Good</td>
//                                    </tr>
//                                    <tr>
//                                        <td>50%% - 59.99%%</td>
//                                        <td>2.00 - 2.39</td>
//                                        <td>B</td>
//                                        <td>Good</td>
//                                    </tr>
//                                    <tr>
//                                        <td>40%% - 49.99%%</td>
//                                        <td>1.60 - 1.99</td>
//                                        <td>C</td>
//                                        <td>Acceptable</td>
//                                    </tr>
//                            </tbody></table>
//                </body>
//            </html>
//        """;
        return html
    }
    
    func showMarkView(res:[Result]) -> String{
        
                    var html = """
                        <html>
                        <head>
                        <link rel='stylesheet' type='text/css' href='%@'>
                            <style>
                                thead th{
                                    text-align: center;
                                }
                                thead td,thead th{
                                    font-size: 28px !important;
                                    text-align : left;
                                    vertical-align: top !important;
                                    border-bottom: 1px solid #ddd;
                                    padding: 0.3em !important;
                                }
                                table{
                                    padding : 0 5% !important;
                                }
                                tbody td{
                                    font-size : 28px;
                                }
                                .title{
                                    text-align:center;
                                    font-size : 37px;
                                    display : block;
                                    font-weight : bold;
                                }
                            </style>
                        </head>
                        <body>
                        <table class="table table-striped" style="margin-top: 15px;">
                            <thead>
                                <tr>
                                    <label class="title">%@</label>
                                </tr>
                                <tr>
                                    <th rowspan="2">#</th>
                                    <th rowspan="2">Subject</th>
                                    <th colspan="2" style="text-align:center;">Full Mark</th>
                                    <th colspan="2" style="text-align:center;">Obtained Mark</th>
                                    <th rowspan="2">Total</th>
                                    <th rowspan="2" style="text-align:center;">Highest Mark</th>
                                    <th rowspan="2">Rank</th>
                                </tr>
                                <tr>
                                    <th>Theory</th>
                                    <th>Practical</th>
                                    <th>Theory</th>
                                    <th>Practical</th>
                                </tr>
                        </thead>
                        <tbody>
                        """;
                    var i = 1;
                            for items in res{
                                let subject = items.subject
                                let fullMarkTheory = items.fullMarkTheory
                                let fullMarkPractical = items.fullMarkPractical
                                let obtainedMark = items.obtainedMark
                                let obtainedTheoryMark = items.obtainedTheoryMark
                                let obtainedPracticalMark = items.obtainedPracticalMark
                                let highestTheoryMark = items.highestTheoryMark
                                let highestPracticalMark = items.highestPracticalMark
                                let totalhighest = Int(highestTheoryMark)! + Int(highestPracticalMark)!
                                let rank = items.rank
                                html += "<tr class='subject'>";
                                html += "<td class='id'>"+String(i)+"</td>";
                                html += "<td class='nsubject'>"+subject+"</td>";
                                //FM
                                html += "<td class='fmtheory'>"+fullMarkTheory+"</td>";
                                html += "<td class='fmpractical'>"+fullMarkPractical+"</td>";
                                //OM
                                html += "<td class='otm'>"+obtainedTheoryMark+"</td>";
                                html += "<td class='opm'>"+obtainedPracticalMark+"</td>";
                                
                                html += "<td class='singlemark'>"+obtainedMark+"</td>";
                                html += "<td class='singlemark' style='text-align:center;'>"+String(totalhighest)+"</td>";
                                html += "<td class='singlemark'>"+rank+"</td>";
                                html += "</tr>";
                                i += 1
                            }
                    html += "</tbody></table>"
                    html += "<h2 style='margin-top:20px;'>Total Obtained Marks : " + String(self.totalObtainedMarks) + "</h3>"
                    var percent:Double = 0.00
                    percent = self.totalObtainedMarks / self.totalMarks
                    percent = percent * 100
                    let percentText = String(format: "%.2f", percent) + " %"
                    html += "<h2>Percentage : " + percentText + "</h3>"
                        html += """
                    </body>
                    </html>
                    """;
        return html
    }
    
    func loadExamRoutine(url:String){
            fnPostApi(url: url, completionHandler: {(res,json)->Void in
                if(res == true){
                    if let path = Bundle.main.path(forResource: "bootstrap.min", ofType: "css"){
                        var html = "<html><head><title></title><meta charset='utf-8'><meta name='viewport' content='width=device-width, user-scalable=no' /><link rel='stylesheet' href='https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css'><style> body{ font-family: serif; }thead th{ text-align: center; } thead td,thead th{ font-size: 9px !important; text-align : left; vertical-align: top !important; border-bottom: 1px solid #ddd; padding: 0.3em !important; } table{ padding : 0 5% !important; } tbody td{ font-size: 9px; } .title{ text-align:center; font-size : 37px; display : block; font-weight : bold; }.totalm{font-size:12px; text-align: right; padding-right: 15px; } .examname{text-align:center; margin: 10px auto; font-size: 19px; font-weight: bold; } .schedule{text-align:center; margin: 10px auto; font-size: 19px; font-weight: bold; } .collegeaddr{ text-align:center; font-size: 18.5px; margin-bottom: 0px; } .collegeestd{ text-align:center; font-size: 14px; margin-bottom: 0px} .collegename{ font-size:20px; text-align:center; margin-top: 10px; margin-bottom: 0px; } .totallabel { font-weight: bold; } .admitcard { max-width: 125px; font-weight: bold; margin: auto; background-color: #000; color: #fff; padding: 2px 8px; } .ml18{ margin-left: 8px; } .examrountine th{ font-size: 14px !important; vertical-align: middle !important; } .examrountine tbody{ padding: 20px; }.examrountine th:first-child{ padding: 0px 0px 0px 25px !important; width: 40%; }.rountinemeta tr td:first-child{ padding: 8px 24px !important; width: 40%; }.rountinemeta tr td{ font-size: 14px; padding: 8px; }@media(max-width: 640px){ .userinfo p{ margin-bottom: 5px; } .rountinemeta tr td:first-child { padding: 10px !important;} } </style></head><body><div class='container-fluid'><h6 class='schedule'>Examination Schedule</h6><div class='table-responsive-sm'>  <table class='table'><thead><tr class='examrountine'><th class='thexam' style='width:87px;'>Date</th><th class='thexam'>Subject</th><th class='thexam'>Start Time</th><th class='thexam'>End Time</th></tr></thead><tbody class='rountinemeta'>";
                        let routineResult = json["routineResult"].arrayValue
                        for subJson in routineResult {
    //                        var examId =  subJson["ExamTypeId"].stringValue
    //                        var subjectId =  subJson["SubjectId"].stringValue
                            let subjectName =  subJson["SubjectName"].stringValue
                            let examDate =  subJson["ExamDate"].stringValue
                            let startTime = subJson["StartTime"].stringValue
                            let endTime = subJson["EndTime"].stringValue
    //                        var startTime =  subJson["StartTime"].stringValue ?? "00:00"
    //                        var endTime =  subJson["EndTime"].stringValue ?? "00:00"
                            html += "<tr>";
                            html += "<td>" + examDate + "</td>";
                            html += "<td>" + subjectName + "</td>";
                            html += "<td>" + startTime + "</td>";
                            html += "<td>" + endTime + "</td>";
                            html += "</tr>";
                        }
                        html += "</tbody>";
                        html += "</table>";
                        html += "</div>";
                        html += "</div>";
                        html += "</body>";
                        html += "</html>";
                        
                        html = String(format: html, path, self.examTitle)
                        html = html.replacingOccurrences(of: "\n", with: "")
                        print(html)
                        let baseUrl = URL(fileURLWithPath: path)
                        self.webView.loadHTMLString(html, baseURL: baseUrl)
                        hideProgressBar(activityIndicator: self.activityIndicator)
                    } else {
                        var html = "<html><head><link rel='stylesheet' type='text/css' href='%@'></head><body><label>No Data found!</label></body></html>"
                        let path = Bundle.main.path(forResource: "styles", ofType: "css")
                        html = String(format: html, path!)
                        html = html.replacingOccurrences(of: "\n", with: "")
                        self.webView.loadHTMLString(html, baseURL: URL(fileURLWithPath: path!))
                        showToast(state:self, message: "No data found")
                        hideProgressBar(activityIndicator: self.activityIndicator)
                    }
                }else{
                    showToast(state:self, message: "Some error Occurred.")
                    hideProgressBar(activityIndicator: self.activityIndicator)
                }
            })
        }

}
