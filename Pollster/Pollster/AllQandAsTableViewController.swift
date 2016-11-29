//
//  AllQandAsTableViewController.swift
//  Pollster
//
//  Created by Simen Gangstad on 29.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit
import CloudKit

class AllQandAsTableViewController: UITableViewController {

    var allQandAs = [CKRecord]() { didSet { tableView.reloadData() }}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchAllQandAs()
        iCloudSubscribeToQandAs()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        iCloudUnsubscribeToQandAs()
    }
    
    private let database = CKContainer.default().publicCloudDatabase
    
    private func fetchAllQandAs() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: Cloud.Entity.QandA, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: Cloud.Attribute.Question, ascending: true)]
        database.perform(query, inZoneWith: nil) { (records, error) in
        
            if records != nil {
                
                DispatchQueue.main.async {
                    self.allQandAs = records!
                }
            }
        }
    }
    
    private let subscriptionID = "All QandA creations and deletions"
    private var cloudKitObserver: NSObjectProtocol?
    
    private func iCloudSubscribeToQandAs() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let subscription = CKQuerySubscription(recordType: Cloud.Entity.QandA,
                                               predicate: predicate,
                                               subscriptionID: self.subscriptionID,
                                               options: [.firesOnRecordCreation, .firesOnRecordDeletion])
        
        database.save(subscription) { (savedSubscription, error) in
            if let ckError = error as? CKError {
                switch ckError.code {
                case CKError.Code.serverRejectedRequest: break
                    // Rejects if the subscription is already in the server
                default: break
                }
            }
        }
        
        cloudKitObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: CloudKitNotifications.NotificationReceived),
                                                                  object: nil,
                                                                  queue: OperationQueue.main,
                                                                  using: {notification in
                                                                    if let ckqn = notification.userInfo?[CloudKitNotifications.NotificationKey] as? CKQueryNotification {
                                                                        self.iCloudHandleSubscriptionNotification(ckqn: ckqn)
                                                                    }
        })
    }
    
    private func iCloudHandleSubscriptionNotification(ckqn: CKQueryNotification) {
        if ckqn.subscriptionID == self.subscriptionID {
            if let recordID = ckqn.recordID {
                switch ckqn.queryNotificationReason {
                case .recordCreated:
                    database.fetch(withRecordID: recordID) { (record, error) in
                        if record != nil {
                            DispatchQueue.main.async {
                                self.allQandAs = (self.allQandAs + [record!]).sorted {
                                    return $0.question < $1.question
                                }
                            }
                        }
                    }
                case .recordDeleted:
                    DispatchQueue.main.async {
                        self.allQandAs = self.allQandAs.filter {$0.recordID != recordID}
                    }
                default:
                    break
                }
            }
        }
    }
    
    private func iCloudUnsubscribeToQandAs() {
        database.delete(withSubscriptionID: self.subscriptionID) { (removedSubscription, error) in
            if let _ = error as? CKError {
                // Handle error
            }
        }
        
        NotificationCenter.default.removeObserver(cloudKitObserver as Any)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allQandAs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QandACell")
        cell!.textLabel?.text = allQandAs[indexPath.row].question
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return allQandAs[indexPath.row].wasCreatedByThisUser
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let record = allQandAs[indexPath.row]
            
            database.delete(withRecordID: record.recordID) {(deletedRecord, error) in
            
                // Handle errors
            }
            
            allQandAs.remove(at: indexPath.row)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show QandA" {
            if let ckQandATVC = segue.destination as? CloudQandATableViewController {
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    ckQandATVC.ckQandARecord = allQandAs[indexPath.row]
                }
                else {
                    ckQandATVC.ckQandARecord = CKRecord(recordType: Cloud.Entity.QandA)
                }
            }
        }
    }
}
