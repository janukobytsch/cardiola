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
    let measurementRadarTitleChart = "Messdetails"
    let measurementRadarTitlePending = "Messung noch ausstehend"
    
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
    @IBOutlet weak var measurementTable: UITableView!
    @IBOutlet weak var measurementRadarTitle: UILabel!
    @IBOutlet weak var measurementRadar: RadarChartView!
    
    var patientRepository: PatientRepository?
    var planRepository: PlanRepository?
    
    var measurementRecorder: MeasurementRecorder?
    
    var currentPatient: Patient?
    var currentPlan: MeasurementPlan?
    
    override var preferredFocusedView: UIView? {
        return self.measurementTable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // allows the recorder to propagate updates to the model
        measurementRecorder?.addUpdateListener(self)
        
        measurementTable.dataSource = self
        measurementTable.delegate = self
        measurementTable.remembersLastFocusedIndexPath = true
        
        let playPauseRecognizer = UITapGestureRecognizer(target: self, action: "tablePlayPausePressed")
        playPauseRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)];
        measurementTable.addGestureRecognizer(playPauseRecognizer)
        
        currentPatient = patientRepository?.getCurrentPatient()
        currentPlan = planRepository?.currentPlan
        
        entries = [pendingEntriesTitle: currentPlan!.pendingEntries,
            archivedEntriesTitle: currentPlan!.archivedEntries,
            activeEntriesTitle: currentPlan!.activeEntries]
        
        initRadarChart()
    }
    
    override func viewWillAppear(animated: Bool) {
        // model might have changed meanwhile
        measurementTable.reloadData()
        measurementRadar.notifyDataSetChanged()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Charts
    
    func initRadarChart() {
        let chart = measurementRadar
        
        chart.descriptionText = "Vitalparameter"
        chart.webLineWidth = 1.0
        chart.innerWebLineWidth = 1.0
        chart.webAlpha = 1.0
        chart.backgroundColor = Colors.translucent
        
        let legend = chart.legend
        legend.position = ChartLegend.ChartLegendPosition.BelowChartLeft
        legend.form = ChartLegend.ChartLegendForm.Square
        legend.xEntrySpace = 2.0
        
        let yAxis = chart.yAxis
        yAxis.labelCount = 0
        yAxis.drawTopYLabelEntryEnabled = false
        yAxis.drawGridLinesEnabled = false
        yAxis.drawLabelsEnabled = false
        yAxis.startAtZeroEnabled = true
        yAxis.drawLimitLinesBehindDataEnabled = false
        
        let xAxis = chart.xAxis
        xAxis.drawGridLinesEnabled = false
    }
    
    // TODO: support missing vital parameters
    // TODO: Collect data
    func updateChartData(selectedEntry: MeasurementPlanEntry) {
        let chart = self.measurementRadar
        let measurement = selectedEntry.data
        
        var xValues = ["Systolischer Blutdruck", "Diastolischer Blutdruck", "Pulsrate", "Blutzucker", "Sauferstoffsättigung", "Persönliches Befinden"]
        var yValues = [ChartDataEntry]()
        
        // pending dataset
        if let pendingMeasurement =  measurementRecorder?.currentMeasurement {
            
            //let supports = [pending.isBloodPressureEntry, selectedEntry.isBloodPressureEntry, selectedEntry.isHeartRateEntry, false, false, false]
            let properties = [pendingMeasurement.systolicPressure, pendingMeasurement.diastolicPressure, pendingMeasurement.heartRate, nil, nil, nil]
            yValues = properties.enumerate().map() {
                return ($0.element != nil) ? ChartDataEntry(value: Double($0.element!), xIndex: $0.0) : ChartDataEntry(value: 0.0, xIndex: $0.0)
            }
        }
        
        let dataset1 = RadarChartDataSet(yVals: yValues, label: "Ausstehende Messung")
        dataset1.drawFilledEnabled = true
        dataset1.setColor(Colors.gray)
        dataset1.fillColor = Colors.gray
        dataset1.lineWidth = 2.0
        
        // recorded dataset
        
        let properties = [measurement?.systolicPressure, measurement?.diastolicPressure, measurement?.heartRate, nil, nil, nil]
        yValues = properties.enumerate().map() {
            return ($0.element != nil) ? ChartDataEntry(value: Double($0.element!), xIndex: $0.0) : ChartDataEntry(value: 0.0, xIndex: $0.0)
        }
        
        let dataset2 = RadarChartDataSet(yVals: yValues, label: "Abgeschlossene Messung")
        dataset2.drawFilledEnabled = true
        dataset2.setColor(Colors.darkGray)
        dataset2.fillColor = Colors.darkGray
        dataset2.lineWidth = 2.0
        
        // annotate x-values
        
        for (index, recordedValue) in properties.enumerate() {
            let annotation = (recordedValue != nil) ? "\n\(recordedValue)" : "\n(ausstehend)"
            xValues[index] = xValues[index] + annotation
        }
        
        let data = RadarChartData(xVals: xValues, dataSets: [dataset1, dataset2])
        chart.data = data
        
        chart.hidden = false
        chart.notifyDataSetChanged()
    }
    
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
            addActiveEntry()
        default:
            let selectedEntry = _entryForIndexPath(indexPath)
            if !selectedEntry.isPending {
                self.measurementRadarTitle.text = measurementRadarTitleChart
                updateChartData(selectedEntry)
            } else {
                self.measurementRadarTitle.text = measurementRadarTitlePending
            }
        }
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        self.measurementRadar.hidden = true
    }
    
    // MARK: Longpresscallback
    
    func tablePlayPausePressed() {
        if measurementTable.indexPathForSelectedRow != nil &&
            _entryForIndexPath(measurementTable.indexPathForSelectedRow!).data != nil {
                showDeleteEntryDialog();
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
        let waitTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_MSEC)))
        dispatch_after(waitTime, GlobalDispatchUtils.MainQueue) {
            self.tabBarController?.selectedIndex = 1
        }
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
    
    func removeSelectedEntry() {
        if let indexPath = measurementTable.indexPathForSelectedRow {
            if Array(entries.keys)[indexPath.section - 1] == archivedEntriesTitle  {
                let entry = _entryForIndexPath(indexPath)
                
                if entry.data != nil {
                    currentPlan?.removeEntry(entry)
                    self.update()
                    self.measurementRadar.hidden = true
                }
            }
        }
    }
    
    
    // MARK: Utils
    
    
    func showDeleteEntryDialog() {
        let alertController = UIAlertController(title: "Messung löschen",
            message: "Soll die ausgewählte Messung gelöscht werden?", preferredStyle: .Alert)
        
        
        let cancelAction = UIAlertAction(title: "Messung löschen", style: .Destructive) { (action) in
            self.removeSelectedEntry()
        }
        alertController.addAction(cancelAction)
        
        let ok = UIAlertAction(title: "Zurück", style: .Default) { (action) in }
        alertController.addAction(ok)
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func _entryForIndexPath(indexPath: NSIndexPath) -> MeasurementPlanEntry {
        return entries[Array(entries.keys)[indexPath.section - 1]]![indexPath.row]
    }
}
