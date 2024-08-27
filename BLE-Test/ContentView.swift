import SwiftUI

struct ContentView: View {
    
    @State private var bluetoothHelper: BluetoothHelper!
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            bluetoothHelper = BluetoothHelper()
        }
    }
}

#Preview {
    ContentView()
}
