//
//  ViewController.swift
//  UsingCoreData
//
//  Created by Ahmed Saeed on 3/15/22.
//  Copyright © 2022 Ahmed Saeed. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var persons = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        fetchData()
    }
    //get all data from database(coreData)
    func fetchData(){
        do{
            self.persons = try self.context.fetch(Person.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }catch{
            print("Error in fetchData function: ", error.localizedDescription)
        }
    }
    //add new item in database(coreData)
    @IBAction func addNewDataOnClick(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New item", message: "", preferredStyle: .alert)
        alert.addTextField { (txt) in txt.placeholder = "name"}
        alert.addTextField { (txt) in txt.placeholder = "age"}
        alert.addTextField { (txt) in txt.placeholder = "gender"}
        
        let addButton = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let name = alert.textFields?[0].text, !name.isEmpty, let age = alert.textFields?[1].text, !age.isEmpty, let gender = alert.textFields?[2].text, !gender.isEmpty else{return}
            
            //1- craete new person in coreData
           self.tableView.beginUpdates()
            let person = Person(context: self.context)
            person.name = name
            person.age = Int64(age) ?? 0
            person.gender = gender
            self.tableView.endUpdates()
            self.tableView.reloadData()
            //2- save change
            do{
                try self.context.save()
            }catch{
                print("Error in addNewItemOnClick function: ", error.localizedDescription)
            }
            //3- reload data in tableView
            self.fetchData()
            self.tableView.reloadData()
        }
        alert.addAction(addButton)
        tableView.reloadData()
        self.present(alert, animated: true, completion: nil)
        
    }
    //delete all data from database(coreData)
    @IBAction func deleteAllDataOnClick(_ sender: UIBarButtonItem) {
        do{
            //1- fetch all data
            
            let results = try self.context.fetch(Person.fetchRequest())
            for res in results{
                //2- delete
                self.context.delete(res as! NSManagedObject)
            }
        }catch{
            print("Error in deleteAllDataOnClick function: ", error.localizedDescription)
        }
        do{
            //3- save change
            try self.context.save()
        }catch{
            print(error.localizedDescription)
        }
        //4- realod data in tableView
        self.fetchData()
    }
    //for upload and retrive image from database
    @IBAction func goToPhotosPageOnClick(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoViewController")
        navigationController?.pushViewController(storyboard, animated: true)
    }
}
extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.Name?.text = persons[indexPath.row].name
        cell.Age?.text = persons[indexPath.row].gender
        return cell
    }
}
//tableView with delegate
extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //delete selected person
        let delete = UIContextualAction(style: .destructive, title: "delete") { (_, _, _) in
            //1- select person for delete
            let personSelected = self.persons[indexPath.row]
            //2- delete
            self.context.delete(personSelected)
            do{
                //3- save change
                try self.context.save()
                
            }catch{
                print("Error when delete item: ", error.localizedDescription)
            }
            //reload data in tableView
            self.fetchData()
        }
        //edit selected item
        let edit = UIContextualAction(style: .normal, title: "edit") { (_, _, _) in
            let alert = UIAlertController(title: "Add New item", message: "", preferredStyle: .alert)
            alert.addTextField { (txt) in txt.placeholder = "name"}
            alert.addTextField { (txt) in txt.placeholder = "age"}
            alert.addTextField { (txt) in txt.placeholder = "gender"}
            //1- selected item for edit
            let personSelected = self.persons[indexPath.row]
            alert.textFields?[0].text = personSelected.name
            alert.textFields?[1].text = String(personSelected.age)
            alert.textFields?[2].text = personSelected.gender
            
            let editButton = UIAlertAction(title: "edit", style: .default) { (_) in
                //2- make edit
                personSelected.name = alert.textFields?[0].text
                personSelected.age = Int64((alert.textFields?[1].text)!)!
                personSelected.gender = alert.textFields?[2].text
                do{
                    //3- save change
                    try self.context.save()
                }catch{
                    print("Error when edit item: ", error.localizedDescription)
                }
                //4- reload data in tableView
                self.fetchData()
            }
            alert.addAction(editButton)
            self.present(alert, animated: true, completion: nil)
        }
        return UISwipeActionsConfiguration(actions: [delete,edit])
    }
}

