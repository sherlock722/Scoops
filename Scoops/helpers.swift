//
//  helpers.swift
//


import Foundation


//let kEndpointMobileService = "https://myvideoblogjuanamn.azure-mobile.net/"
//let kAppKeyMobileService = "XObHPCejvWSJAqJRHJshIiZSMLpaVA37"
//let kEndpointAzureStorage = "https://videoblogapp.blob.core.windows.net"

let kEndpointMobileService = "https://fjcscoops.azure-mobile.net/"
let kAppKeyMobileService = "AuKAmzYsYjoMMdArOSxIcfrxwFnfBc34"
let kEndpointAzureStorage = "https://fjcscoopsstorage.blob.core.windows.net/"


//Recibe un MSUser y persistimos en local la informacion del usuario (userId y el token)
func saveAuthInfo (currentUser : MSUser?){
    
    NSUserDefaults.standardUserDefaults().setObject(currentUser?.userId, forKey: "userId") //Identificador de usuario de la red social
    NSUserDefaults.standardUserDefaults().setObject(currentUser?.mobileServiceAuthenticationToken, forKey: "tokenId")
    
}

//Metodo que devuelva los datos de user_id y token que están persistido en local
func loadUserAuthInfo() -> (usr : String, tok : String)? {
    
    let user = NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String
    let token = NSUserDefaults.standardUserDefaults().objectForKey("tokenId") as? String
    
    return (user!, token!)
}

func isUserloged() -> Bool {
    
    var result = false
    
    //Si el user_id está persistido significa que el usuario ya está logueado
    let userID = NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String
    
    if let _ = userID {
        result = true
    }
    
    return result
    
}


