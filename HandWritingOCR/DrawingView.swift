//
//  DrawingView.swift
//  HandWritingOCR
//
//  Created by Masashi Miyazaki on 6/16/16.
//  Copyright © 2016 Masashi Miyazaki. All rights reserved.
//

import Cocoa

class DrawingView: NSView {
    
    let penWidth:CGFloat = Constants.penWidth
    
    var paint:Bool = false
    var currentStrokePoints = [CGPoint]()
    var strokePointsStack = [Array<CGPoint>]()
    
    var delegate:AnyObject?
    
    func reset() {
        self.currentStrokePoints = [CGPoint]()
        self.strokePointsStack = [Array<CGPoint>]()
        self.needsDisplay = true
    }
    
    override func mouseDown(theEvent: NSEvent) {
        self.currentStrokePoints = []
        pushPoint(theEvent)
        self.needsDisplay = true
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        pushPoint(theEvent)
        self.needsDisplay = true
    }
    
    override func mouseUp(theEvent: NSEvent) {
        pushPoint(theEvent)
        self.strokePointsStack.append(self.currentStrokePoints)
        if self.delegate != nil {
            (delegate as? ViewController)?.lineDrawn(self)
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        NSColor.whiteColor().set()
        NSRectFill( dirtyRect );
        saveGState { ctx in
            CGContextBeginPath(ctx)
            // set stroke color
            CGContextSetStrokeColorWithColor(ctx,NSColor.blackColor().CGColor)
            // set line width
            CGContextSetLineWidth(ctx, self.penWidth)
            CGContextSetLineJoin(ctx, CGLineJoin.Round)
            CGContextSetLineCap(ctx, CGLineCap.Round)

            for var strokePoints in ([self.currentStrokePoints] + self.strokePointsStack) {
                // drow lines
                let numPoints = strokePoints.count
                if numPoints < 1 {
                    continue
                }
                CGContextMoveToPoint(ctx, strokePoints[0].x, strokePoints[0].y)
                if numPoints == 1 {
                    // Do nothing
                } else {
                    for i in 1...(numPoints - 1) {
                        CGContextAddLineToPoint(ctx, strokePoints[i].x, strokePoints[i].y)
                    }
                    CGContextStrokePath(ctx)
                }
            }
            CGContextDrawPath(ctx, CGPathDrawingMode.FillStroke)
        }
    }
    
    func pushPoint(theEvent : NSEvent) {
        currentStrokePoints.append(calcLocalPoint(theEvent))
    }
    
    func calcLocalPoint (theEvent: NSEvent) -> NSPoint {
        let event_location:NSPoint = theEvent.locationInWindow
        return self.convertPoint(event_location, fromView:nil)
    }
    
    var currentContext : CGContext? {
        get {
            return NSGraphicsContext.currentContext()?.CGContext
        }
    }
    
    func empty() -> Bool {
        return strokePointsStack.count == 0
    }
    
    func saveGState(drawStuff: (ctx:CGContextRef) -> ()) -> () {
        if let context = self.currentContext {
            CGContextSaveGState (context)
            drawStuff(ctx: context)
            CGContextRestoreGState (context)
        }
    }
}