import SwiftUI
import FirebaseCore

struct ChatCardView: View {
    let chat: ChatModel
    @EnvironmentObject var session: UserSession

    var body: some View {
        GeometryReader { geometry in
            let isWide = geometry.size.width > 400

            HStack(spacing: geometry.size.width * 0.03) { // spacing scales with width
                // Profile Image
                AsyncImage(url: URL(string: chat.profileImageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: geometry.size.width * 0.12, // scale profile size
                       height: geometry.size.width * 0.12)
                .clipShape(Circle())

                // Name + Last Message
                VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                    Text(
                        session.name == chat.senderName
                        ? chat.receiverName
                        : (session.name == chat.receiverName
                            ? chat.senderName
                           : chat.receiverName)
                    )
                        .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                        .foregroundColor(.color)

                    Text(chat.lastMessage)
                        .font(.system(size: geometry.size.width * 0.035))
                        .foregroundColor(.color.opacity(0.7))
                        .lineLimit(1)
                }

                Spacer()

                // Time + unread
                VStack(alignment: .trailing, spacing: geometry.size.height * 0.005) {
                    Text(fullDateTimeString(from: chat.timeStamp))
                        .font(.system(size: geometry.size.width * 0.028))
                        .foregroundColor(.color.opacity(0.8))

                    Text(timeAgoString(from: chat.timeStamp))
                        .font(.system(size: geometry.size.width * 0.028))
                        .foregroundColor(.gray)

                    if isWide {
                        Text("Online")
                            .font(.system(size: geometry.size.width * 0.028))
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(.vertical, geometry.size.height * 0.15)
            .padding(.horizontal)
            .frame(width: geometry.size.width)
        }
        .frame(height: 70)
    }

    private func fullDateTimeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func timeAgoString(from date: Date) -> String {
        let secondsAgo = Int(Date().timeIntervalSince(date))

        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour

        if secondsAgo < minute {
            return "Just now"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute)m ago"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour)h ago"
        } else {
            return "\(secondsAgo / day)d ago"
        }
    }
}
