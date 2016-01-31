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
        beforeModeChanged()
    }
    
    func initHistoryChart() {
        let chart = self.historyChart
        
        chart.descriptionText = "Herzfrequenz"
        chart.noDataTextDescription = "Es stehen keine Daten zur Verfügung"
        chart.drawGridBackgroundEnabled = false
        chart.drawBarShadowEnabled = false
        
        let rightAxis = chart.rightAxis
        rightAxis.enabled = false
        
        let leftAxis = chart.leftAxis
        leftAxis.drawGridLinesEnabled = false
    }
    
    func initRealtimeChart() {
        let chart = self.realtimeChart
        
        chart.descriptionText = "Herzfrequenz"
        chart.noDataTextDescription = "Es stehen keine Daten zur Verfügung"
        chart.pinchZoomEnabled = false
        chart.drawGridBackgroundEnabled = false
        chart.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
        
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
        let sorted = measurements.sort({ $0.date < $1.date })
        var binned: [[Measurement]] = [[Measurement]()]
        var last = sorted.first
        var newBin = [Measurement]()
        for current in sorted {
            let isSameDay = last!.date!.isSameDayAs(date: current.date!)
            if !isSameDay {
                binned.append([Measurement]())
            }
            var bin = binned.last!
            bin.append(current)
            last = current
        }

        let xValues = binned.flatMap({ $0[0].formattedDate })
        
        let data = CombinedChartData(xVals: xValues)
        data.lineData = self.createLineData(binned)
        data.barData = self.createBarData(binned)
        
        historyChart.data = data
        historyChart.notifyDataSetChanged()
    }
    
    func createLineData(measurements: [[Measurement]]) -> LineChartData {
        var entries = [ChartDataEntry]()
        let binCount = measurements.count
        for index in 0...binCount {
            let relevantMeasurements = measurements[index]
            let average = relevantMeasurements.averageHeartRate() ?? 0
            let entry = ChartDataEntry(value: average, xIndex: index)
            entries.append(entry)
        }
        let dataset = LineChartDataSet(yVals: entries)
        let data = LineChartData()
        data.addDataSet(dataset)
        return data
    }
    
    func createBarData(measurements: [[Measurement]]) -> BarChartData {
        var entries = [BarChartDataEntry]()
        let binCount = measurements.count
        for index in 0...binCount {
            let relevantMeasurements = measurements[index]
            let max = relevantMeasurements.maxHeartRate() ?? 0
            let entry = BarChartDataEntry(value: Double(max), xIndex: index)
            entries.append(entry)
        }
        let dataset = BarChartDataSet(yVals: entries)
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
