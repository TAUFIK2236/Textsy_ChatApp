import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
private var monitor = NWPathMonitor()
private let queue = DispatchQueue(label: "NetworkMonitor")


@Published var isConnected: Bool = true
    @Published var flashConnected: Bool = false
init() {
    monitor = NWPathMonitor()
    monitor.pathUpdateHandler = { path in
        DispatchQueue.main.async {
            self.isConnected = path.status == .satisfied
        }
    }
    monitor.start(queue: queue)
}
func checkConnectionNow() {
    monitor.cancel() // Cancel current watcher
    let newMonitor = NWPathMonitor()
    newMonitor.pathUpdateHandler = { path in
        DispatchQueue.main.async {
            self.isConnected = path.status == .satisfied
        }
    }
    newMonitor.start(queue: queue)
    self.monitor = newMonitor
    
}
//    if self.isConnected  == false {
//        self.flashConnected = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.flashConnected = false
//        }
//    }



func startAutoRetry() {
    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
        if !self.isConnected {
            self.checkConnectionNow()
        }

    }
}







}
