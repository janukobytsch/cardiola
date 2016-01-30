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
        
        let rightAxis = realtimeBarChart.rightAxis
        rightAxis.enabled = false
        
        let systolicLimit = ChartLimitLine(limit: Double(Measurement.SYSTOLIC_AVG), label: "Normwert (systolisch)")
        let diastolicLimit = ChartLimitLine(limit: Double(Measurement.DIASTOLIC_AVG), label: "Normwert (diastolisch)")
        leftAxis.addLimitLine(systolicLimit)
        leftAxis.addLimitLine(diastolicLimit)
        
        simulateRealtime()
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
        let value = measurement.systolicPressure ?? 0
        let entry = BarChartDataEntry(value: Double(value), xIndex: 0)
        let dataset = BarChartDataSet(yVals: [entry])
        let data = BarChartData(xVals: ["Systolic Pressure"], dataSet: dataset)
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
            let value = measurement.systolicPressure ?? 0
            let entry = BarChartDataEntry(value: Double(value), xIndex: index)
            yValues.append(entry)
            
            let date = measurement.formattedDate
            xValues.append(date)
        }
        
        let dataset = BarChartDataSet(yVals: yValues, label: "Systolic pressure")
        let data = BarChartData(xVals: xValues, dataSet: dataset)
        historyBarChart.data = data
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
