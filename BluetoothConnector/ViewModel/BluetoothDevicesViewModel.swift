//
//  BluetoothDevicesViewModel.swift
//  BluetoothConnector
//
//  Created by Alexis Schotte on 22/12/2023.
//

import Foundation
import CoreBluetooth
import Combine

@MainActor
final class BluetoothDevicesViewModel: ObservableObject {

    // Esse seria o identifier do aparelho desejado. Usei um headphone do meu filho de exemplo
    let idDevice = "B9816FB8-A2F7-7E93-DCB5-F27D268BF68D"
    let idDevices = [ "F2589FBA-DFB9-F206-EB40-D84D5E9CD980",
                      "9F2F59C2-A633-B0E6-D3ED-1DC7D62B4C33"
                      
    ]
//    let idDevices = [ "5B51EA4E-9853-BB27-A92E-2C2AD61D4BDE",
//                      "62815BD9-223D-47C0-8B1F-69F9E5169201",
//                      "82B439F8-F646-4F8C-9F7E-6DDF929E284E"
//    ]
    
    // Essas variáveis são publicadas para que quaisquer alterações sejam passadas à View
    @Published var state: CBManagerState = .unknown
    @Published var peripherals: [CBPeripheral] = []
    
    private var manager: BluetoothManager = .shared
    private var cancellables: Set<AnyCancellable> = .init()
    
    func startSearchingDevices() {
        cancellables.removeAll()
        peripherals.removeAll()
        // Está subscribing a var stateSubject, recebendo qualquer alteração na var e alterando a @Published var state. Está dentro de uma Task para trazer o resultado para main (foreground)
        manager.stateSubject
            .sink { [weak self] state in
                Task {
                    self?.state = state
                }
                switch state {
                case .unknown:
                    print("state unknown")
                case .resetting:
                    print("state resetting")
                case .unsupported:
                    print("state unsupported")
                case .unauthorized:
                    print("state unauthorized")
                case .poweredOff:
                    print("state poweredOff")
                case .poweredOn:
                    print("state poweredOn")
                default:
                    print("unknown")
                }
            }
            .store(in: &cancellables)
        
        // Está subscribing a var peripheralSubject do manager, recebendo qualquer alteração na var e alterando a @Published var peripherals. Está dentro de uma Task para trazer o resultado para main (foreground)
        manager.peripheralSubject
        // filtra valores repetidos (não seria necessário se usar o filtro do identificador
            .filter { [weak self] in self?.peripherals.contains($0) == false }
        // filtra para só identificar o aparelho com o id da var idDevice
            .filter{ $0.identifier.uuidString == self.idDevice }
        // filtra para os identificadores dos aparelhos com os ids do Array idDevices
//            .filter{ self.idDevices.contains($0.identifier.uuidString) }
            .sink { [weak self] peripheral in
                Task {
                    self?.peripherals.append(peripheral)
                    print(peripheral.identifier)
                }
            }
            .store(in: &cancellables)
        
        manager.startSearchingDevices()
    }
    
   
    func stopSearchingDevices() {
        manager.stopSearchingDevices()
    }
    
    func connect(_ peripheral: CBPeripheral) {
        manager.stopSearchingDevices()
//        peripheral.delegate = self
        manager.connect(peripheral)
    }
}
