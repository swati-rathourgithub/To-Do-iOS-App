//
//  NoteViewController.swift
//  To_Do_App
//
//  Created by user173890 on 6/28/20.
//  Copyright © 2020 user173890. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var remindMeSwitch: UISwitch!
    @IBOutlet weak var dueDateDatePicker: UIDatePicker!
    var selectedNote: Note?
    var delegate: NoteTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedNote != nil
        {
            titleTextField.text = selectedNote?.title
            messageTextField.text = selectedNote?.desc
            remindMeSwitch.isOn = selectedNote!.remindme
            if let date = selectedNote?.due
            {
                dueDateDatePicker.date = date
            }
        }
        // Do any additional setup after loading the view.
    }
    

    @IBAction func saveClicked(_ sender: Any) {
        if let title = titleTextField.text
        {
            let desc = messageTextField.text
            let remindme = remindMeSwitch.isOn
            let due = dueDateDatePicker.date
            if selectedNote == nil
            {
                delegate?.createNote(title: title, message: desc, due: due, remindme: remindme)
            }
            else
            {
                selectedNote?.title = title
                selectedNote?.desc = desc
                selectedNote?.remindme = remindme
                selectedNote?.due = due
                delegate?.updateNote()
            }
            navigationController?.popViewController(animated: true)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func completedClicked(_ sender: Any) {
        delegate?.noteCompleted()
        navigationController?.popViewController(animated: true)
    }
    
}
