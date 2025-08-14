import SwiftUI

struct AlertCardView: View {
    let title: String
    let message: String
    let dismissAction: () -> Void

    // tiny state to drive the entrance/exit animation
    @State private var show = false

    var body: some View {
        VStack(spacing: 20) { // slightly more space
            // Title
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)

            // Message – auto height!
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            // OK button
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    show = false
                }
                // run dismiss after the shrink finishes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    dismissAction()
                }
            }) {
                Text("OK")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(24) // increased from default
        .frame(minHeight: 180) // added to make card taller
        .background(Color(.fieldT))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal, 32) // more horizontal breathing room
        .scaleEffect(show ? 1.0 : 0.92)
        .opacity(show ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                show = true
            }
        }
        .onDisappear {
            show = false
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

#Preview("AlertCard – Longer") {
    AlertCardView(
        title: "Oops!",
        message: "This is a slightly longer alert card with more padding and a taller frame, so it feels more spacious and readable.",
        dismissAction: {}
    )
    .preferredColorScheme(.dark)
}
