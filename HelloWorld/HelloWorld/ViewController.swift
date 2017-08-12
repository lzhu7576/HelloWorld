//
//  ViewController.swift
//  HelloWorld
//
//  Created by 朱力 on 2017/8/9.
//  Copyright © 2017年 朱力. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var data: [SnippetData] = [SnippetData]()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
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
            let newTextSnippet = TextData(text: text)
            self.data.append(newTextSnippet)
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
}

extension ViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [String : Any]){
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else{
            print("Image could not be found")
            return
        }
        let newPhotoSnippet = PhotoData(photo: image)
        self.data.append(newPhotoSnippet)
        dismiss(animated: true, completion: nil)
    }
}

