//
//  AlarmDetailTableViewController.swift
//  Alarm
//
//  Created by John Tate on 8/27/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import UIKit

class AlarmDetailTableViewController: UITableViewController {

    @IBOutlet weak var alarmDate: UIDatePicker!
    @IBOutlet weak var alarmDescription: UITextField!
    @IBOutlet weak var enableButton: UIButton!
    
    // landing pad
    var alarm: Alarm? {
        didSet{
            if isViewLoaded{
            updateViews()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }


    // MARK: - Private
    
    private func updateViews() {
        guard let alarm = alarm,
            let thisMorningAtMidnight = DateHelper.thisMorningAtMidnight,
            isViewLoaded else {
                enableButton.isHidden = true
                return
        }
        
       alarmDate.setDate(Date(timeInterval: alarm.fireTimeFromMidnight, since: thisMorningAtMidnight), animated: false)
       alarmDescription.text = alarm.name
      
        enableButton.isHidden = false
        if alarm.enabled == true {
            enableButton.setTitle("Disable", for: UIControlState())
            enableButton.setTitleColor(.white, for: UIControlState())
            enableButton.backgroundColor = .red
        } else {
            enableButton.setTitle("Enable", for: UIControlState())
            enableButton.setTitleColor(.black, for: UIControlState())
            enableButton.backgroundColor = .green
        }
    
        self.title = alarm.name
    }
    

    @IBAction func enableButtonTapped(_ sender: Any) {
        guard let alarm = alarm else {return}
        AlarmController.shared.toggledEnabled(for: alarm)
        updateViews()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = alarmDescription.text,
            let thisMorningAtMidnight = DateHelper.thisMorningAtMidnight else {return}
        let timeIntervalSinceMidnight = alarmDate.date.timeIntervalSince(thisMorningAtMidnight)
        if let alarm = alarm {
            AlarmController.shared.update(alarm: alarm, fireTimeFromMidnight: timeIntervalSinceMidnight, name: title)
        } else {
            AlarmController.shared.addAlarm(fireTimeFromMidnight: timeIntervalSinceMidnight, name: title)
        }
        navigationController?.popViewController(animated: true)
    }
    
    
}
