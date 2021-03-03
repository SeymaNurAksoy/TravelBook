//
//  ViewController1.swift
//  TravelBook
//
//  Created by Şeyma Nur on 2.03.2021.
//

import UIKit
import CoreData

class ViewController1: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var selectId = UUID()
    var selectTitle = ""
    var idArray = [UUID]()
    var titleArray = [String]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        getData()

    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("new"), object: nil)
    }
    
    @objc func addButtonClicked(){
        selectTitle = ""
        performSegue(withIdentifier: "toSecondVC", sender: nil)
    }
    //pin özelleştirmek

    @objc func getData(){
        
        idArray.removeAll(keepingCapacity: false)
        titleArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Travel")
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let title = result.value(forKey:"title" ) as? String{
                        titleArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        idArray.append(id)
                    }
                    //tableview güncelleme işlemi
                    self.tableView.reloadData()
                }
            }
            }catch
            {
                print("error!")
            }
            
        }
           
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectTitle = titleArray[indexPath.row]
        selectId = idArray[indexPath.row]
        performSegue(withIdentifier: "toSecondVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSecondVC" {
            let destinationVC = segue.destination as! ViewController
            destinationVC.chosenTitle = selectTitle
            destinationVC.chosenId = selectId
        }
    }
    

}
