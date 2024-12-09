//
//  MapViewModel.swift
//  SwiftMapWithCenterMarker
//
//  Created by Keita Nakashima on 2024/12/09.
//

import SwiftUI
import GoogleMaps

class MapViewModel: ObservableObject {
    @Published var centerCoordinate: CLLocationCoordinate2D?
    @Published var zoomLevel: Float = 15.0
    @Published var isTouchingMap: Bool = false
    var isInitialAppLaunch: Bool = true
    var shouldAnimateToDefaultZoom: Bool = false
}
