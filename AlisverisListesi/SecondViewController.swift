//
//  SecondViewController.swift
//  AlisverisListesi
//
//  Created by Emir on 27.10.2022.
//

import UIKit
import CoreData

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    var selectedProductName: String?
    var selectedProductUUID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedProductName != nil {
            
            saveButton.isHidden = true
            //Core Data seçilen ürün bilgilerini göster.
            if let uuidString = selectedProductUUID?.uuidString {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0 {
                        for result in results as! [NSManagedObject] {
                            
                            if let imageData = result.value(forKey: "image") as? Data {
                                let image = UIImage(data: imageData)
                                imageView.image = image
                            }
                            
                            if let name = result.value(forKey: "name") as? String {
                                nameTextField.text = name
                            }
                            
                            if let price = result.value(forKey: "price") as? Int {
                                priceTextField.text = String(price)
                            }
                            
                            if let size = result.value(forKey: "size") as? String {
                                sizeTextField.text = size
                            }
                        }
                    }
                } catch {
                    print("Hata var!")
                }
            }
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameTextField.text = nil
            priceTextField.text = nil
            sizeTextField.text = nil
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardClose))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        view.addGestureRecognizer(imageGestureRecognizer)
    }
    
    @objc func keyboardClose(){
        view.endEditing(true)
    }
    
    @objc func chooseImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        let shopping = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context!)
        
        shopping.setValue(nameTextField.text, forKey: "name")
        shopping.setValue(sizeTextField.text, forKey: "size")
        
        if let price = Int(priceTextField.text!) {
            shopping.setValue(price, forKey: "price")
        }
        
        //Universal Unique ID
        shopping.setValue(UUID(), forKey: "id")
        
        let image = imageView.image!.jpegData(compressionQuality: 0.5)
            shopping.setValue(image, forKey: "image")
        
        do {
            try context?.save()
            print("Kayıt edildi!")
        } catch {
            print("Hata var!")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("enteredData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
