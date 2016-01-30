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
    
    var historyChart: LineChartView
    var realtimeChart: LineChartView
    
    var views: [UIView] {
        return [historyChart, realtimeChart]
    }
    
    required init(realtimeChart: ChartViewBase, historyChart: ChartViewBase) {
        self.historyChart = historyChart as! LineChartView
        self.realtimeChart = realtimeChart as! LineChartView
        initRealtimeChart()
        beforeModeChanged()
    }
    
    func initHistoryChart() {
    }
    
    func initRealtimeChart() {
        self._initChart(realtimeChart)
        
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
    
    func _initChart(chart: LineChartView) {
        chart.descriptionText = "Herzfrequenz"
        chart.noDataTextDescription = "Es stehen keine Daten zur Verfügung"
        chart.pinchZoomEnabled = false
        chart.drawGridBackgroundEnabled = false
        chart.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
        
        let legend = chart.legend
        legend.position = ChartLegend.ChartLegendPosition.BelowChartLeft
        legend.form = ChartLegend.ChartLegendForm.Square
        legend.xEntrySpace = 2.0
    }
    
    func updateHistoryData(with measurements: [Measurement]) {
        return
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
