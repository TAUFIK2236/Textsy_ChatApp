import SwiftUI

struct AlertCardView: View {
    let title: String
    let message: String
    let dismissAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)

            Button(action: dismissAction) {
                Text("OK")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.fieldT))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
