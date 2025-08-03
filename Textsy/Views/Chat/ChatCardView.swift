

import SwiftUI
import FirebaseCore

struct ChatCardView: View {
    let chat: ChatModel

    var body: some View {
        GeometryReader { geometry in
            let isWide = geometry.size.width > 400

            HStack(spacing: 12) {
                // Profile Image
                AsyncImage(url: URL(string: chat.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())

                // Name + Last Message
                VStack(alignment: .leading, spacing: 4) {
                    Text(chat.userName)
                        .font(.headline)
                        .foregroundColor(.color)

                    Text(chat.lastMessage ?? "Say Something....")
                        .font(.subheadline)
                        .foregroundColor(.color.opacity(0.7))
                        .lineLimit(1)
                }

                Spacer()

                // Time + unread
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formattedTime)
                        .font(.caption)
                        .foregroundColor(.color.opacity(0.8))

                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.caption2)
                            .padding(6)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }

                    // Extra info on wide screen
                    if isWide {
                        Text("Online")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .frame(width: geometry.size.width) // Make sure the card fills available space
        }
        .frame(height: 70) // Give GeometryReader a fixed height to avoid collapse
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: chat.timeStamp)
    }
}





//#Preview("Dark Mode - Large Width") {
//    ChatCardView(chat: ChatModel(
//        id: "2",
//        userName: "Jonathan Smith",
//        lastMessage: "I'll send the doc tomorrow.",
//        timeStamp: Date(),
//        profileImageURL: "https://randomuser.me/api/portraits/men/2.jpg",
//        unreadCount: 0
//    ))
//    .frame(width: 500, height: 70)
//    .preferredColorScheme(.dark)
//}
// i

//#Preview("Wide") {
//    ChatCardView(chat: ...)
//        .frame(width: 500, height: 70)
//}

