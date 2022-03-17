//
//  PhotoViewController.swift
//  UsingCoreData
//
//  Created by Ahmed Saeed on 3/15/22.
//  Copyright © 2022 Ahmed Saeed. All rights reserved.
//

import UIKit
import CoreData

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var saveImage: UIImageView!
    @IBOutlet weak var fetchImage: UIImageView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //for select photo
    @IBAction func openGallaryOnClick(_ sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        dismiss(animated: true, completion: nil)
        guard let imagePickerView = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{ return }
        saveImage.image = imagePickerView
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    //save photo to CoreData
    @IBAction func saveImageOnClick(_ sender: UIButton) {
        guard let imageData = saveImage.image?.jpegData(compressionQuality: 0.5) else { return }
        let photo = PersonImage(context: context)
        photo.image = imageData
        do{
            try context.save()
            print("save photo is success")
        }catch{
            print("error when save image\(error.localizedDescription)")
        }
    }
    //get photos from CoreData
    @IBAction func fetchImageOnClick(_ sender: UIButton) {
        let arr = try! self.context.fetch(PersonImage.fetchRequest()) as! [PersonImage]
        fetchImage.image = UIImage(data: arr[0].image!)
    }
}
