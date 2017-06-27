//
//  ViewController.swift
//  NotesApp
//
//  Created by Muskan on 6/20/17.
//  Copyright © 2017 akhil. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CreateNoteDelegate {

    var notesArr = [MyNote]()
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.white
        
        self.title="Notes"
        self.navigationController?.navigationBar.isTranslucent=false
        
        let btnAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(btnAddAction))
        self.navigationItem.rightBarButtonItem = btnAdd
        
        notesArr = retrieveNotes()
        //print(notesArr)
        
        self.view.addSubview(myTableView)
        myTableView.delegate=self
        myTableView.dataSource=self
        myTableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive=true
        myTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive=true
        myTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive=true
        myTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive=true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.selectedIndex=nil
    }
    
    func btnAddAction() {
        let vc=CreateNoteVC()
        vc.delegate=self
        if selectedIndex != nil {
            vc.passedNote=self.notesArr[selectedIndex!].title
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text=notesArr[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex=indexPath.row
        btnAddAction()
    }
    
    //Enable cell editing methods.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let share = UITableViewRowAction(style: .normal, title: "Share") { action, index in
            print("share button tapped")
        }
        share.backgroundColor = UIColor.blue
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("delete button tapped")
            let shareMenu = UIAlertController(title: nil, message: "Are you sure you wanna delete this note?", preferredStyle: .actionSheet)
            let yesAction=UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
                self.deleteNote(withId: self.notesArr[indexPath.row].id)
                self.notesArr.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            shareMenu.addAction(yesAction)
            shareMenu.addAction(cancelAction)
            self.present(shareMenu,animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor.red
        
        return [share, delete]
    }

    let myTableView: UITableView = {
        let table=UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        table.tableFooterView=UIView()
        table.translatesAutoresizingMaskIntoConstraints=false
        return table
    }()
    
    //MARK: create note delegate
    func didCreateNote(note: String) {
        if note == "" {
            return
        }
        self.navigationController?.popViewController(animated: true)
        if selectedIndex != nil {
            notesArr[selectedIndex!].title = note
            editNote(withId: notesArr[selectedIndex!].id, note: note)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyyyyhhmmss"
            let currentDate = Date()
            let convertedDateString = dateFormatter.string(from: currentDate)
            let newNote=MyNote(id: convertedDateString, title: note, detail: "someDetail")
            self.notesArr.append(newNote)
            self.addNote(note: newNote)
        }
        selectedIndex=nil
        self.myTableView.reloadData()
    }
    
    //MARK: coredata
    func addNote(note: MyNote) {
        let context = getContext()
        let newNote = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
        newNote.setValue(note.id, forKey: "id")
        newNote.setValue(note.title, forKey: "title")
        newNote.setValue(note.detail, forKey: "detail")
        
        do {
            try context.save()
        } catch {
            print("Error saving to core data")
        }
    }
    
    func retrieveNotes() -> [MyNote] {
        let request=NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        request.returnsObjectsAsFaults=false
        let context = getContext()
        var notes=[MyNote]()
        do {
            let results = try context.fetch(request)
            if results.count>0 {
                for result in results as! [NSManagedObject] {
                    if let id = result.value(forKey: "id") as? String, let title = result.value(forKey: "title") as? String, let detail = result.value(forKey: "detail") as? String {
                        notes.append(MyNote(id: id, title: title, detail: detail))
                    }
                }
            }
        } catch {
            print("Error retrieving from core data")
        }
        return notes
    }
    
    func editNote(withId id: String, note: String) {
        let context = getContext()
        let predicate = NSPredicate(format: "id == %@", id)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.predicate = predicate
        
        do {
            let fetchedEntities = try context.fetch(fetchRequest) as! [NSManagedObject]
            //print("contact fetchedEntities: \(fetchedEntities)")
            if let result = fetchedEntities.first {
                if let _ = result.value(forKey: "title") as? String, let _ = result.value(forKey: "detail") as? String {
                    result.setValue(note, forKey: "title")
                    //result.setValue("something", forKey: "detail")
                }
            }
        } catch {
            print("error : \(error)")
        }
        
        do {
            try context.save()
            print("updated note in coreData")
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func deleteNote(withId id: String){
        let context = getContext()
        let predicate = NSPredicate(format: "id == %@", id)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.predicate = predicate
        
        do {
            let fetchedEntities = try context.fetch(fetchRequest) as! [NSManagedObject]
            if let entityToDelete = fetchedEntities.first {
                context.delete(entityToDelete)
            } else {
                print("note with id \(id) not found")
            }
        } catch {
            print("error : \(error)")
        }
        
        do {
            try context.save()
            print("deleted note in coreData")
        } catch let error as NSError {
            print("Could not delete note. \(error.userInfo)")
        }
    }
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context=appDelegate.persistentContainer.viewContext
        return context
    }

}


class MyNote: NSObject {
    var id: String
    var title: String
    var detail: String
    
    init(id: String, title: String, detail: String) {
        self.id=id
        self.title=title
        self.detail=detail
    }
    
    override var description: String {
        return "\(id) \(title)"
    }
}














