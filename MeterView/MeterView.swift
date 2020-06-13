//
//  MeterView.swift
//  MeterView
//
//  Created by Tanin on 13/06/2020.
//

import SwiftUI

extension Animation {
    static func shaking(while expression: Bool) -> Animation {
        Animation.default
            .speed(4)
            .repeat(while: expression)
    }

    func `repeat`(while expression: Bool, autoreverses: Bool = true) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
    
    static func gaugeIntertia() -> Animation {
        Animation.default
            .speed(0.5)
    }
}

/// A gauge view
///
/// example:
///
///     Meter(
///         progress: 100,
///         marks: [20, 40, 60, 80],
///         markThickness: 0.001,
///         gaugeArcPortion: 0.85,
///         gaugeArcThickness: 20)
///
/// - Properties:
///   - progress: The progress of the gauge. Value range of 0-100.
///   - marks: Speed marks on the gauge.
///   - markThickness: Thickness of the mark on the gauge arc. Value range of 0-1. A mark is usually as small as 0.001.
///   - stopColorSpectrum: Color spectrum on the gauge arc to indicate progress
///   - gaugeArcPortion: The portion of the arc length in a full circle. Value range of 0-1.
///   - gaugeArcThickness: Thickness of the arc.
///   - indicatorColor:
///   - indicatorHandLength:
///   - indicatorHandWidth:
///   - indicatorKnobDiameter:
///   - frameSideLength:
struct MeterView<Content: View>: View {
    
    /// scale of 1-100
    var progress : CGFloat
    var marks: [CGFloat] = []
    var markThickness: CGFloat = 0.001
    
    var stopColorSpectrum: [(Color, CGFloat)] = [(Color.red, 30), (Color.yellow, 60), (Color.green, 90)]
    
    /// must be at least 0.5
    var gaugeArcPortion: CGFloat = 0.6
    var gaugeArcThickness: CGFloat = 30

    var indicatorColor: Color = Color(.red)
    var indicatorHandLength: CGFloat = 120
    var indicatorHandWidth: CGFloat = 2
    var indicatorKnobDiameter: CGFloat = 10

    var frameSideLength: CGFloat = 280
    
    var shakingPoint: CGFloat = 95
    
    var isAnimationOn = true
    
    var middleGaugeContent: () -> Content = {EmptyView() as! Content}
    
        
    var body: some View{
    
        GeometryReader { geo in
            ZStack{
                
                // speed spectrum
                MeterSpeedSpectrum(
                    progress: self.progress,
                    marks: self.marks,
                    markThickness: self.markThickness,
                    gaugeStartingDegree: self.gaugeStartingDegree(),
                    getPointInZeroToOneScale: self.getPointInZeroToOneScale(_:),
                    stopColorInGradients: self.stopColorInGradients(),
                    gaugeArcPortion: self.gaugeArcPortion,
                    gaugeArcThickness: self.gaugeArcThickness,
                    frameSideLength: self.frameSideLength,
                    shakingPoint: self.shakingPoint,
                    isAnimationOn: self.isAnimationOn)
                
                // indicator
                ZStack(alignment: .bottom) {
                    self.indicatorColor
                        .frame(
                            width: self.indicatorHandWidth,
                            height: self.indicatorHandLength)

                    Circle()
                        .fill(self.indicatorColor)
                        .frame(
                            width: self.indicatorKnobDiameter,
                            height: self.indicatorKnobDiameter)
                }
                // Offset the frame to make the center of the circle the rotation anchor
                // ((Indicator hand height) / 2 - (indicator knob height) / 2) * -1
                .offset(y: -((self.indicatorHandLength/2) - (self.indicatorKnobDiameter/2)))
                .rotationEffect(.init(degrees: -90 + self.gaugeStartingDegree()))
                .rotationEffect(.init(degrees: self.getArrowPositionInDegrees()))
                .animation(self.isAnimationOn ? .gaugeIntertia() : .none)
             
                self.middleGaugeContent()
            }
            .meterFrame(geo: geo, frameSideLength: self.frameSideLength, gaugeArcPortion: self.gaugeArcPortion, gaugeArcThickness: self.gaugeArcThickness)
            .meterOffset(frameSideLength: self.frameSideLength, gaugeArcPortion: self.gaugeArcPortion, gaugeArcThickness: self.gaugeArcThickness)
        }
    
    }
    
    // TODO: These functions should probably be in a viewmodel
    func getPointInZeroToOneScale(_ progress: CGFloat) -> CGFloat{
        // set maxiumum
        let localProgress = progress.roundWithInRange(0, to: 100)
        let multiplier = gaugeArcPortion / 100
        return localProgress * multiplier
    }
    
    func getArrowPositionInDegrees() -> Double {
        // set maxiumum
        let localProgress = progress.roundWithInRange(0, to: 100)
        // find the progress value in the scale of the gauge curve length in degrees
        let multiplier = (360 * gaugeArcPortion) / 100
        return Double(localProgress * multiplier)
    }
    
    func gaugeStartingDegree() -> Double {
        guard gaugeArcPortion >= 0.5 else { fatalError() }
        let gaugeCurveLength: Double = (360 * Double(gaugeArcPortion))
        let hiddenCurveLength: Double = 360 - gaugeCurveLength
        let startingPoint: Double = (90 - (hiddenCurveLength/2)) * -1
        return startingPoint
    }

