


import SwiftUI

// 🎏 A small sticky bar that appears at the very top of the app
struct ConnectivityBanner: View {
    @EnvironmentObject var net: NetworkMonitor

    var body: some View {
        VStack(spacing: 0) {
            // 🔴 offline banner
            if !net.isConnected {
                Text("No internet connection")
                    .font(.footnote.bold())
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.red.opacity(0.95))
                    .foregroundColor(.white)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // 🟢 briefly show when we come back online
//            if !net.flashConnected {
//                Text("Connected")
//                    .font(.footnote.bold())
//                    .frame(maxWidth: .infinity)
//                    .padding(8)
//                    .background(Color.green.opacity(0.95))
//                    .foregroundColor(.white)
//                    .transition(.move(edge: .top).combined(with: .opacity))
//            }

            Spacer() // pushes content to top
        }
        .onAppear{net.startAutoRetry()}
       // .ignoresSafeArea(edges: .top)
        .animation(.spring(), value: net.isConnected)
      //  .animation(.spring(), value: net.flashConnected)
    }
}

#Preview("Connectivity Banner") {
    // 1️⃣ Create a real NetworkMonitor instance
   // let mockMonitor = NetworkMonitor()

    // 2️⃣ Force its values for preview
 //   mockMonitor.isConnected = false          // Show red banner
   // mockMonitor.flashConnected = false       // Change to true to preview green banner

    // 3️⃣ Return the view with mock environment
    ConnectivityBanner()
        .environmentObject(NetworkMonitor())
        .previewLayout(.sizeThatFits)
}


