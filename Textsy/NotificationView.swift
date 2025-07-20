//
//  NotificationView.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/18/25.
//


import SwiftUI

struct NotificationView: View {
    @State private var notifications: [NotificationItem] = sampleNotifications

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(notifications) { item in
                        Button {
                            // TODO: Navigate to UserProfileView(user: item.user)
                        } label: {
                            HStack(spacing: 12) {
                                Image(item.user.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.message)
                                        .foregroundColor(.white)
                                        .font(.body)

                                    Text(item.timestamp)
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.fieldT))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .background(Color(.bgc))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Notifications")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    // ✅ Change this to any color
                      
                }
            }

            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

import Foundation

struct NotificationItem: Identifiable {
    let id = UUID()
    let user: UserProfile1
    let message: String
    let timestamp: String
}

// Sample user + notifications
let sampleNotifications: [NotificationItem] = [
    NotificationItem(
        user: UserProfile1(name: "Alice", age: 22, bio: "Coffee + Code", location: "NY", imageName: "profile1"),
        message: "Alice sent you a message request",
        timestamp: "2 min ago"
    ),
    NotificationItem(
        user: UserProfile1(name: "Bob", age: 24, bio: "Music + Travel", location: "LA", imageName: "profile2"),
        message: "Bob accepted your request",
        timestamp: "10 min ago"
    )
]

#Preview("Notification View - Dark") {
    NotificationView()
        .preferredColorScheme(.dark )
}

