//
//  DashboardController.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import UIKit
import Charts

class DashboardController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChartViewDelegate {
    
    let cellReuseIdentifier = "MeasurementTableViewCell"
    let addCellTitle = "Neue Messung erstellen"
    let addNewIndex = 0
    
    @IBOutlet weak var measurementPlanLabel: UILabel!
    @IBOutlet weak var measurementDetailLabel: UILabel!
    @IBOutlet weak var measurementDetailView: UIView!
    @IBOutlet weak var measurementTable: UITableView!
    @IBOutlet weak var newMeasurementLabel: UILabel!
    var measurementEntryView: MeasurementEntryView?
    
    
//    var userRepository: UserRepository?
//    var planRepository: MeasurementPlanRepository?
    var patientRepository = PatientRepository()
    var planRepository = PlanRepository()
    
    var currentPatient: Patient?
    var currentPlan: MeasurementPlan?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        measurementTable.dataSource = self
        measurementTable.delegate = self
        
        currentPatient = patientRepository.getCurrentPatient()
        if let patient = currentPatient {
            currentPlan = planRepository.getPlan(from: patient)
        }
        
        measurementEntryView = MeasurementEntryView(frame: measurementDetailView.frame, master: self)
        measurementDetailView.addSubview(measurementEntryView!)
        measurementEntryView?.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ChartViewDelegate
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        if indexPath.row != addNewIndex {
            if let entry = currentPlan?.entries?[indexPath.row-1] {
                cell.textLabel?.text = entry.formattedDate
                cell.detailTextLabel?.text = entry.formattedTime
            }
        } else if indexPath.row == addNewIndex {
            cell.textLabel?.text = addCellTitle
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentPlan?.entries?.count ?? 0) + 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == addNewIndex {
            measurementEntryView?.hidden = true
            newMeasurementLabel.hidden = false
            let newEntry = MeasurementPlanEntry(dueDate: NSDate(timeIntervalSinceNow: 0))
            newEntry.setMeasurement(Measurement.createRandom())
            newEntry.types = [MeasurementPlanEntryType.HeartRate, MeasurementPlanEntryType.BloodPressure]
            self.addNewEntry(newEntry)
            
        } else {
            newMeasurementLabel.hidden = true
            measurementEntryView?.hidden = false
            measurementEntryView?.updateViewWith((currentPlan?.entries?[indexPath.row-1])!)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func addNewEntry(entry: MeasurementPlanEntry) {
        self.currentPlan?.entries?.insert(entry, atIndex: 0)
        
        measurementTable.beginUpdates()
        measurementTable.insertRowsAtIndexPaths([
            NSIndexPath(forRow: 1, inSection: 0)
            ], withRowAnimation: .Automatic)
        measurementTable.endUpdates()
    }
    
    func showAlertMessage(title: String, message: String, acceptable: Bool = false) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: "Zurück", style: .Cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        
        if acceptable {
            let ok = UIAlertAction(title: "OK", style: .Default) { (action) in }
            alertController.addAction(ok)
        }
        
        self.presentViewController(alertController, animated: true) { }
    }
}
