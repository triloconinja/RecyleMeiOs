//
//  Settings.swift
//  RecyleMe
//
//  Created by Manuel Henry Villacruz II on 23/12/15.
//  Copyright © 2015 Thinking Cap. All rights reserved.
//

import Foundation

class Settings {
    
    static let itemPerCollectionView = 6
    static let blobImageUrl = "https://recyclemeblob.blob.core.windows.net/images/"
                            
    static let parseAppId = "lSGDQL3a7UZQj1BL5v2bUvSqNaS8fy9N8HL36exp"
    static let parseClientKey = "IhpEe0gnXL6ZUl8oNaqG4CiYkKX2gXxsg3aPStZi"
    
    static let twitterConsumerKey = ""
    static let twitterConsumerSecret = ""
    
    
    static let latestImagesURL = "http://recyclemeapi.azurewebsites.net/odata/Item/?$filter=IsDeleted%20eq%20false%20and%20Status%20ne%201&$orderby=ModifiedDate%20desc&$expand=ItemImages,Owner,ItemCommented,ItemCommented/Commenter,ItemUserFollowers"
    
    static let api:String = "http://recyclemeapi.azurewebsites.net/odata/"
    
}

