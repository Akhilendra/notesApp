//
//  CreateNoteVC.swift
//  NotesApp
//
//  Created by Muskan on 6/20/17.
//  Copyright © 2017 akhil. All rights reserved.
//

import UIKit

protocol CreateNoteDelegate: class {
    func didCreateNote(note: String)
}

class CreateNoteVC: UIViewController {

    var passedNote: String?
    
    weak var delegate: CreateNoteDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title="Create Note"
        
        self.txtView.text=passedNote
        
        let btnDone=UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(btnDoneAction))
        self.navigationItem.rightBarButtonItem=btnDone
        
        self.view.addSubview(txtView)
        txtView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive=true
        txtView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive=true
        txtView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive=true
        txtView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive=true
    }

    func btnDoneAction() {
        delegate?.didCreateNote(note: self.txtView.text!)
    }
    
    let txtView: UITextView = {
        let txt=UITextView()
        //txt.contentInset = UIEdgeInsetsMake(12, 12, -12, -12)
        txt.font=UIFont.systemFont(ofSize: 18)
        txt.textContainerInset=UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        txt.translatesAutoresizingMaskIntoConstraints=false
        return txt
    }()
}
