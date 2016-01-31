//
//  BloodPressureMeasurementManager.swift
//  
//
//  Created by Janusch Jacoby on 30/01/16.
//
//

import Foundation
import Charts

class BloodPressureMeasurementManager: MeasurementManager {
    
    var historyChart: BarChartView
    var realtimeChart: BarChartView
    
    var views: [UIView] {
        return [historyChart, realtimeChart]
    }
    
    required init(realtimeChart: ChartViewBase, historyChart: ChartViewBase) {
        self.historyChart = historyChart as! BarChartView
        self.realtimeChart = realtimeChart as! BarChartView
        initRealtimeChart()
        initHistoryChart()
        beforeModeChanged()
    }
    
    func initHistoryChart() {
        self._initBarChart(historyChart)
        
        let leftAxis = historyChart.leftAxis
        leftAxis.enabled = true
        leftAxis.startAtZeroEnabled = true
        leftAxis.labelFont = UIFont.systemFontOfSize(20.0)
        leftAxis.drawAxisLineEnabled = true
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridLineWidth = 0.3
        
        let rightAxis = historyChart.rightAxis
        rightAxis.enabled = false

        historyChart.animate(xAxisDuration: NSTimeInterval(0), yAxisDuration: NSTimeInterval(2.5))
    }
    
    func initRealtimeChart() {
        self._initBarChart(realtimeChart)
        
        let leftAxis = realtimeChart.leftAxis
        leftAxis.startAtZeroEnabled = true
        leftAxis.customAxisMax = Double(Measurement.SYSTOLIC_MAX)
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        let rightAxis = realtimeChart.rightAxis
        rightAxis.enabled = false
        
        let systolicLimit = ChartLimitLine(limit: Double(Measurement.SYSTOLIC_AVG), label: "Normwert (systolisch)")
        systolicLimit.lineColor = Colors.darkGray
        systolicLimit.lineDashPhase = 0.5
        
        let diastolicLimit = ChartLimitLine(limit: Double(Measurement.DIASTOLIC_AVG), label: "Normwert (diastolisch)")
        diastolicLimit.lineColor = Colors.gray
        diastolicLimit.lineDashPhase = 0.5
        
        leftAxis.addLimitLine(systolicLimit)
        leftAxis.addLimitLine(diastolicLimit)
        
        if realtimeChart.data == nil {
            realtimeChart.hidden = true
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
    
    func updateHistoryData(with measurements: [Measurement]) {
        var xValues = [String]()
        var yValues = [BarChartDataEntry]()
        
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
        dataset.colors = [Colors.darkGray, Colors.gray]
        dataset.stackLabels = ["Systolisch", "Diastolisch"]
        
        let data = BarChartData(xVals: xValues, dataSet: dataset)
        historyChart.data = data
        historyChart.notifyDataSetChanged()
    }
    
    func updateRealtimeData(with measurement: Measurement) {
        let systolicValue = measurement.systolicPressure ?? 0
        let systolicEntry = BarChartDataEntry(value: Double(systolicValue), xIndex: 0)
        let datasetSystolic = BarChartDataSet(yVals: [systolicEntry], label: "Systolisch")
        datasetSystolic.setColor(Colors.darkGray)
        
        let diastolicValue = measurement.diastolicPressure ?? 0
        let diastolicEntry = BarChartDataEntry(value: Double(diastolicValue), xIndex: 0)
        let datasetDiastolic = BarChartDataSet(yVals: [diastolicEntry], label: "Diastolisch")
        datasetDiastolic.setColor(Colors.gray)
        
        let data = BarChartData(xVals: ["Blutdruck"], dataSets: [datasetSystolic, datasetDiastolic])
        let chart = self.realtimeChart
        
        if chart.data == nil {
            chart.animate(xAxisDuration: NSTimeInterval(0), yAxisDuration: NSTimeInterval(1.0))
        }
        
        chart.data = data
        chart.notifyDataSetChanged()
    }

    func startMeasurement() {
        realtimeChart.hidden = false
    }
    
    func beforeModeChanged() {
        // hide all mode-specific views
        for view in views {
            view.hidden = true
        }
    }
    
    func afterModeChanged() {
        // show all mode-specific views
        for view in views {
            view.hidden = false
        }
    }
    
}