    func stopColorInGradients() -> [Gradient.Stop] {
        stopColorSpectrum.map { (color, percentage) -> Gradient.Stop in
            let loc: CGFloat = (percentage * (gaugeArcPortion/100)) - 0.03
            return .init(color: color, location: loc.roundWithInRange(0, to: 1))
        }
    }
}

struct MeterSpeedSpectrum: View {
    
    var progress : CGFloat
    var marks: [CGFloat] = []
    var markThickness: CGFloat = 0.001
    var gaugeStartingDegree: Double
    var getPointInZeroToOneScale: (CGFloat) -> CGFloat
    var stopColorInGradients: [Gradient.Stop]
    var gaugeArcPortion: CGFloat = 0.6
    var gaugeArcThickness: CGFloat
    var frameSideLength: CGFloat
    var shakingPoint: CGFloat
    var isAnimationOn = true
    
    var body: some View {
        ZStack{
                
            // gauge background half circle
            Circle()
                .rotation(.init(degrees: self.gaugeStartingDegree))
                .trim(from: 0, to: self.gaugeArcPortion)
                .stroke(Color(.systemGray4).opacity(0.5), lineWidth: self.gaugeArcThickness)
                .frame(
                    width: self.frameSideLength - self.gaugeArcThickness,
                    height: self.frameSideLength - self.gaugeArcThickness)
            
            Circle()
                .rotation(.init(degrees: gaugeStartingDegree))
                .trim(from: 0, to: getPointInZeroToOneScale(self.progress))
                .stroke(
                    AngularGradient(
                        gradient: .init(stops: stopColorInGradients),
                        center: .center,
                        angle: .init(degrees: gaugeStartingDegree)
                    ),
                    lineWidth: gaugeArcThickness)
                .frame(
                    width: frameSideLength - gaugeArcThickness,
                    height: frameSideLength - gaugeArcThickness)
            
            ForEach(marks, id: \.self) { mark in
                
                Circle()
                    .rotation(.init(degrees: self.gaugeStartingDegree))
                    .trim(
                        from: (self.getPointInZeroToOneScale(mark) - (self.markThickness/2)).roundWithInRange(0, to: 1),
                        to: (self.getPointInZeroToOneScale(mark) + (self.markThickness/2)).roundWithInRange(0, to: 1))
                    .stroke(Color(.systemGray), lineWidth: self.gaugeArcThickness)
                    .frame(
                        width: self.frameSideLength - self.gaugeArcThickness,
                        height: self.frameSideLength - self.gaugeArcThickness)
                
            }
            
        }
        .animation(isAnimationOn ? .gaugeIntertia() : .none)
        .rotationEffect(.init(degrees: 180))
        .animation(nil)
        .scaleEffect(self.progress > self.shakingPoint ? 1.01 : 1)
        .animation(.shaking(while: self.progress > self.shakingPoint))
        
    }
    
}

extension View {
    func meterFrame(
        geo: GeometryProxy,
        frameSideLength: CGFloat,
        gaugeArcPortion: CGFloat,
        gaugeArcThickness: CGFloat
    ) -> some View {
        let thicknessOffset = ((abs(0.5 - gaugeArcPortion))/2 * gaugeArcThickness)
        // the circle length comes down on both side, so we need to divide it by 2
        let missingBottomHalf = ((frameSideLength) * (1 - gaugeArcPortion)/2)
        let height = frameSideLength - missingBottomHalf - thicknessOffset
        return self.frame(width: geo.size.width, height: height)
    }
    
    func meterOffset(
        frameSideLength: CGFloat,
        gaugeArcPortion: CGFloat,
        gaugeArcThickness: CGFloat
    ) -> some View {
        let thicknessOffset = ((abs(0.5 - gaugeArcPortion))/2 * gaugeArcThickness)
        // the circle length comes down on both side, so we need to divide it by 2
        let missingBottomHalf = ((frameSideLength) * (1 - gaugeArcPortion)/2)
        return self.offset(y: missingBottomHalf - thicknessOffset)
    }
}

struct MeterView_Previews: PreviewProvider {
    static var previews: some View {
        
        MeterView(
            progress: 100,
            marks: [20, 40, 60, 80],
            markThickness: 0.01,
            gaugeArcPortion: 0.5,
            gaugeArcThickness: 20,
            indicatorHandWidth: 5,
            indicatorKnobDiameter: 20,
            frameSideLength: 350,
            middleGaugeContent: {Text("Hi")})
        
    }
}

extension CGFloat {
    func roundWithInRange(_ lowerBound: CGFloat, to upperBound: CGFloat) -> CGFloat {
        let result: CGFloat
        if self > upperBound {
            result = upperBound
        } else if self < lowerBound {
            result = lowerBound
        } else {
            result = self
        }
        return result
    }
}

extension Double {
    func roundWithInRange(_ lowerBound: Double, to upperBound: Double) -> Double {
        let result: Double
        if self > upperBound {
            result = upperBound
        } else if self < lowerBound {
            result = lowerBound
        } else {
            result = self
        }
        return result
    }
}

