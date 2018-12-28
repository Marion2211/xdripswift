import Foundation
import CoreBluetooth

final class CGMG4xDripTransmitter: BluetoothTransmitter, BluetoothTransmitterDelegate {
    func centralManagerD(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //TODO
    }
    
    
    // MARK: - properties
    
    /// uuid used for scanning, can be empty string, if empty string then scan all devices - only possible if app is in foreground
    let CBUUID_Advertisement_G4: String = "0000FFE0-0000-1000-8000-00805F9B34FB"
    /// service to be discovered
    let CBUUID_Service_G4: String = "0000FFE0-0000-1000-8000-00805F9B34FB"
    /// receive characteristic
    let CBUUID_ReceiveCharacteristic_G4: String = "0000FFE1-0000-1000-8000-00805F9B34Fb"
    /// write characteristic
    let CBUUID_WriteCharacteristic_G4: String = "0000FFE1-0000-1000-8000-00805F9B34Fb"
    
    /// will be used to pass back bluetooth and cgm related events
    var cgmTransmitterDelegate:CGMTransmitterDelegate?
    
    // MARK: - functions
    
    init(addressAndName: CGMG4xDripTransmitter.G4DeviceAddressAndName, delegate:CGMTransmitterDelegate) {
        
        // assign addressname and name or expected devicename
        var newAddressAndName:BluetoothTransmitter.DeviceAddressAndName
        switch addressAndName {
        case .alreadyConnectedBefore(let newAddress, let newName):
            newAddressAndName = BluetoothTransmitter.DeviceAddressAndName.alreadyConnectedBefore(address: newAddress, name: newName)
        case .notYetConnected:
            newAddressAndName = BluetoothTransmitter.DeviceAddressAndName.notYetConnected(expectedName: nil)
        }
        
        //assign CGMTransmitterDelegate
        cgmTransmitterDelegate = delegate

        super.init(addressAndName: newAddressAndName, CBUUID_Advertisement: CBUUID_Advertisement_G4, CBUUID_Service: CBUUID_Service_G4, CBUUID_ReceiveCharacteristic: CBUUID_ReceiveCharacteristic_G4, CBUUID_WriteCharacteristic: CBUUID_WriteCharacteristic_G4)
        
        blueToothTransmitterDelegate = self
    }
    
    // MARK: - functions
    
    // MARK: - BluetoothTransmitterDelegate functions
    
    func peripheralD(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        //In Spike and iosxdripreader, a device connection completed is transmitted in this case
        cgmTransmitterDelegate?.cgmTransmitterdidConnect()
    }
    
    func peripheralD(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("hello")
    }
    
    func centralManagerDidUpdateStateD(_ central: CBCentralManager) {
        cgmTransmitterDelegate?.bluetooth(didUpdateState: central.state)
    }

    func peripheralD(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        //In Spike and iosxdripreader, a device connection completed is transmitted in this case
        cgmTransmitterDelegate?.cgmTransmitterdidConnect()
    }
    
    /// * if we never connected to a G4 bridge, then we don't know it's name and address as the Device itself is going to send.
    /// * If we already connected to a device before, then we know it's name and address
    enum G4DeviceAddressAndName {
        /// we already connected to the device so we should know the address and name as used by the device
        case alreadyConnectedBefore (address:String, name:String)
        /// * We never connected to the device, no need to send an expected device name
        case notYetConnected
    }
}
