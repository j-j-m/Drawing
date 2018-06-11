//
//  AppDelegate.swift
//  Drawing-macOS
//
//  Created by Jacob Martin on 6/9/18.
//  Copyright © 2018 jjm. All rights reserved.
//

import Cocoa
import Metal
import DrawingKit_macOS


class AppDelegate: NSObject, NSApplicationDelegate {
    
    lazy var window: NSWindow = {
        let w = NSWindow(contentRect: NSMakeRect(10, 10, 1600, 900),
                                         styleMask: .resizable,
                                         backing: .buffered,
                                         defer: false)
        w.center()
        w.backgroundColor = NSColor(calibratedHue: 0, saturation: 1.0, brightness: 0, alpha: 0.7)
        return w
    }()
    
    lazy var windowController: NSWindowController = NSWindowController(window: window)
    
    var controller: DrawingViewController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if let device = MTLCreateSystemDefaultDevice(), let library = device.makeDefaultLibrary() {
            
            configureDrawingShaderLibrary(library: library, device: device)
        }
        
        windowController.loadWindow()
        
        controller = DrawingViewController()
        let content = window.contentView! as NSView
        let view = controller!.view
        view.frame = content.bounds
        
        content.addSubview(view)
        
        windowController.showWindow(nil)
    }
}
