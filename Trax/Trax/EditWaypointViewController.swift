//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by Simen Gangstad on 01.12.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class EditWaypointViewController: UIViewController, UITextFieldDelegate {

    var waypoint: EditableWaypoint? { didSet { updateUI() } }
    
    private func updateUI() {
        nameTextField?.text = waypoint?.name
        infoTextField?.text = waypoint?.info
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        nameTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listenToTextFields()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        preferredContentSize = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopListeningToTextFields()
    }
    
    private var ntfObserver: NSObjectProtocol?
    private var itfObserver: NSObjectProtocol?
    
    private func listenToTextFields() {
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        
        ntfObserver = center.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange,
                           object: nameTextField,
                           queue: queue,
                           using: {notification in
        
                            if let waypoint = self.waypoint {
                                waypoint.name = self.nameTextField.text
                            }
        })
        
        
        itfObserver = center.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange,
                           object: nameTextField,
                           queue: queue,
                           using: {notification in
                            
                            if let waypoint = self.waypoint {
                                waypoint.info = self.infoTextField.text
                            }
        })
    }
    
    private func stopListeningToTextFields() {
        if let observer = ntfObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if let observer = itfObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }
    @IBOutlet weak var infoTextField: UITextField! { didSet { infoTextField.delegate = self } }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
