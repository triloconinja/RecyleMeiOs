//
//  Odata.swift
//  RecyleMe
//
//  Created by MAYBANK on 24/12/15.
//  Copyright © 2015 Thinking Cap. All rights reserved.
//

import Foundation

class Odata {

    static func get(uri:String) -> NSDictionary{
        
        var jsonData:NSDictionary =  NSDictionary()
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: uri as String)!
        
        let dataTask = session.dataTaskWithURL(url) { (data,response, error) -> Void in
            
            do
            {
                 jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
              

            }
            catch
            {
                print("Error: \(error)")
            }
        }
        
        dataTask.resume()
        return jsonData
    }
    
    
    static func post(params : NSMutableDictionary, urlString : String) {
        
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlString )!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"

        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        } catch {
            //handle error. Probably return or mark function as throws
            print(error)
            return
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            // handle error
            guard error == nil else { return }
            
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            
            let json: NSDictionary?
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
            } catch let dataError {
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                print(dataError)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                // return or throw?
                return
            }
            
            
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            if let parseJSON = json {
                // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                let success = parseJSON["success"] as? Int
                print("Succes: \(success)")
            }
            else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: \(jsonStr)")
            }
            
        })
        
        task.resume()
    }
    
}
