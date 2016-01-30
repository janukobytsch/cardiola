//
//  MeasurementController.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Charts

class MeasurementController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var historyBarChart: BarChartView!
    @IBOutlet weak var realtimeBarChart: BarChartView!
    
    lazy var colorSystolic = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    lazy var colorDiastolic = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //historyBarChart.delegate = self
        //realtimeBarChart.delegate = self
        initHistoryChart()
        initRealtimeChart()
    }
    
    func initHistoryChart() {
        self._initBarChart(historyBarChart)
        
        let leftAxis = historyBarChart.leftAxis
        leftAxis.enabled = true
        leftAxis.startAtZeroEnabled = true
        leftAxis.labelFont = UIFont.systemFontOfSize(20.0)
        leftAxis.drawAxisLineEnabled = true
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridLineWidth = 0.3
        
        let rightAxis = historyBarChart.rightAxis
        rightAxis.enabled = false
        
        loadHistoryData()
        
        historyBarChart.animate(xAxisDuration: NSTimeInterval(0), yAxisDuration: NSTimeInterval(2.5))
    }
    
    func initRealtimeChart() {
        self._initBarChart(realtimeBarChart)
        
        let leftAxis = realtimeBarChart.leftAxis
        leftAxis.startAtZeroEnabled = true
        leftAxis.customAxisMax = Double(Measurement.SYSTOLIC_MAX)
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        let rightAxis = realtimeBarChart.rightAxis
        rightAxis.enabled = false
        
        let systolicLimit = ChartLimitLine(limit: Double(Measurement.SYSTOLIC_AVG), label: "Normwert (systolisch)")
        systolicLimit.lineColor = colorSystolic
        systolicLimit.lineDashPhase = 0.5
        let diastolicLimit = ChartLimitLine(limit: Double(Measurement.DIASTOLIC_AVG), label: "Normwert (diastolisch)")
        diastolicLimit.lineColor = colorDiastolic
        diastolicLimit.lineDashPhase = 0.5
        leftAxis.addLimitLine(systolicLimit)
        leftAxis.addLimitLine(diastolicLimit)
        
        if realtimeBarChart.data == nil {
            realtimeBarChart.hidden = true
        }
    }
    
    func _initBarChart(chart: BarChartView) {
        chart.descriptionText = "Blutdruck"
        chart.noDataTextDescription = "Es stehen keine Daten zur Verfügung"
        chart.pinchZoomEnabled = false
        chart.drawGridBackgroundEnabled = false
        chart.drawBarShadowEnabled = false
        chart.drawValueAboveBarEnabled = true
        chart.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
        
        let legend = chart.legend
        legend.position = ChartLegend.ChartLegendPosition.BelowChartLeft
        legend.form = ChartLegend.ChartLegendForm.Square
        legend.xEntrySpace = 2.0
    }
    
    func simulateRealtime() {
        for count in 0...30 {
            let delaySeconds = 600.0 * Double(count)
            let waitTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySeconds * Double(NSEC_PER_MSEC)))
            
            dispatch_after(waitTime, GlobalDispatchUtils.MainQueue) {
                let measurement = Measurement.createRandom()
                self.updateRealtimeData(with: measurement)
            }
        }
    }
    
    func updateRealtimeData(with measurement: Measurement) {
        let systolicValue = measurement.systolicPressure ?? 0
        let systolicEntry = BarChartDataEntry(value: Double(systolicValue), xIndex: 0)
        let datasetSystolic = BarChartDataSet(yVals: [systolicEntry], label: "Systolisch")
        datasetSystolic.setColor(colorSystolic)
        
        let diastolicValue = measurement.diastolicPressure ?? 0
        let diastolicEntry = BarChartDataEntry(value: Double(diastolicValue), xIndex: 0)
        let datasetDiastolic = BarChartDataSet(yVals: [diastolicEntry], label: "Diastolisch")
        datasetDiastolic.setColor(colorDiastolic)
        
        let data = BarChartData(xVals: ["Blutdruck"], dataSets: [datasetSystolic, datasetDiastolic])
        let chart = self.realtimeBarChart
        
        if chart.data == nil {
            chart.animate(xAxisDuration: NSTimeInterval(0), yAxisDuration: NSTimeInterval(1.0))
        }
        
        chart.data = data
        chart.notifyDataSetChanged()
    }
    
    func loadHistoryData() {
        var xValues = [String]()
        var yValues = [BarChartDataEntry]()
        
        let measurements = MeasurementRepository.createRandomDataset()
        for (index, measurement) in measurements.enumerate() {
            let systolicPressure = measurement.systolicPressure ?? 0
            let diastolicPressure = measurement.diastolicPressure ?? 0
            let values = [systolicPressure, diastolicPressure].map({ Double($0) })
            let entry = BarChartDataEntry(values: values, xIndex: index)
            yValues.append(entry)
            
            let date = measurement.formattedDate
            xValues.append(date)
        }
        
        let dataset = BarChartDataSet(yVals: yValues, label: "Systolic pressure")
        dataset.colors = [colorSystolic, colorDiastolic]
        dataset.stackLabels = ["Systolisch", "Diastolisch"]
        let data = BarChartData(xVals: xValues, dataSet: dataset)
        historyBarChart.data = data
    }
    
    @IBAction func startMeasurement(sender: UIButton) {
        sender.enabled = false
        sender.hidden = true
        realtimeBarChart.hidden = false
        simulateRealtime()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
