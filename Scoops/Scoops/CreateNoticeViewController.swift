//
//  CreateNoticeViewController.swift
//  Scoops
//
//  Created by Javier Cazorla Moriche on 4/3/16.
//  Copyright © 2016 FJC. All rights reserved.
//

import UIKit

class CreateNoticeViewController: UIViewController {
    
    //Se define el client
    var client : MSClient?
    
    
    // MARK: - @IBOutlet
    @IBOutlet weak var titleText: UITextField!
    
    
    // MARK: - @IBAction
    @IBAction func saveNews(sender: AnyObject) {
        
        
        //Usando la propiedad client accedemos a la tabla de los videos para poder insertar
        let tablaVideos = client?.tableWithName("news")
        
        
        tablaVideos?.insert(["title" : titleText.text!], completion: { (inserted, error: NSError?) -> Void in
            
            if error != nil{
                print("Tenemos un error -> : \(error)")
            } else {
                
                // 2: Persistir el blob en el Storage
                print("Primera parte superada (Ya tenemos el registro en la BBDD, ahora toca blob")
                
                //Subimos el blob al storage con el método creado uploadToStorage
                //self.uploadToStorage(self.bufferVideo!, blobName: self.myBlobName!)
            }
        })
        //Fin insert
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        //Titulo
        self.title = "New News"
        
        //boton con la camara para capturar el video
        //Se llama al metodo capturarVideo:
        let plusButton = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "capturarPhoto:")
        self.navigationItem.rightBarButtonItem = plusButton
        
        //Se viewController será el delegado del titleText: UITextField! para controlar la longitud de
        //la cadena ver extension del método implmentado
        titleText.delegate = self
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CreateNoticeViewController: UITextFieldDelegate{
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        
        /*let currentString = textField.text! as NSString
        
        if (currentString.length > 10) {
            validatorLabel.text = "Este titulo mola"
            validatorLabel.textColor = UIColor.greenColor()
            saveInAzureButton.enabled = true
        }*/
        
        
        return true
    }
}
