//
//  HeartFrequencyMeasurementManager.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation
import Charts


class HeartFrequencyMeasurementManager: MeasurementManager {
    
    let MAX_VISIBLE_VALUES = 20
    
    var historyChart: CombinedChartView
    var realtimeChart: LineChartView
    
    var views: [UIView] {
        return [historyChart, realtimeChart]
    }
    
    required init(realtimeChart: ChartViewBase, historyChart: ChartViewBase) {
        self.historyChart = historyChart as! CombinedChartView
        self.realtimeChart = realtimeChart as! LineChartView
        initRealtimeChart()
        initHistoryChart()
        beforeModeChanged()
    }
    
    func initHistoryChart() {
        let chart = self.historyChart
        
        chart.descriptionText = "Herzfrequenz"
        chart.noDataTextDescription = "Es stehen keine Daten zur Verfügung"
        chart.drawGridBackgroundEnabled = true
        chart.drawBarShadowEnabled = false
        chart.backgroundColor = Colors.translucent
        chart.gridBackgroundColor = Colors.translucent
        
        let legend = chart.legend
        legend.position = ChartLegend.ChartLegendPosition.BelowChartLeft
        legend.form = ChartLegend.ChartLegendForm.Square
        legend.xEntrySpace = 2.0
        
        let leftAxis = chart.leftAxis
        leftAxis.startAtZeroEnabled = true
        leftAxis.customAxisMax = Double(Measurement.HEART_RATE_MAX)
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        let rightAxis = chart.rightAxis
        rightAxis.enabled = false
        
        let restingLimit = ChartLimitLine(limit: Double(Measurement.HEART_RATE_RESTING), label: "Ruhepuls (Normwert)")
        restingLimit.lineColor = Colors.lightgray
        restingLimit.lineDashPhase = 0.5
        
        let stressLimit = ChartLimitLine(limit: Double(Measurement.HEART_RATE_STRESS), label: "Belastungspuls (Normwert)")
        stressLimit.lineColor = Colors.lightgray
        stressLimit.lineDashPhase = 0.5
        
        leftAxis.addLimitLine(restingLimit)
        leftAxis.addLimitLine(stressLimit)
        
        if historyChart.data == nil {
            historyChart.hidden = true
        }
    }
    
    func initRealtimeChart() {
        let chart = self.realtimeChart
        
        chart.descriptionText = "Herzfrequenz"
        chart.noDataTextDescription = "Es stehen keine Daten zur Verfügung"
        chart.pinchZoomEnabled = false
        chart.drawGridBackgroundEnabled = false
        chart.backgroundColor = Colors.translucent
        
        let legend = chart.legend
        legend.position = ChartLegend.ChartLegendPosition.BelowChartLeft
        legend.form = ChartLegend.ChartLegendForm.Square
        legend.xEntrySpace = 2.0
        
        let leftAxis = realtimeChart.leftAxis
        leftAxis.startAtZeroEnabled = true
        leftAxis.customAxisMax = Double(Measurement.HEART_RATE_MAX)
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        let rightAxis = realtimeChart.rightAxis
        rightAxis.enabled = false
        
        if realtimeChart.data == nil {
            realtimeChart.hidden = true
        }
    }
    
    func updateHistoryData(with measurements: [Measurement]) {
        guard measurements.count > 0 else {
            return
        }
        
        // fit measurements in bins for same day
        let binning = measurements.collectSimilar({ $0.date! < $1.date! }) {
            return $0.date!.isSameDayAs($1.date!)
        }
        
        let xValues = binning.flatMap({ $0[0].formattedDate })
        
        let data = CombinedChartData(xVals: xValues)
        data.lineData = self.createLineData(binning)
        data.barData = self.createBarData(binning)
        
        historyChart.data = data
        historyChart.notifyDataSetChanged()
    }
    
    func createLineData(measurements: [[Measurement]]) -> LineChartData {
        var entries = [ChartDataEntry]()
        let maxIndex = measurements.count - 1
        for index in 0...maxIndex {
            let relevantMeasurements = measurements[index]
            let average = relevantMeasurements.averageHeartRate() ?? 0
            let entry = ChartDataEntry(value: average, xIndex: index)
            entries.append(entry)
        }
        let dataset = LineChartDataSet(yVals: entries, label: "Pulsrate (Durchschnitt)")
        dataset.setColor(Colors.gray)
        dataset.fillColor = Colors.gray
        dataset.circleColors = [Colors.gray]
        dataset.drawCubicEnabled = true
        dataset.drawValuesEnabled = true
        let data = LineChartData()
        data.addDataSet(dataset)
        return data
    }
    
    func createBarData(measurements: [[Measurement]]) -> BarChartData {
        var entries = [BarChartDataEntry]()
        let maxIndex = measurements.count - 1
        for index in 0...maxIndex {
            let relevantMeasurements = measurements[index]
            let max = relevantMeasurements.maxHeartRate() ?? 0
            let entry = BarChartDataEntry(value: Double(max), xIndex: index)
            entries.append(entry)
        }
        let dataset = BarChartDataSet(yVals: entries, label: "Pulsrate (Maximum)")
        dataset.setColor(Colors.darkGray)
        let data = BarChartData()
        data.addDataSet(dataset)
        return data
    }
    
    func updateRealtimeData(with measurement: Measurement) {
        let chart = self.realtimeChart
        let heartRate = measurement.heartRate ?? 0
        let xValue = measurement.formattedTime
        let xIndex = (chart.data?.xValCount ?? -1) + 1
        let entry = ChartDataEntry(value: Double(heartRate), xIndex: xIndex)
        
        if chart.data == nil {
            let dataset = self.createDataset()
            let data = LineChartData(xVals: [xValue], dataSet: dataset)
            chart.data = data
        }
        
        chart.data?.addXValue(xValue)
        chart.data?.addEntry(entry, dataSetIndex: 0)
        chart.notifyDataSetChanged()
        chart.setVisibleXRangeMaximum(CGFloat(MAX_VISIBLE_VALUES))
        chart.moveViewToX(xIndex - MAX_VISIBLE_VALUES - 1)
    }
    
    func createDataset() -> LineChartDataSet {
        let dataset = LineChartDataSet(yVals: [])
        dataset.lineWidth = 2.0
        dataset.circleRadius = 3.0
        dataset.setColor(Colors.darkGray)
        dataset.setCircleColor(Colors.gray)
        dataset.drawValuesEnabled = true
        return dataset
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
