//
//  VirtualDevice.swift
//  Unscroll
//
//  Created by Sebastian on 25/06/2026.
//

import Foundation
import CoreHID

final class VirtualDevice: HIDVirtualDeviceDelegate {
    let device: HIDVirtualDevice?
    
    init() {
        let mouseDescriptor = Data([
            0x05, 0x01,        // Usage Page (Generic Desktop)
            0x09, 0x02,        // Usage (Mouse)
            0xA1, 0x01,        // Collection (Application)

            0x09, 0x01,        //   Usage (Pointer)
            0xA1, 0x00,        //   Collection (Physical)

            // Buttons (3)
            0x05, 0x09,        //     Usage Page (Button)
            0x19, 0x01,        //     Usage Minimum (1)
            0x29, 0x03,        //     Usage Maximum (3)
            0x15, 0x00,        //     Logical Minimum (0)
            0x25, 0x01,        //     Logical Maximum (1)
            0x95, 0x03,        //     Report Count (3)
            0x75, 0x01,        //     Report Size (1)
            0x81, 0x02,        //     Input (Data,Var,Abs)

            // Padding
            0x95, 0x01,        //     Report Count (1)
            0x75, 0x05,        //     Report Size (5)
            0x81, 0x01,        //     Input (Const)

            // X, Y
            0x05, 0x01,        //     Usage Page (Generic Desktop)
            0x09, 0x30,        //     Usage (X)
            0x09, 0x31,        //     Usage (Y)
            0x15, 0x81,        //     Logical Minimum (-127)
            0x25, 0x7F,        //     Logical Maximum (127)
            0x75, 0x08,        //     Report Size (8)
            0x95, 0x02,        //     Report Count (2)
            0x81, 0x06,        //     Input (Data,Var,Rel)

            // Wheel
            0x09, 0x38,        //     Usage (Wheel)
            0x15, 0x81,        //     Logical Minimum (-127)
            0x25, 0x7F,        //     Logical Maximum (127)
            0x75, 0x08,        //     Report Size (8)
            0x95, 0x01,        //     Report Count (1)
            0x81, 0x06,        //     Input (Data,Var,Rel)

            0xC0,              //   End Collection
            0xC0               // End Collection
        ])
        
        let properties = HIDVirtualDevice.Properties(
            descriptor: mouseDescriptor,
            vendorID: 1452,
            productID: 2
        )
        
        guard let device = HIDVirtualDevice(properties: properties) else {
            self.device = nil
            print("Device not created")
            return
        }
        
        self.device = device
    }
    
    func activate() async {
        guard let device else {
            print("Device not available")
            return
        }
        print("Activating device")
        await device.activate(delegate: self)
        print("Device activated")
    }
    
    func hidVirtualDevice(_ device: HIDVirtualDevice, receivedSetReportRequestOfType type: HIDReportType, id: HIDReportID?, data: Data) throws {
        print("Device received a set report request for report type:\(type) id:\(String(describing: id)) with data:[\(data.map { String(format: "%02x", $0) }.joined(separator: " "))]")
    }
    
    
    // A handler for system requests to query data from the device.
    func hidVirtualDevice(
        _ device: HIDVirtualDevice,
        receivedGetReportRequestOfType type: HIDReportType,
        id: HIDReportID?,
        maxSize: size_t
    ) throws -> Data {

        print("GetReport type=\(type) id=\(String(describing: id)) maxSize=\(maxSize)")

        switch type {
        case .input:
            return Data([0, 0, 0, 0])

        case .feature:
            return Data()

        case .output:
            return Data()

        @unknown default:
            return Data()
        }
    }
    
    func scroll(_ amount: Int8) async {
        guard let device else { return }

        let report = Data([
            0x00,                           // buttons
            0x00,                           // x
            0x00,                           // y
            UInt8(bitPattern: amount)       // wheel
        ])

        do {
            try await device.dispatchInputReport(data: report, timestamp: .now)
        } catch {
            print("Failed to dispatch report:", error)
        }
    }
    
    func scrollUp(lines: Int8 = 1) async {
        await scroll(lines)
    }

    func scrollDown(lines: Int8 = 1) async {
        await scroll(-lines)
    }
}
