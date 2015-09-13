import Foundation
import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var DefectItems = [DefectItem]()
    
    @IBOutlet weak var logTableView: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DefectItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DefectCell") as! UITableViewCell
        let defectItem = DefectItems[indexPath.row]
        cell.textLabel?.text = defectItem.type + defectItem.adress
        return cell
    }
    
    //func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //    let defectItem = DefectItems[indexPath.row]
    //    println(defectItem.type)
    //}
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            // Find the LogItem object the user is trying to delete
            let logItemToDelete = DefectItems[indexPath.row]
            
            // Delete it from the managedObjectContext
            managedObjectContext?.deleteObject(logItemToDelete)
            
            // Refresh the table view to indicate that it's deleted
            self.fetchLog()
            
            // Tell the table view to animate out that row
            logTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "DefectCell")
        
        // This tells the table view that it should get it's data from this class, ViewController
        logTableView.dataSource = self
        logTableView.delegate = self
        
        fetchLog()
    }
    
    func saveNewItem(title : String) {
        // Create the new  log item
        var newLogItem = DefectItem.createInManagedObjectContext(self.managedObjectContext!, type: title, adress: "Проспект", image: NSData(), latitude: 35.123, longitude: 55.1123432)
        
        // Update the array containing the table view row data
        self.fetchLog()
        
        // Animate in the new row
        // Use Swift's find() function to figure out the index of the newLogItem
        // after it's been added and sorted in our logItems array
        if let newItemIndex = find(DefectItems, newLogItem) {
            // Create an NSIndexPath from the newItemIndex
            let newLogItemIndexPath = NSIndexPath(forRow: newItemIndex, inSection: 0)
            // Animate in the insertion of this row
            logTableView.insertRowsAtIndexPaths([ newLogItemIndexPath ], withRowAnimation: .Automatic)
        }
    }
    
    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "DefectItem")
        
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "type", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [DefectItem] {
            DefectItems = fetchResults
        }
    }
    
    
}

