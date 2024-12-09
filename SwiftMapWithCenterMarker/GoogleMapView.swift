//
//  GoogleMapView.swift
//  SwiftMapWithCenterMarker
//
//  Created by Keita Nakashima on 2024/12/09.
//

import SwiftUI
import GoogleMaps

struct GoogleMapView: UIViewControllerRepresentable {
    @EnvironmentObject var mapViewModel: MapViewModel
    
    private let defaultZoomLevel: Float = 15.0
    
    func makeUIViewController(context: Context) -> GoogleMapViewController {
        let controller = GoogleMapViewController()
        controller.mapViewModel = mapViewModel
        return controller
    }
    
    func updateUIViewController(_ uiViewController: GoogleMapViewController, context: Context) {
        uiViewController.updateMapState()
    }
}

class GoogleMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var mapViewModel: MapViewModel!
    var defaultZoomLevel: Float = 19.0
    var currentLocation: CLLocationCoordinate2D?
    var overlayView: CustomMapOverlay!
    
    private var lastUpdateTime: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupOverlay()
        setupLocationManager()
    }
    
    func setupMapView() {
        mapView = GMSMapView()
        mapView.frame = self.view.bounds
        
        let mapInsets = UIEdgeInsets(top: 00.0, left: 0.0, bottom: 0.0, right: 0.0)
        mapView.padding = mapInsets

        let initialCamera = GMSCameraPosition.camera(
            withLatitude: mapViewModel.centerCoordinate?.latitude ?? 0,
            longitude: mapViewModel.centerCoordinate?.longitude ?? 0,
            zoom: mapViewModel.zoomLevel
        )
        mapView.camera = initialCamera
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let targetCamera = GMSCameraUpdate.setCamera(
                GMSCameraPosition.camera(
                    withLatitude: self.mapViewModel.centerCoordinate?.latitude ?? 0,
                    longitude: self.mapViewModel.centerCoordinate?.longitude ?? 0,
                    zoom: self.defaultZoomLevel
                )
            )
            self.mapView.animate(with: targetCamera)
        }
        
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        self.view.addSubview(mapView)
    }
    
    func setupOverlay() {
        overlayView = CustomMapOverlay(frame: self.view.bounds)
        overlayView.backgroundColor = .clear
        self.view.addSubview(overlayView)
    }
    
    func drawCustomLine() {
        guard let currentLocation = mapView.myLocation?.coordinate else { return }
        
        let centerLocation = mapView.camera.target
        
        let start = mapView.projection.point(for: currentLocation)
        let end = mapView.projection.point(for: centerLocation)
        
        overlayView.drawLine(from: start, to: end)
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func updateMapState() {

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate
        
        if mapViewModel.isInitialAppLaunch {
            // Uses current location only at first startup
            let camera = GMSCameraPosition.camera(withTarget: currentLocation!, zoom: mapViewModel.zoomLevel)
            mapView.animate(to: camera)
            
            mapViewModel.isInitialAppLaunch = false
            mapViewModel.centerCoordinate = currentLocation
        }
        
        drawCustomLine()
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        mapViewModel.isTouchingMap = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            mapViewModel.isTouchingMap = true
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        mapViewModel.centerCoordinate = position.target
        drawCustomLine()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        mapViewModel.isTouchingMap = false
        mapViewModel.centerCoordinate = position.target
        mapViewModel.zoomLevel = position.zoom
        drawCustomLine()
    }
}

class CustomMapOverlay: UIView {
    private var shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }
    
    private func setupLayer() {
        // Touch event disabled
        isUserInteractionEnabled = false
        
        // CAShapeLayer setting
        shapeLayer.strokeColor = UIColor.gray.cgColor
        shapeLayer.lineWidth = 3.0
        shapeLayer.lineDashPattern = [0, 5]
        shapeLayer.lineCap = .round
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        // Add Layer to view
        self.layer.addSublayer(shapeLayer)
    }
    
    func drawLine(from start: CGPoint, to end: CGPoint, offset: CGFloat = 10.0) {
        // Adjust the starting point so that it is not covered by the current location marker
        let adjustedStart = calculateOffsetPoint(from: start, to: end, offset: offset)
        
        let path = UIBezierPath()
        path.move(to: adjustedStart)
        path.addLine(to: end)
        shapeLayer.path = path.cgPath
    }
    
    private func calculateOffsetPoint(from start: CGPoint, to end: CGPoint, offset: CGFloat) -> CGPoint {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let distance = sqrt(dx * dx + dy * dy)
        
        guard distance != 0 else { return start }
        
        let ratio = offset / distance
        let adjustedX = start.x + dx * ratio
        let adjustedY = start.y + dy * ratio
        
        return CGPoint(x: adjustedX, y: adjustedY)
    }
}
