//
//  BluetoothManager.swift
//  BluetoothConnector
//
//  Created by Alexis Schotte on 22/12/2023.
//

import Foundation
import CoreBluetooth
import Combine

// Essa é a classe que vai efetivamente detectar o Bluetooth do aparelho
final class BluetoothManager: NSObject {
    
    // fiz uma singleton do Manager, mas pode ser Dependecy injection também
    static let shared = BluetoothManager()
    private override init() {}

    // first object you’ll need to instantiate to set up a Bluetooth connection. It handles monitoring the Bluetooth state of the device, scanning for Bluetooth peripherals, and connecting to and disconnecting from them.
    private var centralManager: CBCentralManager?
    
    // Essas variáveis vão passar as informações para o ViewModel (Combine)
    var stateSubject: PassthroughSubject<CBManagerState, Never> = .init()
    var peripheralSubject: PassthroughSubject<CBPeripheral, Never> = .init()
    
    
    func startSearchingDevices() {
        centralManager = CBCentralManager(delegate: self, queue: .global(qos: .background))
    }
    
    func stopSearchingDevices() {
        centralManager?.stopScan()
    }
    
    // TODO: próxima etapa a ser feita
    func connect(_ peripheral: CBPeripheral) {
        self.centralManager?.stopScan()
//        peripheral.delegate = self
        self.centralManager?.connect(peripheral)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: nil)
            stateSubject.send(central.state)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheralSubject.send(peripheral)
    }
}
