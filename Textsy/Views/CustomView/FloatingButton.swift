import SwiftUI

struct FloatingButton: View {
    var icon: String
    var backgroundColor: Color = .blue
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding()
                .background(backgroundColor)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
}
