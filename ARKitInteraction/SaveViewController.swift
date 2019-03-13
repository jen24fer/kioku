//
//  SaveViewController.swift
//  ARKitInteraction
//
//  Created by Jenny Ferina on 3/12/19.
//  Copyright © 2019 Apple. All rights reserved.
//
import os.log
import UIKit

class SaveViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var memoryPalace: MemoryPalace?
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var mapPhoto: UIImageView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    @IBAction func selectImageFromLibrary(_ sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //createSavedItems()
    }
    
    @IBAction func textFieldText(_ sender: UITextField) {
        
    }
    

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        mapPhoto.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    
    func createSavedItems()
    {
        if (textField.text != nil)
        {
            let memoryPalace = ViewController.palace
            if (textField.text != nil && memoryPalace != nil)
            {
                memoryPalace!.name = textField.text!
                print(memoryPalace!.name)
                memoryPalace?.photo = mapPhoto.image
            }
            
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // This method lets you configure a view controller before it's presented.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        //let name = textField.text ?? ""
        //let photo = mapPhoto.image
        createSavedItems()
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        
    }
}
