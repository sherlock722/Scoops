//
//  NoticeTableViewController.swift
//  Scoops
//
//  Created by Javier Cazorla Moriche on 4/3/16.
//  Copyright © 2016 FJC. All rights reserved.
//

import UIKit

class NoticeTableViewController: UITableViewController {
    
    
    //Configurar el MSClient. Los datos se sacan de la consola de azure del servicio MBaaS creado
    let client = MSClient (applicationURL: NSURL(string: "https://fjcscoops.azure-mobile.net/"), applicationKey: "AuKAmzYsYjoMMdArOSxIcfrxwFnfBc34")
    
    var model : [AnyObject]?

    @IBAction func refreshTable(sender: AnyObject) {
        
        //Actualizar el modelo y la vista...
        self.populateModel()
        //self.tableView.reloadData()
        
        
        //Terminar el refresh
        sender.endRefreshing()
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.title = "News"
        let plusButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNews:")
        self.navigationItem.rightBarButtonItem = plusButton
        
        //Recuperar los datos de las noticias
        populateModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var rows = 0
        if model != nil {
            rows = (model?.count)!
        }
        return rows
    }
    
    
    // MARK: - Utils
    
    
    func populateModel (){
        
        
        
        //Representa la tabla de los videos
        let noticeTable = client?.tableWithName("news")
        
        
        //Obtener datos via MSQuery
        
        //Se necesita una tabla
        let query = MSQuery(table: noticeTable)
        
        // Incluir predicados, constrains para filtrar, para limitar el numero de filas o delimitar el numero de columnas
        
        //Ordenar por titulo
        query.orderByAscending("title")
        
        
        query.readWithCompletion { (result:MSQueryResult?, error:NSError?) -> Void in
            if error == nil {
                //Bloque
                self.model = result?.items //Array de resultados
                self.tableView.reloadData()
            }
        }
        
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("news", forIndexPath: indexPath)

        //Sincronización vista y modelo
        cell.textLabel?.text = model![indexPath.row]["title"] as? String

        return cell
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("detailNews", sender:indexPath)
    }

    

    //Añadir una nueva Noticia
    func addNews(sender : AnyObject){
        //Lanzamos el segur para ir de un controlador a otro
        //El nombre de la escena es addNewItem
        performSegueWithIdentifier("addNews", sender: sender)
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //Referencia al controlador destino y se le pasa el NSClient creado desde esta clase
        guard let identifier = segue.identifier else{
            print("no tenemos identifier")
            return
        }
        
        switch identifier{
        case "addNews":
            let vc = segue.destinationViewController as! CreateNoticeViewController
            // desde aqui podemos pasar alguna property
            vc.client = client
            break
        case "detailNews":
            let index = sender as? NSIndexPath
            let vc = segue.destinationViewController as! CreateNoticeViewController //Cambiar la clase
            vc.client = client
            //vc.record = model![(index?.row)!]
            break
        default: break
            
        }
        
        
        
    }
    

}
