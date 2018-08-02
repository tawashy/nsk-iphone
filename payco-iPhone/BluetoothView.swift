//
//  BluetoothView.swift
//  payco-iPhone
//
//  Created by Yaser Tawash on 10/2/17.
//  Copyright © 2017 Yaser Tawash. All rights reserved.
//

import CoreBluetooth
import UIKit

class BluetoothView: UIViewController {
    var centralManager: CBCentralManager?
    var peripherals = Array<CBPeripheral>()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialise CoreBluetooth Central Manager
//        centralManager = CBCentralManager(delegate: self as? CBCentralManagerDelegate, queue: DispatchQueue.main, options: nil)
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
}

extension BluetoothView: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn){
            central.scanForPeripherals(withServices: nil, options: nil)
        }
        else {
            // do something like alert the user that ble is not on
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripherals.append(peripheral)
        tableView.reloadData()
    }
}

extension BluetoothView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        let peripheral = peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
}
