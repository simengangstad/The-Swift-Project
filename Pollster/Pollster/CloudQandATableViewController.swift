//
//  CloudQandATableViewController.swift
//  Pollster
//
//  Created by Simen Gangstad on 29.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit
import CloudKit

class CloudQandATableViewController: QandATableViewController {

    var ckQandARecord: CKRecord {
        get {
            if _ckQandARecord == nil {
                _ckQandARecord = CKRecord(recordType: Cloud.Entity.QandA)
            }
            
            return _ckQandARecord!
        }
        set {
            _ckQandARecord = newValue
        }
    }
    
    private var _ckQandARecord: CKRecord? {
        didSet {
            let question = ckQandARecord[Cloud.Attribute.Question] as? String ?? ""
            let answers = ckQandARecord[Cloud.Attribute.Answers] as? [String] ?? []
            qanda = QandA(question: question, answers: answers)
            
            asking = ckQandARecord.wasCreatedByThisUser
        }
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        super.textViewDidEndEditing(textView)
        iCloudUpdate()
    }
    
    private let database = CKContainer.default().publicCloudDatabase

    @objc private func iCloudUpdate() {
        
        if !qanda.question.isEmpty && !qanda.answers.isEmpty {
            ckQandARecord[Cloud.Attribute.Question] = qanda.question as CKRecordValue
            ckQandARecord[Cloud.Attribute.Answers] = qanda.answers as CKRecordValue
            iCloudSaveRecord(recordToSave: ckQandARecord)
        }
    }
    
    private func iCloudSaveRecord(recordToSave: CKRecord) {
        database.save(recordToSave) { (savedRecord, error) in
            if error != nil {
                let ckError = error as? CKError
                
                if ckError?.code == CKError.Code.serverRecordChanged {
                    // ignore
                }
                
                self.retryAfterError(error: error, withSelector: #selector(self.iCloudUpdate))
            }
        }
    }
    
    private func retryAfterError(error: Error?, withSelector selector: Selector) {
        
        if let retryInterval = (error as? CKError)?.userInfo[CKErrorRetryAfterKey] as? TimeInterval {
            DispatchQueue.main.async {
                Timer.scheduledTimer(timeInterval: retryInterval,
                                     target: self,
                                     selector: selector,
                                     userInfo: nil,
                                     repeats: false)
            }
        }
    }
}
