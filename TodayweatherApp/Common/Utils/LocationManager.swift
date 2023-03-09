//
//  LocationManager.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/20.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    let locationManager = CLLocationManager()
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestCoordinate(completion: @escaping (_ coordinate: CLLocationCoordinate2D) -> Void) {
        guard CLLocationManager.locationServicesEnabled() else { return }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        guard let coordinate = locationManager.location?.coordinate else { return }
        completion(coordinate)
    }
    
    func requestOnlyLocation(completion: @escaping (_ coordinate: CLLocationCoordinate2D) -> Void) {
        guard let coordinate = locationManager.location?.coordinate else { return }
        completion(coordinate)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func checkUserDeviceLocationAuth() {
        checkUserCurrentLocationAuth(locationManager.authorizationStatus) { }
    }
    
    private func checkUserCurrentLocationAuth(_ authStatus: CLAuthorizationStatus, completionHandler: () -> Void) {
        switch authStatus {
        case .notDetermined:
            print("not Determined")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("restricted or denied, 아이폰 설정 유도")
        case .authorizedWhenInUse:
            print("when in use")
            locationManager.startUpdatingLocation()
            completionHandler()
        default:
            print("Default")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        
        checkUserCurrentLocationAuth(locationManager.authorizationStatus) { [weak self] in
            guard let self = self else { return }
            guard let coordinate = manager.location?.coordinate else { return }
            self.coordinate = coordinate
            NotificationCenter.default.post(name: .coordinate, object: coordinate)
        }
    }
    
    // 사용자 위치 변환 및 저장
    func checkUserCurrentLocation(_ coordinate: CLLocationCoordinate2D, completionHandler: @escaping (String, String) -> Void) {
        print(#function)
        
        let findLocation: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geoCoder: CLGeocoder = CLGeocoder()
        let local: Locale = Locale(identifier: "Ko-kr") // Korea
        
        geoCoder.reverseGeocodeLocation(findLocation, preferredLocale: local) { place, _ in
            if let address: [CLPlacemark] = place {
                let administrativeArea = address.last?.administrativeArea ?? "지역 오류"
                let subLocality = address.last?.subLocality ?? "지역 오류"
                
                completionHandler(administrativeArea, subLocality)
            }
        }
    }
}
