//
//  ListOfFoundDevices.swift
//  BluetoothConnector
//
//  Created by Alexis Schotte on 22/12/2023.
//

import SwiftUI

struct BluetoothDevicesView: View {
    @StateObject var bluetoothVM = BluetoothDevicesViewModel()
    @State private var scanning = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                
                HStack {
                    Spacer()
                    Image(systemName: scanning ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                        .font(.title)
                        .foregroundColor(scanning ? .blue : .gray)
                    Spacer()
                }
                
                if bluetoothVM.peripherals.isEmpty && scanning {
                    ProgressView()
                        .scaleEffect(CGSize(width: 2, height: 2))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List(bluetoothVM.peripherals, id: \.self) { peripheral in
                        VStack {
                            Text(peripheral.identifier.uuidString)
                                .font(.headline)
                            Text(peripheral.name ?? "unnamed")
                                .font(.subheadline)
                            Text(String(peripheral.state.rawValue))
                                .font(.subheadline)
                        }
                    }
                }
                
                HStack(spacing: 20) {
                    Button("Stop") {
                        withAnimation(.easeInOut(duration: 0.7)) {
                            scanning = false
                        }
                        bluetoothVM.stopSearchingDevices()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button("Start") {
                        withAnimation(.easeInOut(duration: 0.7)) {
                            scanning = true
                        }
                        bluetoothVM.startSearchingDevices()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
            .navigationTitle("Bluetooth Devices")
        }
    }
}

#Preview {
    BluetoothDevicesView()
}
