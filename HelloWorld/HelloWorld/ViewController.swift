//
//  ViewController.swift
//  HelloWorld
//
//  Created by 朱力 on 2017/8/9.
//  Copyright © 2017年 朱力. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class ViewController: UIViewController {

    //var data: [SnippetData] = [SnippetData]()
    var data = [NSManagedObject]()
    let imagePicker = UIImagePickerController()
    let locationManager = CLLocationManager()
    @IBOutlet weak var tableView: UITableView!
    var currentCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50.0
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        askForLocationPermissions()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadSnippetData()
        tableView.reloadData()
    }
    
    func reloadSnippetData() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = delegate.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Snippet")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [ sortDescriptor ]
        do{
            let fetchResults = try managedContext.fetch(request)
            self.data = fetchResults as! [NSManagedObject]
        }catch{
            let e = error as NSError
            print("Unresolved error \(e), \(e.userInfo)")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createNewSnippet(_ sender: Any) {
        let alert = UIAlertController(title: "Select a snippet type", message: nil, preferredStyle: .actionSheet)
        let textAction = UIAlertAction(title: "Text", style: .default){
            (alert: UIAlertAction!) -> Void in
            self.createNewTextSnippet()
            //self.data.append(SnippetData(snippetType: .text))
        }
        
        let photoAction = UIAlertAction(title: "Photo", style: .default){
            (alert: UIAlertAction!) -> Void in
            self.createNewPhotoSnippet()
            //self.data.append(SnippetData(snippetType: .photo))
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(textAction)
        alert.addAction(photoAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func createNewTextSnippet(){
        guard let textEntryVC = storyboard?.instantiateViewController(withIdentifier: "textSnippetEntry") as? TextSnippetEntryViewController else {
            print("TextSnippetEntryViewContoller could not be instantiated from storyboard")
            return
        }
        textEntryVC.modalTransitionStyle = .coverVertical
        textEntryVC.saveText = {(text:String) in
            //let newTextSnippet = TextData(text: text, creationDate: NSDate() as Date, creationCoordinate: self.currentCoordinate)
            //self.data.append(newTextSnippet)
            self.saveTextSnippet(text: text)
        }
        present(textEntryVC,animated: true,completion: nil)
    }
    func createNewPhotoSnippet(){
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else{
            print("Camera is not available")
            return
        }
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        present(imagePicker,animated: true,completion: nil)
    }
    func saveTextSnippet(text: String){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = delegate.managedObjectContext
        let desc = NSEntityDescription.entity(forEntityName: "TextSnippet", in: managedContext)
        let textSnippet = NSManagedObject(entity: desc!, insertInto: managedContext)
        textSnippet.setValue(SnippetType.text.rawValue, forKey: "type")
        textSnippet.setValue(text, forKey: "text")
        textSnippet.setValue(NSDate(), forKey: "date")
        if let coord = self.currentCoordinate {
            textSnippet.setValue(coord.latitude, forKey: "latitude")
            textSnippet.setValue(coord.longitude, forKey: "longitude")
        }
        delegate.saveContext()
    }
 
    func savePhotoSnippet(photo: UIImage){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = delegate.managedObjectContext
        let desc = NSEntityDescription.entity(forEntityName: "PhotoSnippet", in: managedContext)
        let photoSnippet = NSManagedObject(entity: desc!, insertInto: managedContext)
        let photoData = UIImagePNGRepresentation(photo)
        
        photoSnippet.setValue(SnippetType.photo.rawValue, forKey: "type")
        photoSnippet.setValue(photoData, forKey: "photo")
        photoSnippet.setValue(NSDate(), forKey: "date")
        if let coord = self.currentCoordinate {
            photoSnippet.setValue(coord.latitude, forKey: "latitude")
            photoSnippet.setValue(coord.longitude, forKey: "longitude")
        }
        delegate.saveContext()
    }
    
    func askForLocationPermissions(){
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [String : Any]){
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else{
            print("Image could not be found")
            return
        }
        //let newPhotoSnippet = PhotoData(photo: image, creationDate: Date(), creationCoordinate: self.currentCoordinate)
        //self.data.append(newPhotoSnippet)
        savePhotoSnippet(photo: image)
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell: UITableViewCell
        //let sortedData = data.reversed() as [SnippetData]
        //let snippetData = sortedData[indexPath.row]
        let snippetData = data[indexPath.row]
        let snippetDate = snippetData.value(forKey: "date") as! Date
        let snippetType = SnippetType(rawValue: snippetData.value(forKey: "type") as! String)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //let dateString = formatter.string(from: snippetData.date)
        let dateString = formatter.string(from: snippetDate)
        
        switch snippetType {
        case .text:
            //cell = tableView.dequeueReusableCell(withIdentifier: "textSnippetCell", for: indexPath)
            //(cell as! TextSnippetCell).label.text = (snippetData as! TextData).textData
            let snippetText = snippetData.value(forKey: "text") as! String
            cell = tableView.dequeueReusableCell(withIdentifier: "textSnippetCell", for: indexPath) as! TextSnippetCell
            (cell as! TextSnippetCell).label.text = snippetText
            (cell as! TextSnippetCell).date.text = dateString
        case .photo:
            let snippetPhoto = UIImage(data: snippetData.value(forKey: "photo") as! Data)
            cell = tableView.dequeueReusableCell(withIdentifier: "photoSnippetCell", for: indexPath)
            //(cell as! PhotoSnippetCell).photo.image = (snippetData as! PhotoData).photoData
            (cell as! PhotoSnippetCell).photo.image = snippetPhoto
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = delegate.managedObjectContext
        let currentObject = data[indexPath.row]
        managedContext.delete(currentObject)
        delegate.saveContext()
        reloadSnippetData()
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
    }
    
}

extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager could not get location. Error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            currentCoordinate = currentLocation.coordinate
            print("\(currentCoordinate!.latitude),\(currentCoordinate!.longitude)")
        }
    }
}

