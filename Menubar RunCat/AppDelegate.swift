//
//  AppDelegate.swift
//  Menubar RunCat
//
//  Created by Takuto Nakamura on 2019/08/06.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let nc = NSWorkspace.shared.notificationCenter
    private var frames = [NSImage]()
    private var cnt: Int = 0
    private var isRunning: Bool = false
    private var interval: Double = 1.0
    private let cpu = CPU()
    private var cpuTimer: Timer? = nil
    private var usage: (value: Double, description: String) = (0.0, "")
    private var isShowUsage: Bool = false
  private var pinger: SwiftyPing? = nil
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        for i in (0 ..< 5) {
            frames.append(NSImage(imageLiteralResourceName: "cat_page\(i)"))
        }
        statusItem.menu = menu
        statusItem.button?.imagePosition = .imageRight
        statusItem.button?.image = frames[cnt]
        cnt = (cnt + 1) % frames.count
        
        startRunning()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        stopRunning()
    }
    
    func setNotifications() {
        nc.addObserver(self, selector: #selector(AppDelegate.receiveSleepNote),
                       name: NSWorkspace.willSleepNotification, object: nil)
        nc.addObserver(self, selector: #selector(AppDelegate.receiveWakeNote),
                       name: NSWorkspace.didWakeNotification, object: nil)
    }
    
    @objc func receiveSleepNote() {
        stopRunning()
    }
    
    @objc func receiveWakeNote() {
        startRunning()
    }
    
    func startRunning() {
      guard let gwIP = Network.gatewayIP() else {return}
      
      cpuTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (t) in
        let once = try? SwiftyPing(host: gwIP, configuration: PingConfiguration(interval: 0.5, with: 5), queue: DispatchQueue.global())
        once?.observer = { (response) in
          let duration = response.duration
          self.usage = (duration * 1000, String(format: "%.2f", duration * 1000) + "ms")
        }
        once?.targetCount = 1
        try? once?.startPinging()
        let value = log2(self.usage.value + 4)
        
        self.interval = 0.02 * (10 * min(10, value)) / 6
        self.statusItem.button?.title = self.isShowUsage ? self.usage.description : ""
      })
      cpuTimer?.fire()
      isRunning = true
      animate()
    }
    
    func stopRunning() {
        isRunning = false
        cpuTimer?.invalidate()
    }

    func animate() {
        statusItem.button?.image = frames[cnt]
        cnt = (cnt + 1) % frames.count
        if !isRunning { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval) {
            self.animate()
        }
    }
    
    @IBAction func toggleShowUsage(_ sender: NSMenuItem) {
        isShowUsage = sender.state == .off
        sender.state = isShowUsage ? .on : .off
        statusItem.button?.title = isShowUsage ? usage.description : ""
    }
    
    @IBAction func showAbout(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }

}

