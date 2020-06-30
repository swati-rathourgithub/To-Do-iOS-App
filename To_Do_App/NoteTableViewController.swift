//
//  NoteTableViewController.swift
//  To_Do_App
//
//  Created by user173890 on 6/28/20.
//  Copyright © 2020 user173890. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class NoteTableViewController: UITableViewController {
    
    @IBOutlet weak var trashBtn: UIBarButtonItem!
    @IBOutlet weak var moveToBtn: UIBarButtonItem!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    var notes = [Note]()
    var selectedFolder: Folder? {
        didSet {
            loadNotes()
        }
    }
    
    var selectedNote: Note?
    
    // create a context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSearchBar()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func loadNotes(with request: NSFetchRequest<Note> = Note.fetchRequest(), predicate: NSCompoundPredicate? = nil) {
    //        let request: NSFetchRequest<Note> = Note.fetchRequest()
            let folderPredicate = NSPredicate(format: "parentFolder.name=%@", selectedFolder!.name!)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            if let addtionalPredicate = predicate {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [folderPredicate, addtionalPredicate])
            } else {
                request.predicate = folderPredicate
            }
            
            do {
                notes = try context.fetch(request)
            } catch {
                print("Error loading notes \(error.localizedDescription)")
            }
            
            tableView.reloadData()
        }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "noteCell")
        if cell == nil
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "noteCell")
        }
        let note = notes[indexPath.row]
        cell?.textLabel?.text = note.title
        setCellColor(due: note.due, cell: cell!)
        return cell!
    }
    
    func setCellColor(due: Date?, cell: UITableViewCell)
    {
        if let date = due
        {
            if date <= Date()
            {
                cell.backgroundColor = .red
            }
            else if Calendar.current.isDate(Date().addingTimeInterval(24*60*60), equalTo: date, toGranularity: .day)
            {
                cell.backgroundColor = .green
            }
            else
            {
                cell.backgroundColor = .white
            }
        }
        else
        {
            cell.backgroundColor = .white
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing
        {
            selectedNote = notes[indexPath.row]
            performSegue(withIdentifier: "addNote", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addDate = UIContextualAction(style: .normal, title: "add day") { (action, view, completion) in
            self.notes[indexPath.row].due = self.notes[indexPath.row].due?.addingTimeInterval(24*60*60)
            self.save()
            self.setCellColor(due: self.notes[indexPath.row].due, cell: tableView.cellForRow(at: indexPath)!)
            completion(true)
        }
        addDate.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        return UISwipeActionsConfiguration(actions: [addDate])
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let nvc = segue.destination as? NoteViewController
        {
            nvc.delegate = self
            nvc.selectedNote = selectedNote
        }
        if let mtvc = segue.destination as? MoveToViewController
        {
            mtvc.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedNote = nil
    }
    
    func createNote(title: String, message: String?, due: Date?, remindme: Bool)
    {
        let note = Note(context: context)
        note.title = title
        note.desc = message
        note.due = due
        note.remindme = remindme
        note.created = Date()
        note.parentFolder = selectedFolder
        notes.append(note)
        save()
        if let date = due, remindme
        {
            addNotification(title: title, description: message, date: date)
        }
        tableView.reloadData()
    }
    
    func addNotification(title: String, description: String?, date: Date)
    {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = "Note Due Tomrrow"
        if let desc = description
        {
            content.body = desc
        }
        else
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            content.body = formatter.string(from: date)
        }
        let imageName = "applelogo"
        guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else {return }
        let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
        content.attachments = [attachment]
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date.addingTimeInterval(-24*60*60))
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    @IBAction func EditClicked(_ sender: Any) {
        if tableView.isEditing
        {
            editButton.title = "Edit"
            moveToBtn.isEnabled = false
            trashBtn.isEnabled = false
            tableView.setEditing(false, animated: true)
        }
        else
        {
            tableView.setEditing(true, animated: true)
            editButton.title = "Done"
            moveToBtn.isEnabled = true
            trashBtn.isEnabled = true
        }
    }
    func noteCompleted()
    {
        notes.removeAll { (note) -> Bool in
            return note == selectedNote
        }
        selectedNote?.parentFolder = FolderTableViewController.archivedFolder
        save()
        tableView.reloadData()
    }
    
    func updateNote()
    {
        save()
        tableView.reloadData()
    }
    
    func save()
    {
        do
        {
            try context.save()
        }
        catch
        {
            print(error)
        }
    }
    
    @IBAction func trashClicked(_ sender: Any) {
        if let indexpaths = tableView.indexPathsForSelectedRows
        {
            for indexpath in indexpaths.reversed()
            {
                let note = notes.remove(at: indexpath.row)
                context.delete(note)
            }
            tableView.reloadData()
        }
    }
    
    func moveTo(to folder: Folder)
    {
        if let indexpaths = tableView.indexPathsForSelectedRows
        {
            for indexpath in indexpaths.reversed()
            {
                let note = notes.remove(at: indexpath.row)
                note.parentFolder = folder
            }
            save()
            tableView.reloadData()
        }
    }
    
    func showSearchBar() {
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Folder"
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.searchBar.searchTextField.textColor = .white
    }
    
    
}

extension NoteTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //        let request : NSFetchRequest<Note> = Note.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        let predicate1 = NSPredicate(format: "desc CONTAINS[cd] %@", searchBar.text!)
        //        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        //        loadNotes(with: request, predicate: predicate)
        loadNotes(predicate: NSCompoundPredicate(orPredicateWithSubpredicates: [predicate,predicate1]))
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadNotes()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadNotes()
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
}
