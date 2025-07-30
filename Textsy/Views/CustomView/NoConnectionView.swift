import SwiftUI

struct NoConnectionView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var isRetrying = false

    var body: some View {
        ZStack {
            // Textsy background
            Color(.bgc)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // WiFi Icon
                Image(systemName: "wifi.slash")
                    .font(.system(size: 64))
                    .foregroundColor(.sdc)

                // Title
                Text("No Internet Connection")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                // Description
                Text("Please check your connection and try again.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                // Spinner or Retry button
                if isRetrying {
                    VStack(spacing: 8) {
                        ColorChangingSpinner()
                            .frame(width: 60, height: 60)
                            .padding(.top, 10)

                        Text("Retrying...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    Button(action: {
                        isRetrying = true
                        networkMonitor.retryConnection {
                            isRetrying = false
                        }
                    }) {
                        Text("Retry")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.sdc)
                            .cornerRadius(10)
                    }
                    .disabled(isRetrying)
                }
            }
            .padding()
        }
        .onAppear {
            networkMonitor.startAutoRetry()
        }
    }
}
