//
//  PieChartRow.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct PieChartRow : View {
    var data: [PieChartData]
    var labeledData: [(String, Double)]?
    var backgroundColor: Color
    var accentColor: Color
    var slices: [PieSlice] {
        var tempSlices:[PieSlice] = []
        var lastEndDeg:Double = 0
        let maxValue = data.map({
            $0.value
        }).reduce(0, +)
        for slice in data {
            let normalized:Double = Double(slice.value)/Double(maxValue)
            let startDeg = lastEndDeg
            let endDeg = lastEndDeg + (normalized * 360)
            lastEndDeg = endDeg
            tempSlices.append(PieSlice(startDeg: startDeg, endDeg: endDeg, value: slice.value, label: slice.label, normalizedValue: normalized))
        }
        return tempSlices
    }
    
    @Binding var showValue: Bool
    @Binding var currentValue: PieChartData
    
    @State private var currentTouchedIndex = -1 {
        didSet {
            if oldValue != currentTouchedIndex {
                showValue = currentTouchedIndex != -1
                currentValue = showValue ? PieChartData(label: slices[currentTouchedIndex].label, value: slices[currentTouchedIndex].value) : PieChartData(value: 0)
            }
        }
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack{
                if self.slices.count > 0 {
                    ForEach(0..<self.slices.count){ i in
                        PieChartCell(rect: geometry.frame(in: .local), startDeg: self.slices[i].startDeg, endDeg: self.slices[i].endDeg, index: i, backgroundColor: self.backgroundColor,accentColor: self.accentColor)
                            .scaleEffect(self.currentTouchedIndex == i ? 1.1 : 1)
                            .animation(Animation.spring())
                    }
                }
            }
            .gesture(DragGesture()
                        .onChanged({ value in
                            let rect = geometry.frame(in: .local)
                            let isTouchInPie = isPointInCircle(point: value.location, circleRect: rect)
                            if isTouchInPie {
                                let touchDegree = degree(for: value.location, inCircleRect: rect)
                                self.currentTouchedIndex = self.slices.firstIndex(where: { $0.startDeg < touchDegree && $0.endDeg > touchDegree }) ?? -1
                            } else {
                                self.currentTouchedIndex = -1
                            }
                        })
                        .onEnded({ value in
                            self.currentTouchedIndex = -1
                        }))
        }
    }
}

#if DEBUG
struct PieChartRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            PieChartRow(data:[PieChartData(value: 8), PieChartData(value: 23), PieChartData(value: 54), PieChartData(value: 32), PieChartData(value: 12), PieChartData(value: 37), PieChartData(value: 7), PieChartData(value: 23), PieChartData(value: 43)], backgroundColor: Color(red: 252.0/255.0, green: 236.0/255.0, blue: 234.0/255.0), accentColor: Color(red: 225.0/255.0, green: 97.0/255.0, blue: 76.0/255.0), showValue: Binding.constant(false), currentValue: Binding.constant(PieChartData(value: 0)))
                .frame(width: 100, height: 100)
            PieChartRow(data:[PieChartData(value: 0)], backgroundColor: Color(red: 252.0/255.0, green: 236.0/255.0, blue: 234.0/255.0), accentColor: Color(red: 225.0/255.0, green: 97.0/255.0, blue: 76.0/255.0), showValue: Binding.constant(false), currentValue: Binding.constant(PieChartData(value: 0)))
                .frame(width: 100, height: 100)
        }
    }
}
#endif
