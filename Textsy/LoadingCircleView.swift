import SwiftUI

struct LoadingCircleView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            ColorChangingSpinner()
        }
    }
}
