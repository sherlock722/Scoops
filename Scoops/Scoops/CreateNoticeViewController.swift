//
//  CreateNoticeViewController.swift
//  Scoops
//
//  Created by Javier Cazorla Moriche on 4/3/16.
//  Copyright © 2016 FJC. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreLocation

class CreateNoticeViewController: UIViewController {
    
    //Se define el client que se recibe como parametro del NoticeTable......
    var client : MSClient?
    
    
    //Nombre del Blob
    var myBlobName : String?
    
    //Localizacion
    //let locationManager = CLLocationManager()
    var longitude : Double?
    var latitude : Double?
    var location : CLLocation?
    
    
    // MARK: - @IBOutlet
    @IBOutlet weak var titleText: UITextField!
    
    
    @IBOutlet weak var textNews: UITextView!
    
    
    @IBOutlet weak var authorNews: UITextField!
    
    
    @IBOutlet weak var saveInAzure: UIButton!
    
    @IBOutlet weak var imageNews: UIImageView!
    
    
    // MARK: - @IBAction
    @IBAction func saveNews(sender: AnyObject) {
        
        //Mostrar un aviso al usuario cuando no se rellenen datos de la noticia
        if (titleText.text! == "" || textNews.text! == "Text News" || self.imageNews.image == nil){
            
            
           let importAlert = UIAlertController.init(title: "Message", message: "Indicating at least the title, text and image of the news", preferredStyle: UIAlertControllerStyle.Alert)
        
            importAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                print("OK")
                
            }))
        
           presentViewController(importAlert, animated: true, completion: nil)
            
        } else {
        
        
            //Verificamos si el usuario está logado para insertar en la tabla
            if isUserloged() {
            
                // Cargamos los datos del usuario que ya hizo login
                if let usrlogin = loadUserAuthInfo() {
                    client!.currentUser = MSUser(userId: usrlogin.usr)
                    client!.currentUser.mobileServiceAuthenticationToken = usrlogin.tok
                    
                    
                //Usando la propiedad client se accede a la tabla de las noticias para poder insertar
                let tablaVideos = client?.tableWithName("news")
                    
                    //Se asigna nombre al blob
                    self.myBlobName = "photonews-\(NSUUID().UUIDString).png"
        
                    tablaVideos?.insert(["title" : titleText.text!, "text" : textNews.text!, "author" : authorNews.text!, "createnews" : NSDate(), "blob_name" : self.myBlobName!, "status" : "Not Published", "containername" : "photonotice", "latitude" : self.latitude!, "longitude" : self.longitude!], completion: { (inserted, error: NSError?) -> Void in
            
                    if error != nil{
                        print("Error -> : \(error)")
                    } else {
                
                        print ("OK Insert Tabla")
                
                        //Subimos la imagen, convertido en NSData, al storage con el método creado uploadToStorage
                        
                        self.uploadToStorage(UIImagePNGRepresentation (self.imageNews.image!)!, blobName: self.myBlobName!)
                        
                    }
                })
                
                }
                
            } else { //No se está logado
                
                
                //Se fuerza el login
                client!.loginWithProvider("facebook", controller: self, animated: true, completion: { (user: MSUser?, error: NSError?) -> Void in
                    
                    if (error != nil){
                        print("Error: \(error)")
                    }
                    
                    else{
                        
                        // Se persisten las credenciales del usuario
                        //Para saber que ya se ha logado
                        saveAuthInfo(user)
                        
                    }
                    
                })
                
            }
        }
        
    }
    
    // MARK: - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.orangeColor()
        
        
        //Localizacion
        //Se recupera la localizacion
        let locationManager = CLLocationManager()
        //locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        //Valores de longitud y latitud - No me funciona el recuperar coordenadas
        self.longitude=0
        self.latitude=0
        
        /*print ("Localizacion")
        print (self.longitude)
        print (self.latitude)*/
        
        
        //Se prepara el campo texto de la noticia como si tuviera placeholder
        textNews.delegate = self
        textNews.text = "Text News"
        textNews.textColor = UIColor.lightGrayColor()
        
        //Titulo
        self.title = "New"
        
        //boton con la camara para capturar el video
        //Se llama al metodo capturarVideo:
        let plusButton = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "capturarPhoto:")
        self.navigationItem.rightBarButtonItem = plusButton
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: - Guardar en AZURE (Storage)
    func uploadToStorage(data : NSData, blobName : String){
        
        //Se deshabilita el botón
        self.saveInAzure.enabled = false
        
        //Utilizamos el método invokeAPI para llamar a nuestro CustomAPI que hemos creado en AZURE
        client?.invokeAPI("urlsastoblobandcontainer",
            body: nil,
            HTTPMethod: "GET",
            parameters: ["blobName" : myBlobName!, "containerName" : "photonotice"],//ContainerName que existe
            headers: nil,
            completion: { (result : AnyObject?, response : NSHTTPURLResponse?, error: NSError?) -> Void in
                
                //result devuelve un diccionario con la la url que hemos generado para subir un blob
                if error == nil{
                    
                    // Solo es la ruta del container/blob + la SASURL
                    let sasURL = result!["sasUrl"] as? String
                    //print ("sasurl \(sasURL)")
                    
                    //url del endpoint de Storage
                    var endPoint = "https://fjcscoopsstorage.blob.core.windows.net"
                    
                    //URL completa para subir el recurso
                    endPoint += sasURL!
                    
                    //let credentials = AZSStorageCredentials(SASToken: sasURL!)
                    //print ("endpoint \(endPoint)")
                    
                    
                    //Obtenemos la referencia del container de Azure Storage
                    let container = AZSCloudBlobContainer(url: NSURL(string: endPoint)!)
                    
                    //let container = AZSCloudBlobContainer(url: NSURL(string: "https://fjcscoopsstorage.blob.core.windows.net/photonotice")!, credentials: credentials)
                    
                    
                    // Tengo que subir a partir de nuestro blob local
                    let blobLocal = container.blockBlobReferenceFromName(blobName)
                    
                    
                    //Los métodos de AZS trabajan en segundo plano
                    //En data va la imagen a guardar
                    blobLocal.uploadFromData(data,
                        completionHandler: { (error: NSError?) -> Void in
                            
                            if error == nil {
                                
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    
                                    //desactivar el boton que graba en azure
                                    self.saveInAzure.enabled = false
                                    print ("OK Insert Storage")
                                    
                                })
                            } else {
                                print("Error -> \(error)")
                                self.saveInAzure.enabled = false
                            }
                            
                    })
                    
                }
                
        })
        
    }
    
    
    // MARK: - Navigation
    func capturarPhoto (sender : AnyObject){
        
        startCapturePhotoBlogFromViewController(self, withDelegate: self)
        
    }
    
    
    func startCapturePhotoBlogFromViewController (viewcontroller: UIViewController, withDelegate delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) -> Bool{
        
        
        let pickerController = UIImagePickerController()
        
        //Se accede al carrete
        pickerController.sourceType = .PhotoLibrary
        pickerController.allowsEditing = false
        pickerController.delegate = delegate
        
        presentViewController(pickerController, animated: true, completion: nil)
        
        return true
    
    }

}


extension CreateNoticeViewController : UITextViewDelegate{
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if textNews.textColor == UIColor.lightGrayColor() {
            textNews.text = ""
            textNews.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if textNews.text == "" {
            
            textNews.text = "Text News"
            textNews.textColor = UIColor.lightGrayColor()
        }
    }
    
    
}

//Navigation
extension CreateNoticeViewController: UINavigationControllerDelegate{
    
}

//Picker
extension CreateNoticeViewController: UIImagePickerControllerDelegate{
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        
        let mediaType = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //Asignar mediaType a la imageView
        
        self.imageNews.image = mediaType
        
        dismissViewControllerAnimated(true, completion :nil)
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        // Cerrar seleccion de imágenes  al pulsar  cancelar
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

extension CreateNoticeViewController: CLLocationManagerDelegate{
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        //self.longitude = coord.longitude
        //self.latitude = coord.latitude
        self.longitude = 0
        self.latitude = 0
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Error while updating location " + error.localizedDescription)
        //Longitud y Latitud
        self.longitude = 0
        self.latitude = 0
        
    }
    
    
    
}

