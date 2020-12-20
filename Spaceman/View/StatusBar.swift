//
//  StatusBar.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Cocoa
import Foundation
import SwiftUI
import Sparkle

class StatusBar {
    private let displays = CGSCopyManagedDisplaySpaces(_CGSDefaultConnection()) as! [NSDictionary]
    private let workspace = NSWorkspace.shared
    private let screens = NSScreen.screens
    @ObservedObject private var prefsVM = PreferencesViewModel()
    private let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let statusBarMenu = NSMenu()
    private var prefsWindow = PreferencesWindow()
    
    init() {
        let about = NSMenuItem()
        let aboutView = AboutView()
        let view = NSHostingView(rootView: aboutView)
        view.frame = NSRect(x: 0, y: 0, width: 220, height: 70)
        about.view = view
        
        prefsVM.loadData()
        var spaces = [NSMenuItem]()
        for space in prefsVM.sortedSpaceNamesDict {
            spaces.append(
                NSMenuItem(
                    title: String(space.value.spaceNum) + ": " + space.value.spaceName,
                    action: #selector(getSelectedSpace(_:)),
                    keyEquivalent: String(space.value.spaceNum))
            )
        }
        
        let updates = NSMenuItem(
            title: "Check for updates...",
            action: #selector(SUUpdater.checkForUpdates(_:)),
            keyEquivalent: "")
        updates.target = SUUpdater.shared()
        
        let pref = NSMenuItem(
            title: "Preferences...",
            action: #selector(showPreferencesWindow(_:)),
            keyEquivalent: "")
        pref.target = self
        
        let quit = NSMenuItem(
            title: "Quit Spaceman",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "")
        
        statusBarMenu.addItem(about)
        statusBarMenu.addItem(NSMenuItem.separator())
        for space in spaces {
            space.target = self
            statusBarMenu.addItem(space)
        }
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(updates)
        statusBarMenu.addItem(pref)
        statusBarMenu.addItem(quit)
        statusBarItem.menu = statusBarMenu
    }
    
    func updateStatusBar(withIcon icon: NSImage) {
        if let statusBarButton = statusBarItem.button {
            statusBarButton.image = icon
        }
    }
    
    @objc func showPreferencesWindow(_ sender: NSMenuItem) {
        prefsWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    @objc func getSelectedSpace(_ sender: NSMenuItem) {
        let selectedSpaceIndex = (Int(sender.keyEquivalent) ?? 1) - 1
        var allDisplays = [Display]()
        var allSpacesIds = [String]()
        print("Selected workspace: ", selectedSpaceIndex)
        for d in displays {
            let display = Display(
                            id: d["Display Identifier"] as? String ?? "",
                            currentSpace: d["Current Space"] as? [String: Any] ?? [String: Any](),
                            spaces: d["Spaces"] as? [[String: Any]] ?? [[String: Any]]()
                        )
            allDisplays.append(display)
//            print("Current Space UUIDs:")
//            print(display.currentSpace["uuid"] ?? "")
//            print("===========")
//            print("All Space UUIDs:")
            for space in display.spaces {
//                print(space["uuid"] ?? "")
                allSpacesIds.append((space["uuid"] ?? "") as! String)
            }
//            print("===========")
//            print("Display ID: " + display.id)
        }
        if (selectedSpaceIndex < allSpacesIds.count) {
            print("Selected workspace UUID: ", allSpacesIds[selectedSpaceIndex])
            switchWorkspace(spaceIndex: selectedSpaceIndex)
        }
    }
    
    func switchWorkspace(spaceIndex: Int) {
        print(spaceIndex)
    }
}

struct Display {
    var id: String
    var currentSpace: [String: Any]
    var spaces: [[String: Any]]
}
