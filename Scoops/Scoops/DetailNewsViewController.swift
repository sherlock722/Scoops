//
//  DetailNewsViewController.swift
//  Scoops
//
//  Created by Javier Cazorla Moriche on 5/3/16.
//  Copyright © 2016 FJC. All rights reserved.
//

import UIKit

class DetailNewsViewController: UIViewController {
    
    //Se define el client que se recibe como parametro del NoticeTable......
    var client : MSClient?
    var model : AnyObject?
    
    // MARK: - Properties
    @IBOutlet weak var titleNews: UITextField!
    
    @IBOutlet weak var textNews: UITextView!
    
    
    @IBOutlet weak var loadImageNews: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.view.backgroundColor = UIColor.orangeColor()

        // Do any additional setup after loading the view.
        //self.title = model?.title
        self.title = model!["title"] as? String
        //self.titleNews.text = model!["title"] as? String
        self.textNews.text = model!["text"] as? String
        loadBlobFromAzure()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadBlobFromAzure(){
        
        //Sacar del modelo el nombre del blob y el contenedor
        
        let blobName = model!["blob_name"] as! String
        let containerName = model!["containername"] as! String
        
        
        print (blobName)
        print (containerName)
        
        //Invocar API
        
        /*client?.invokeAPI("urlsastoblobandcontainer",
            body: nil,
            HTTPMethod: "GET",
            parameters: ["blobName" : blobName, "containerName" : containerName],
            headers: nil,
            completion: { (result : AnyObject?, response : NSHTTPURLResponse?, error: NSError?) -> Void in
        */
                
        client?.invokeAPI("v2",
                    body: nil,
                    HTTPMethod: "GET",
                    parameters: ["blobName" : blobName, "containerName" : "photonotice"],//ContainerName que existe
                    headers: nil,
                    completion: { (result : AnyObject?, response : NSHTTPURLResponse?, error: NSError?) -> Void in
                        
                
        
                if error == nil{
                    
                    //Tenemos solo la ruta del container/blob + la SASURL
                    let sasURL = result!["sasUrl"] as? String
                    
                    //url del endpoint de Storage
                    var endPoint = "https://fjcscoopsstorage.blob.core.windows.net"
                    
                    endPoint += sasURL!
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        
                        self.loadImageNews.loadRequest(NSURLRequest(URL: NSURL(string: endPoint)!))
                        
                        print ("OK")
                    })
                    
                }
                
        })
        
        
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
