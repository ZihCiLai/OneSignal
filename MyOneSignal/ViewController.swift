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
    var users = ["e48dd5af-77c9-4231-83bb-5a4f20098195"]
    var currentEdit: selectEdit?
    var sentOneSignal: SentOneSignal!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        sentText.delegate = self
        
        OneSignal.getTags({ tags in
            print("tags:", tags ?? "nil")
        }, onFailure: { error in
            print("Error")
        })
        
//        requestWithJSONBody(urlString: "https://onesignal.com/api/v1/notifications") { (data) in
//            DispatchQueue.main.async {
//                self.processData(data: data)
//            }
//        }
    }
    
    func processData(data: Data) {
        if let fetchedDictionary = data.parseData() {
            print("Data:", fetchedDictionary.description)
        } else {
            print("Data=nil")
        }
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
            sentOneSignal = SentOneSignal(users: users, sentMSG: sentMSG, sentTitle: sentTitle, sentSubtitle: sentSubtitle)
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
