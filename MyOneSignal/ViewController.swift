//
//  ViewController.swift
//  MyOneSignal
//
//  Created by Lai Zih Ci on 2017/5/29.
//  Copyright © 2017年 ZihCi. All rights reserved.
//

import UIKit
import OneSignal

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sentText: UITextField!
    @IBOutlet weak var information: UITextView!
    
    var sentTitle = ""
    var sentSubtitle = ""
    var sentMSG = ""
    var currentEdit: selectEdit?
    
    func processData(data: Data) {
        if let fetchedDictionary = data.parseData() {
            print("Data:", fetchedDictionary.description)
        } else {
            print("Data=nil")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        sentText.delegate = self
//        OneSignal.sendTag("one", value: "theOne", onSuccess: { (hashable) in
//            print("hashable:", hashable ?? "nil")
//        }) { (error) in
//            print("error:", error ?? "nil")
//        }
        
        OneSignal.getTags({ tags in
            print("tags:", tags ?? "nil")
        }, onFailure: { error in
            print("Error")
        })
        
//        requestWithJSONBody(urlString: "https://onesignal.com/api/v1/notifications", parameters: js) { (data) in
//            DispatchQueue.main.async {
//                self.processData(data: data)
//            }
//        }
    }
    
    // MARK: TextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let edit = currentEdit {
            switch edit {
            case .title:
                sentTitle = sentText.text! + string
            case .sub:
                sentSubtitle = sentText.text! + string
            default:
                sentMSG = sentText.text! + string
            }
        }
        return true
    }
    
    
    // MARK: OneSignal
    let jso: [String: Any] = ["app_id": "d24c5012-f415-425f-935c-0a647108db48",
                             "included_segments": ["All"],
                             "data": ["foo": "bar"],
                             "contents": ["en": "Test Message"]
    ]
    
    let js: [String: Any] = [
        "app_id": "d24c5012-f415-425f-935c-0a647108db48",
        "include_player_ids": ["1b422e11-39e4-4b9d-83ab-d430a9944aa8"],
        "data": ["foo": "bar"],
        "contents": ["en": "Message"]
    ]
    
    func requestWithJSONBody(urlString: String, parameters: [String: Any], completion: @escaping (Data) -> Void){
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
        }catch let error{
            print(error)
        }
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic YjZlNDU4MTItYWFjMy00MDNiLWI3NjAtZDM5ZTEzODlmZWM1", forHTTPHeaderField: "Authorization")
        
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
            "include_player_ids": ["e48dd5af-77c9-4231-83bb-5a4f20098195"],
            "contents": ["en": sentMSG],
            "headings": ["en": sentTitle],
            "subtitle": ["en": sentSubtitle],
            // If want to open a url with in-app browser
            //"url": "https://google.com",
            // If you want to deep link and pass a URL to your webview, use "data" parameter and use the key in the AppDelegate's notificationOpenedBlock
            //"data": ["OpenURL": "https://imgur.com"],
            "ios_attachments": ["id" : "https://cdn.pixabay.com/photo/2017/01/16/15/17/hot-air-balloons-1984308_1280.jpg"],
            "ios_badgeType": "Increase",
            "ios_badgeCount": 1
        ]
        // "e48dd5af-77c9-4231-83bb-5a4f20098194"
        OneSignal.postNotification(jj, onSuccess: { (hashable) in
            print("hashable:", hashable ?? "nil")
        }) { (error) in
            print("error:", error ?? "nil")
        }
    }
    
    func sentMessage2() {
        let notifiation2Content: [AnyHashable : Any] = [
            // Update the following id to your OneSignal plyaer / user id.
            "include_player_ids": ["e48dd5af-77c9-4231-83bb-5a4f20098195"],
            // Tag substitution: https://documentation.onesignal.com/docs/tag-variable-substitution
            "headings": ["en": "Congrats {{users_name}}!!"],
            "contents": ["en": "You finished level {{ finished_level | default: '1' }}! Let's see if you can do more."],
            // Action Buttons: https://documentation.onesignal.com/reference#section-action-buttons
            "buttons": [["id": "id1", "text": "GREEN"], ["id": "id2", "text": "RED"]]
        ]
        OneSignal.postNotification(notifiation2Content, onSuccess: { result in
            print("result = \(result!)")
        }, onFailure: {error in
            print("error = \(error!)")
        })
    }
    
    /// Notification status information
    func status() {
        var inf = ""
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        
        let hasPrompted = status.permissionStatus.hasPrompted.description
        let userStatus = status.permissionStatus.status
        let isSubscribed = status.subscriptionStatus.subscribed.description
        let userSubscriptionSetting = status.subscriptionStatus.userSubscriptionSetting.description
        let userID = status.subscriptionStatus.userId
        let pushToken = status.subscriptionStatus.pushToken
        
        inf = "hasPrompted:\(hasPrompted)\n"
        inf += "userStatus:\(userStatus)\n"
        inf += "isSubscribed:\(isSubscribed)\n"
        inf += "userSubscriptionSetting:\(userSubscriptionSetting)\n"
        inf += "userID:\(userID ?? "nil")\n"
        inf += "pushToken:\(pushToken ?? "nil")\n"
        
        information.text = inf
    }
    
    // MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = ""
        switch indexPath.row {
        case 0:
            cell.detailTextLabel?.text = "Title Text"
        case 1:
            cell.detailTextLabel?.text = "SubTitle Text"
        case 2:
            cell.detailTextLabel?.text = "Message Text"
        case 3:
            cell.detailTextLabel?.text = "Sent Notification"
        case 4:
            cell.detailTextLabel?.text = "Status"
        default:
            cell.detailTextLabel?.text = "Text"
        }
        if indexPath.row == 3 {
            cell.detailTextLabel?.backgroundColor = UIColor.cyan
        } else {
            cell.detailTextLabel?.backgroundColor = UIColor.clear
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        print("Row:", indexPath.row)
        switch indexPath.row {
        case 0:
            sentText.text = sentTitle
            currentEdit = .title
        case 1:
            sentText.text = sentSubtitle
            currentEdit = .sub
        case 2:
            sentText.text = sentMSG
            currentEdit = .message
        case 3:
            sentMessage()
        case 4:
            status()
        default:
            break
        }
    }
    
    enum selectEdit {
        case title
        case sub
        case message
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension Data{
    func parseData() -> NSDictionary? {
        
        guard let dataDict = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers) as! NSDictionary else {
            return nil
        }
        
        return dataDict
    }
    
    mutating func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
