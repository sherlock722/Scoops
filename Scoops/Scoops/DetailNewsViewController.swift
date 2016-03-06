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
    //var client : MSClient?
    var model : AnyObject?
    
    // MARK: - Properties
    @IBOutlet weak var titleNews: UITextField!
    
    @IBOutlet weak var textNews: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.title = model?.title
        self.title = model!["title"] as? String
        self.titleNews.text = model!["title"] as? String
        self.textNews.text = model!["text"] as? String
        
        
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
