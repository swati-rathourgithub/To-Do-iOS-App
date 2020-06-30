//
//  MoveToViewController.swift
//  To_Do_App
//
//  Created by user173890 on 6/28/20.
//  Copyright © 2020 user173890. All rights reserved.
//
import UIKit
import CoreData

class MoveToViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegate: NoteTableViewController?
    var folders = [Folder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFolder()
        // Do any additional setup after loading the view.
    }

    @IBAction func cancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func loadFolder() {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        
        do {
            folders = try context.fetch(request)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")
        if cell == nil
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "categoryCell")
        }
        let folder = folders[indexPath.row]
        cell?.textLabel?.text = folder.name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.moveTo(to: folders[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
}

