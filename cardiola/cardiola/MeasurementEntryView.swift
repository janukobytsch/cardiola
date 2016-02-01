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
        
        entryStackView.frame = CGRectMake(width/2 - 400, 10, 800, 600)
        entryStackView.axis = UILayoutConstraintAxis.Vertical
        entryStackView.distribution = UIStackViewDistribution.FillEqually
        addSubview(entryStackView)
        
        bloodPressureStackView.frame = CGRectMake(0, 0, 800, 200)
        bloodPressureStackView.axis = UILayoutConstraintAxis.Vertical
        bloodPressureStackView.distribution = UIStackViewDistribution.FillProportionally
        entryStackView.addArrangedSubview(bloodPressureStackView)
        
        bloodPressureTitelLabel.text = "Blutdruck:"
        bloodPressureTitelLabel.textAlignment = NSTextAlignment.Left
        bloodPressureTitelLabel.font = UIFont.boldSystemFontOfSize(72)
        bloodPressureStackView.addArrangedSubview(bloodPressureTitelLabel)
        bloodPressureValueLabel.text = "Wert X\nWert Y"
        bloodPressureValueLabel.numberOfLines = 2
        bloodPressureValueLabel.textAlignment = NSTextAlignment.Right
        bloodPressureValueLabel.font = bloodPressureValueLabel.font.fontWithSize(68)
        bloodPressureStackView.addArrangedSubview(bloodPressureValueLabel)
        
        heartRateStackView.frame = CGRectMake(width/2 - 400, 40, 800, 200)
        heartRateStackView.axis = UILayoutConstraintAxis.Vertical
        heartRateStackView.distribution = UIStackViewDistribution.FillProportionally
        entryStackView.addArrangedSubview(heartRateStackView)
        
        heartRateTitelLabel.text = "Herzfrequenz:"
        heartRateTitelLabel.textAlignment = NSTextAlignment.Left
        heartRateTitelLabel.font = UIFont.boldSystemFontOfSize(72)
        heartRateStackView.addArrangedSubview(heartRateTitelLabel)
        heartRateValueLabel.text = "WErt XYZ:"
        heartRateValueLabel.numberOfLines = 1
        heartRateValueLabel.textAlignment = NSTextAlignment.Right
        heartRateValueLabel.font = heartRateValueLabel.font.fontWithSize(68)
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
        
        newEntryButton.hidden = hideNewButton
        entryStackView.hidden = !hideNewButton
        
        if hideNewButton {
            if self.entry!.types.contains(MeasurementPlanEntryType.BloodPressure) {
                bloodPressureStackView.hidden = false
                
                let valueText = "SYS:\t" + String((self.entry?.data?.systolicPressure!)!) + "\nDIA:\t" + String((self.entry?.data?.diastolicPressure)!)
                bloodPressureValueLabel.numberOfLines = 2
                bloodPressureValueLabel.text = valueText
            } else {
                bloodPressureStackView.hidden = true
            }
            
            if self.entry!.types.contains(MeasurementPlanEntryType.HeartRate) {
                heartRateStackView.hidden = false
                
                let valueText = "HeartRate:\t" + String((self.entry?.data?.heartRate!)!) + " BPM"
                heartRateValueLabel.numberOfLines = 1
                heartRateValueLabel.text = valueText
            } else {
                heartRateStackView.hidden = true
            }
        }
    }
    
    func updateViewWith(entry: MeasurementPlanEntry) {
        self.entry = entry
        updateView()
    }
    
    func createNewMeasurement() {
        let isToday = self.entry?.dueDate?.isSameDayAs(NSDate())
        if let isToday = isToday {
            masterView?.showAlertMessage("Falsches Datum", message: "Bitte Einträge nur an dem entsprechenden Datum erstellen")
        } else {
            self.entry?.setMeasurement(Measurement.createRandom())
            self.updateViewWith(self.entry!)
            
            masterView?.updateEntryPosition(self.entry!)
        }
    }
}
