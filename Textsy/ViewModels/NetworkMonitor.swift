//
//  NetworkMonitor.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/25/25.
//


//
//  NetworkMonitor.swift
//  TodoApp
//
//  Created by Anika Tabasum on 7/12/25.
//


import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    private var monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected: Bool = true

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
    
    // manual retry in "Retry" button
    func retryConnection(completion: @escaping () -> Void = {}) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.checkConnectionNow()
            completion()
        }
    }

    // Auto retry every 5 (time is changable)seconds until connected
    func startAutoRetry() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            if !self.isConnected {
                self.checkConnectionNow()
            }
        }
    }



}