import SwiftUI

struct AlertCardView: View {
    let title: String
    let message: String
    let dismissAction: () -> Void

    // tiny state to drive the entrance/exit animation
    @State private var show = false

    var body: some View {
        VStack(spacing: 16) {
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
                // run  dismiss after the shrink finishes
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
        .padding()
        .background(Color(.fieldT)) //  app’s card color
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal)
        //  entrance “pop” + fade (height still auto)
        .scaleEffect(show ? 1.0 : 0.92)
        .opacity(show ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                show = true
            }
        }
        .onDisappear {
            // make sure it resets if removed
            show = false
        }
        // slide-from-top when inserted/removed by parent
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
