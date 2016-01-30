//
//  DashboardController.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import UIKit

class DashboardController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellReuseIdentifier = "MeasurementTableViewCell"

    @IBOutlet weak var measurementPlanLabel: UILabel!
    @IBOutlet weak var lastMeasurementLabel: UILabel!
    @IBOutlet weak var measurementTable: UITableView!
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        if let entry = currentPlan?.entries?[indexPath.row] {
            cell.textLabel?.text = entry.formattedDate
            cell.detailTextLabel?.text = entry.formattedTime
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPlan?.entries?.count ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: UITableViewDelegate
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
