//
//  ExploreView.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/18/25.
//

import Foundation
import SwiftUI

struct ExploreView: View {
    let users: [UserProfile] = sampleUsers // Replace later with Firebase data
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(users) { user in
                        Button {
                            // TODO: Navigate to UserProfileView
                        } label: {
                            UserCardView(user: user)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.bgc))
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}



struct UserCardView: View {
    let user: UserProfile

    var body: some View {
        VStack(spacing: 8) {
            Image("Logo1")
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(20)

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .foregroundColor(.white)
                    .font(.headline)

                Text("\(user.age) • \(user.bio)")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 10)
        }
        .background(Color(.fieldT))
        .cornerRadius(20)
        .shadow(color: .sdc.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}


struct UserProfile: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let bio: String
    let imageName: String // Use local image assets or URLs later
}

let sampleUsers: [UserProfile] = [
    UserProfile(name: "Alice", age: 22, bio: "Loves coffee & books", imageName: "profile1"),
    UserProfile(name: "Jake", age: 25, bio: "Gym & gaming", imageName: "profile2"),
    UserProfile(name: "Mia", age: 20, bio: "Beach vibes", imageName: "profile3"),
    UserProfile(name: "Noah", age: 24, bio: "Travel addict", imageName: "profile4"),
    UserProfile(name: "Sofia", age: 23, bio: "Dog mom 🐶", imageName: "profile5"),
    UserProfile(name: "Liam", age: 21, bio: "Just vibes", imageName: "profile6")
]


#Preview("ExploreView - Dark Mode") {
    ExploreView()
        .preferredColorScheme(.dark)
}
