//
//  NewMeasurementView.swift
//  cardiola
//
//  Created by Jakob Frick on 31/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import UIKit

class MeasurementEntryView: UIView {

    var masterView: DashboardController?
    var entry: MeasurementPlanEntry?
    
    var newEntryButton = UIButton(type: UIButtonType.System) as UIButton
    var entryStackView = UIStackView()
    var bloodPressureStackView = UIStackView()
    var bloodPressureTitelLabel = UILabel()
    var bloodPressureValueLabel = UILabel()
    
    var heartRateStackView = UIStackView()
    var heartRateTitelLabel = UILabel()
    var heartRateValueLabel = UILabel()
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    // MARK: Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self._setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self._setupView()
    }
    
    init(frame: CGRect, master: DashboardController, entry: MeasurementPlanEntry? = nil) {
        super.init(frame: frame)
        
        self._setupView()
        self.setMaster(master)
    }
    
    private func _setupView(entry: MeasurementPlanEntry? = nil) {
        
        newEntryButton.setTitle("Messung aufnehmen", forState: UIControlState.Normal)
        let width = self.frame.size.width
        let frame = CGRectMake(width/2 - 400, 40, 800, 600)
        newEntryButton.frame = frame
        newEntryButton.addTarget(self, action: "createNewMeasurement", forControlEvents: UIControlEvents.PrimaryActionTriggered)
        addSubview(newEntryButton)
        
        entryStackView.frame = CGRectMake(width/2 - 400, 40, 800, 600)
        entryStackView.axis = UILayoutConstraintAxis.Vertical
        entryStackView.distribution = UIStackViewDistribution.FillEqually
        addSubview(entryStackView)
        
        bloodPressureStackView.frame = CGRectMake(width/2 - 400, 40, 800, 200)
        bloodPressureStackView.axis = UILayoutConstraintAxis.Vertical
        bloodPressureStackView.distribution = UIStackViewDistribution.FillEqually
        entryStackView.addArrangedSubview(bloodPressureStackView)
        
        bloodPressureTitelLabel.text = "Blutdruck:"
        bloodPressureTitelLabel.textAlignment = NSTextAlignment.Left
        bloodPressureTitelLabel.font = bloodPressureTitelLabel.font.fontWithSize(40)
        bloodPressureStackView.addArrangedSubview(bloodPressureTitelLabel)
        bloodPressureValueLabel.text = "Wert XZY:"
        bloodPressureValueLabel.textAlignment = NSTextAlignment.Right
        bloodPressureValueLabel.font = bloodPressureValueLabel.font.fontWithSize(40)
        bloodPressureStackView.addArrangedSubview(bloodPressureValueLabel)
        
        heartRateStackView.frame = CGRectMake(width/2 - 400, 40, 800, 200)
        heartRateStackView.axis = UILayoutConstraintAxis.Vertical
        heartRateStackView.distribution = UIStackViewDistribution.FillEqually
        entryStackView.addArrangedSubview(heartRateStackView)
        
        heartRateTitelLabel.text = "Herzfrequenz:"
        heartRateTitelLabel.textAlignment = NSTextAlignment.Left
        heartRateTitelLabel.font = heartRateTitelLabel.font.fontWithSize(40)
        heartRateStackView.addArrangedSubview(heartRateTitelLabel)
        heartRateValueLabel.text = "WErt XYZ:"
        heartRateValueLabel.textAlignment = NSTextAlignment.Left
        heartRateValueLabel.font = heartRateValueLabel.font.fontWithSize(40)
        heartRateStackView.addArrangedSubview(heartRateValueLabel)
    
        if entry != nil {
            updateViewWith(entry!)
        } else {
            updateView()
        }
    }
    
    // MARK: Interactions
    
    func setMaster(view: DashboardController) {
        self.masterView = view
    }
    
    func updateView() {
        let hideNewButton = (self.entry?.data != nil)
        
        print("Showing new button", self.entry?.data, hideNewButton)
        
        newEntryButton.hidden = hideNewButton
        entryStackView.hidden = !hideNewButton
        
        if hideNewButton {
            if self.entry!.types.contains(MeasurementPlanEntryType.BloodPressure) {
                bloodPressureStackView.hidden = false
            } else {
                bloodPressureStackView.hidden = true
            }
            
            if self.entry!.types.contains(MeasurementPlanEntryType.HeartRate) {
                heartRateStackView.hidden = false
            } else {
                heartRateStackView.hidden = true
            }
        }
    }
    
    func updateViewWith(entry: MeasurementPlanEntry) {
        self.entry = entry
        print("setting entry")
        updateView()
    }
    
    func createNewMeasurement() {
        // Check if we are on the same date
        let calendar = NSCalendar.currentCalendar()
        
        let nowDate = NSDate(timeIntervalSinceNow: 0)
        
        let difference = calendar.components(.Day, fromDate:  (self.entry?.dueDate)!, toDate: nowDate, options: [])
        if difference.day != 0 {
            masterView?.showAlertMessage("Falsches Datum", message: "Bitte Einträge nur an dem entsprechenden Datum erstellen")
        } else {
            self.entry?.setMeasurement(Measurement.createRandom())
            self.updateViewWith(self.entry!)
        }
    }
}
