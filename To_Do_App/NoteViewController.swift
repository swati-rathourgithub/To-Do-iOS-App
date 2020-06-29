//
//  NoteViewController.swift
//  To_Do_App
//
//  Created by user173890 on 6/28/20.
//  Copyright © 2020 user173890. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {
    
    @IBOutlet weak var noteTextView: UITextView!
    var selectedNote: Note? {
        didSet {
            // write code after
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
