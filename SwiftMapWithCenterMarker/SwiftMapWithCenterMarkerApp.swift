//
//  SwiftMapWithCenterMarkerApp.swift
//  SwiftMapWithCenterMarker
//
//  Created by Keita Nakashima on 2024/12/09.
//

import SwiftUI
import GoogleMaps

@main
struct SwiftMapWithCenterMarkerApp: App {
    
    init() {
        GMSServices.provideAPIKey(Bundle.main.object(forInfoDictionaryKey: "GoogleApiKey") as! String)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
