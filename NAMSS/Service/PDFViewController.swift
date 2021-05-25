//
//  PDFViewController.swift
//  NAMSS
//
//  Created by ITH on 25/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {
    
    private let pdfView = PDFView()
    private let thumbnailView = PDFThumbnailView()
    private let pdfURL: URL!
    private let outline: PDFOutline?
    private let document:  PDFDocument!
    
    init(pdfUrl: URL) {
        self.pdfURL = pdfUrl
        self.document = PDFDocument(url: pdfUrl)
        self.outline = document.outlineRoot
        pdfView.document = document
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPDFView()
        setUpThumbnailView()

//        view.addSubview(pdfView)
        
//        if let document = PDFDocument(url: pdfURL) {
//            pdfView.document = document
//        }
    }
    
    override func viewDidLayoutSubviews() {
        pdfView.frame = view.frame
    }
    
    private func setupPDFView() {
        view.addSubview(pdfView)
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true, withViewOptions: nil)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
    }
    
    private func setUpThumbnailView() {
        thumbnailView.pdfView = pdfView
        thumbnailView.backgroundColor = UIColor(displayP3Red: 179/255, green: 179/255, blue: 179/255, alpha: 0.5)
        thumbnailView.layoutMode = .horizontal
        thumbnailView.thumbnailSize = CGSize(width: 80, height: 100)
        thumbnailView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        view.addSubview(thumbnailView)
    }
}
