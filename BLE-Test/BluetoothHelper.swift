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
            print("Powered On.")
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
        peripheralToConnect?.delegate = self
        peripheralToConnect?.discoverServices(nil)
    }
    
    /// デバイスをスキャン
    func scanForDevices() {
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    /// サービスの取得時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        peripheralToConnect?.discoverCharacteristics(nil, for: (peripheral.services?.first)!)
    }
    
    /// キャラクタリスティック取得時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        print("\(service.uuid)")
    }
}
