//
//  DashboardController.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import UIKit
import Charts

class DashboardController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChartViewDelegate, RecorderUpdateListener {
    
    let cellReuseIdentifier = "MeasurementTableViewCell"
    
    let addCellTitle = "Neue Messung erstellen"
    let activeEntriesTitle = "Aktuelle Messung"
    let archivedEntriesTitle = "Archivierte Messungen"
    let pendingEntriesTitle = "Bevorstehende Messungen"
    
    enum EntrySection: Int {
        case NewMeasurement = 0
        case ActiveEntries = 1
        case DoneEntries = 2
        case TodoEntries = 3
    }
    
    // dictionary containg mapping from section titles to section items
    var entries = [String: [MeasurementPlanEntry]]()
    
    @IBOutlet weak var measurementPlanLabel: UILabel!
    @IBOutlet weak var measurementDetailLabel: UILabel!
    @IBOutlet weak var measurementDetailView: UIView!
    @IBOutlet weak var measurementTable: UITableView!
    @IBOutlet weak var newMeasurementLabel: UILabel!
    var measurementEntryView: MeasurementEntryView?
    
    var patientRepository: PatientRepository?
    var planRepository: PlanRepository?
    
    var measurementRecorder: MeasurementRecorder?

    var currentPatient: Patient?
    var currentPlan: MeasurementPlan?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // allows the recorder to propagate updates to the model
        measurementRecorder?.addUpdateListener(self)
        
        measurementTable.dataSource = self
        measurementTable.delegate = self
        
        currentPatient = patientRepository?.getCurrentPatient()
        currentPlan = planRepository?.currentPlan
        
        measurementEntryView = MeasurementEntryView(frame: measurementDetailView.frame, master: self)
        measurementDetailView.addSubview(measurementEntryView!)
        measurementEntryView?.hidden = true

        entries = [pendingEntriesTitle: currentPlan!.pendingEntries,
                    archivedEntriesTitle: currentPlan!.archivedEntries,
                    activeEntriesTitle: currentPlan!.activeEntries]
    }
    
    override func viewWillAppear(animated: Bool) {
        // model might have changed meanwhile
        measurementTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ChartViewDelegate
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = addCellTitle
        } else {
            let entry = _entryForIndexPath(indexPath)
            cell.textLabel?.text = entry.formattedDate
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return entries[Array(entries.keys)[section - 1]]!.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return entries.keys.count + 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "" : Array(entries.keys)[section - 1]
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            newMeasurementLabel.hidden = false
            measurementEntryView?.hidden = true
            addActiveEntry()
        default:
            newMeasurementLabel.hidden = true
            measurementEntryView?.hidden = false
            measurementEntryView?.updateViewWith(_entryForIndexPath(indexPath))
        }
    }
    
    // MARK: RecorderUpdateListener
    
    func update() {
        entries[activeEntriesTitle] = currentPlan!.activeEntries
        entries[pendingEntriesTitle] = currentPlan!.pendingEntries
        entries[archivedEntriesTitle] = currentPlan!.archivedEntries
        measurementTable.reloadData()
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */

    func addActiveEntry() {
        measurementRecorder?.start(from: self)
    }
    
    func activateEntry(entry: MeasurementPlanEntry) {
        measurementRecorder?.start(with: entry, from: self)
//        if let idx = (self.entries[todoEntriesTitle]!).indexOf(entry) {
//            self.entries[doneEntriesTitle]!.append(entry)
//            self.entries[todoEntriesTitle]!.removeAtIndex(idx)
//            
//            measurementTable.beginUpdates()
//            measurementTable.deleteRowsAtIndexPaths([NSIndexPath(forRow: idx, inSection: 2)], withRowAnimation: .Automatic)
//            measurementTable.insertRowsAtIndexPaths([NSIndexPath(forRow: self.entries[doneEntriesTitle]!.count - 1 , inSection: 1)], withRowAnimation: .Automatic)
//            measurementTable.endUpdates()
//            
//            entry.save()
//            measurementRecorder?.start(from: self)
//        }
    }
    
    func archiveEntry(entry: MeasurementPlanEntry) {
        measurementRecorder?.finish()
    }
    
    
    // MARK: Utils
    
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
    
    func _entryForIndexPath(indexPath: NSIndexPath) -> MeasurementPlanEntry {
        return entries[Array(entries.keys)[indexPath.section - 1]]![indexPath.row]
    }
}
