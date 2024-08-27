import CoreBluetooth

class BluetoothHelper: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var centralManager: CBCentralManager! = nil
    private var peripheralToConnect: CBPeripheral?
    
    var onDeviceDiscovered: ((CBPeripheral) -> Void)?
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /// Bluetooth の状態が更新されたときに呼ばれるメソッド
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("<<< Powered On >>>")
            scanForDevices()
        }
        else {
            print("Bluetooth is not available.")
        }
    }
    
    /// デバイス発見時に呼ばれるメソッド
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name ?? "Unknown device") at \(RSSI)")
        
        onDeviceDiscovered?(peripheral)
        
        if let name = peripheral.name, name.contains("M5StickC") {
            centralManager.stopScan()
            peripheralToConnect = peripheral
            centralManager.connect(peripheral)
        }
    }
    
    /// デバイス接続時に呼ばれる
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("<<< Connected to device [\(peripheral.name ?? "Unknown device")] >>>")
        
        peripheralToConnect?.delegate = self
        peripheralToConnect?.discoverServices(nil)
    }
    
    /// デバイスをスキャン
    func scanForDevices() {
        print("<<< Start scan >>>")
        
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    /// サービスの取得時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        print("<<< Discovered services >>>")
        
        for service in peripheral.services! {
            print("<<< On Peripheral [\(peripheral.name ?? "Unknown device")] - [\(service.uuid)]")
        }
        
        peripheralToConnect?.discoverCharacteristics(nil, for: (peripheral.services?.first)!)
    }
    
    /// キャラクタリスティック取得時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        print("<<< Discovered characteristics >>>")
        
        for characteristic in service.characteristics! {
            print("<<< On Service [\(service.uuid)] - [\(characteristic.uuid)]")
        }
        
        if let characteristic = service.characteristics?.first {
            print("<<< Try read values >>>")
            
            peripheralToConnect?.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        print("<<< Received data >>>")
        
        let data = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)
        
        if let data = data {
            print("Data: [\(data)]")
        }
    }
}
