//
//  DetectBeaconController.swift
//  payco-iPhone
//
//  Created by Yaser Tawash on 10/3/17.
//  Copyright © 2017 Yaser Tawash. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class DetectBeaconController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var uuidLabel:UILabel!
    @IBOutlet weak var majorLabel:UILabel!
    @IBOutlet weak var minorLabel:UILabel!
    @IBOutlet weak var statusLable:UILabel!
    @IBOutlet weak var rangingButton:UIButton!
    
    var beaconRegion:CLBeaconRegion!
    var locationManager:CLLocationManager!
    
    var peripherals:[CLBeacon]!
    var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Main
    func initializeLocationManager(callback:(Bool) -> Void){
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            //Granted
            locationManager = CLLocationManager()
            locationManager.delegate = self
            
            let uuid = UUID(uuidString: "50DEF72D-B647-4341-9107-5154C15D5C82")! as UUID
            beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "com.agi.beacon")
            beaconRegion.notifyOnEntry = true
            beaconRegion.notifyOnExit = true
            
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startUpdatingLocation()
            callback(true)
        } else {
            //Request access
            callback(false)
        }
    }
    
    func toggleDiscovery(){
        if !isSearching {
            self.initializeLocationManager(callback: {
                (success) in
                if success {
                    isSearching = true
                } else {
                    locationManager.requestAlwaysAuthorization()
                }
            })
        } else {
            locationManager.stopMonitoring(for: beaconRegion)
            locationManager.stopRangingBeacons(in: beaconRegion)
            locationManager.stopUpdatingLocation()
            isSearching = false
        }
        
    }
    
    func updateStatusLabels(beacon:[CLBeacon]) {
        let beacon = beacon[0] as CLBeacon
        uuidLabel.text = beacon.proximityUUID.uuidString
        majorLabel.text = "Majort: \(beacon.major.stringValue)"
        minorLabel.text = "Minor: \(beacon.minor.stringValue)"
        
        let accuracy = String(format: "%.2f", beacon.accuracy)
        print(accuracy);
        statusLable.text = "Beacon Found is \(self.getProximityString(proximity: beacon.proximity)), it is \(accuracy)m away"
        uuidLabel.isHidden = false
        majorLabel.isHidden = false
        minorLabel.isHidden = false
    }
    
    func updateButtonTitle(){
        if isSearching {
            self.rangingButton.setTitle("Stop Ranging", for: .normal)
        } else {
            self.rangingButton.setTitle("Start Ranging", for: .normal)
        }
    }
    
    // MARK: Actions
    @IBAction func startButtonPressed(sender:Any){
        self.toggleDiscovery()
        self.updateButtonTitle()
        
    }
    
    
    // MARK: CLLocationManagerDelegate functions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            print("Authorized")
            break
        case .authorizedWhenInUse:
            break
        case .denied:
            print("Denied")
            break
        case .notDetermined:
            break
        case .restricted:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        locationManager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("LOCATION UPDATED: ",locations)
        if locations.count > 0 {
            if (peripherals != nil && peripherals.count > 0){
                updateStatusLabels(beacon: peripherals!)
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            locationManager.startRangingBeacons(in: beaconRegion)
        } else {
            locationManager.stopRangingBeacons(in: beaconRegion)
        }
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Beacon region entered: \(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Beacon region exited: \(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        //
        if beacons.count > 0 {
            peripherals = beacons
            self.updateStatusLabels(beacon: beacons)
            locationManager.stopRangingBeacons(in: region)
            self.updateButtonTitle()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("failed: \(error)")
    }
    
    // MARK: Helpers
    func getProximityString(proximity: CLProximity) -> String {
        switch proximity {
        case .immediate:
            return "Immediate"
        case .near:
            return "Near"
        case .far:
            return "Far"
        case .unknown:
            return "Unknown"
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
