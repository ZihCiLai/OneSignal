//
//  OneSignal.swift
//  MyOneSignal
//
//  Created by Lai Zih Ci on 2017/6/20.
//  Copyright © 2017年 ZihCi. All rights reserved.
//

import UIKit
import OneSignal

class SentOneSignal: NSObject {
    private var users = [""]
    private var sentMSG = ""
    private var sentTitle = ""
    private var sentSubtitle = ""
    
    init(users: [String], sentMSG: String, sentTitle: String, sentSubtitle: String) {
        super.init()
        self.users = users
        self.sentMSG = sentMSG
        self.sentTitle = sentTitle
        self.sentSubtitle = sentSubtitle
        self.sentMessage()
    }
    
    // MARK: OneSignal
    
    func requestWithJSONBody(urlString: String, completion: @escaping (Data) -> Void){
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        let parameters: [String: Any] = [
            "app_id": "d24c5012-f415-425f-935c-0a647108db48",
            "include_player_ids": users,
            "data": ["foo": "bar"],
            "contents": ["en": "Message"]
        ]
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
        }catch let error{
            print(error)
        }
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic ", forHTTPHeaderField: "Authorization")
        
        fetchedDataByDataTask(from: request, completion: completion)
    }
    
    private func fetchedDataByDataTask(from request: URLRequest, completion: @escaping (Data) -> Void) {
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil{
                print(error as Any)
            }else{
                guard let data = data else{return}
                completion(data)
            }
        }
        task.resume()
    }
    
    func sentMessage() {
        let jj: [String: Any] = [
            // Add user id
            "include_player_ids": users,
            "contents": ["en": sentMSG],
            "headings": ["en": sentTitle],
            "subtitle": ["en": sentSubtitle],
            // If want to open a url with in-app browser
            //"url": "https://google.com",
            // If you want to deep link and pass a URL to your webview, use "data" parameter and use the key in the AppDelegate's notificationOpenedBlock
            "data": ["OpenURL": "https://www.google.com"],
            //"ios_attachments": ["id" : "https://cdn.pixabay.com/photo/2017/01/16/15/17/hot-air-balloons-1984308_1280.jpg"],
            "ios_badgeType": "Increase",
            "ios_badgeCount": 1
        ]
        
        OneSignal.postNotification(jj, onSuccess: { (hashable) in
            print("hashable:", hashable ?? "nil")
        }) { (error) in
            print("error:", error ?? "nil")
        }
    }
    
    func sentMessage2() {
        let notifiation2Content: [AnyHashable : Any] = [
            // Update the following id to your OneSignal user id.
            "include_player_ids": users,
            
            // Tag substitution: https://documentation.onesignal.com/docs/tag-variable-substitution
            "headings": ["en": "Congrats {{users_name}}!!"],
            
            "contents": ["en": "You finished level {{ finished_level | default: '1' }}! Let's see if you can do more."],
            
            // Action Buttons: https://documentation.onesignal.com/reference#section-action-buttons
            "buttons": [["id": "id1", "text": "WebView"], ["id": "id2", "text": "Second"]]
        ]
        OneSignal.postNotification(notifiation2Content, onSuccess: { result in
            print("result = \(result!)")
        }, onFailure: {error in
            print("error = \(error!)")
        })
    }
}
