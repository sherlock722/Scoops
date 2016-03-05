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
    
    //Modelo
    var model : [AnyObject]?

    
    //Para refresecar la Tabla
    @IBAction func refreshTable(sender: AnyObject) {
        
        //Actualizar el modelo y la vista...
        self.populateModel()
        
        
        //Terminar el refresh
        sender.endRefreshing()
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.view.backgroundColor = UIColor.orangeColor()
        
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
        
        
        //Se obtiene con client la tabla de las noticias
        let noticeTable = client?.tableWithName("news")
        
        
        //Obtener datos via MSQuery
        
        //Se recuperea la tabla de noticias una tabla
        let query = MSQuery(table: noticeTable)
        
        //Ordenar por título
        query.orderByAscending("title")
        
        
        query.readWithCompletion { (result:MSQueryResult?, error:NSError?) -> Void in
            if error == nil {
                //Bloque
                self.model = result?.items //Array de resultados
                self.tableView.reloadData()
            }
        }
        
    }
    
    //MARK - Sincronizar Modelo y Vista
    
    //Se recupera la información del modelo y se pinta en la vista
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("news", forIndexPath: indexPath)

        //Sincronización vista y modelo
        //cell.backgroundColor = UIColor.greenColor()
        //cell.textLabel?.backgroundColor = UIColor.redColor()
        cell.textLabel?.text = model![indexPath.row]["title"] as? String
        //cell.detailTextLabel?.text = model![indexPath.row]["createnews"] as? String

        return cell
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("detailNews", sender:indexPath)
    }

    

    //Añadir una nueva Noticia
    func addNews(sender : AnyObject){
        //Lanzamos el segur para ir de un controlador a otro
        performSegueWithIdentifier("addNews", sender: sender)
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //Referencia al controlador destino y se le pasa el NSClient creado desde esta clase
        guard let identifier = segue.identifier else{
            print("No Identifier")
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
            let vc = segue.destinationViewController as! DetailNewsViewController
            //Se pasa como parametro el client y el registro del modelo que se ha selsccionado.
            //vc.client = client
            vc.model = model![(index?.row)!]
            break
        default: break
            
        }
        
        
        
    }
    

}
