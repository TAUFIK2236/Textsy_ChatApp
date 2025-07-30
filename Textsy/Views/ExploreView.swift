import SwiftUI

struct ExploreView: View {
    // Sample users for preview/demo purposes
    let users: [UserModel] = [
        UserModel([
            "name": "Alice",
            "age": 22,
            "bio": "Loves coffee & books",
            "location": "NY",
            "profileImageUrl": ""
        ]),
        UserModel([
            "name": "Jake",
            "age": 25,
            "bio": "Gym & gaming",
            "location": "LA",
            "profileImageUrl": ""
        ])
    ]

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(users, id: \.name) { user in
                        Button {
                            // Navigation placeholder
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
    let user: UserModel

    var body: some View {
        VStack(spacing: 8) {
            profileImageView
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

    private var profileImageView: some View {
        if let urlStr = user.profileImageUrl,
           let url = URL(string: urlStr),
           !urlStr.isEmpty {
            return AnyView(
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image("profile")
                        .resizable()
                        .scaledToFill()
                }
            )
        } else {
            return AnyView(
                Image("profile")
                    .resizable()
                    .scaledToFill()
            )
        }
    }
}

#Preview("ExploreView - Dark Mode") {
    ExploreView()
        .preferredColorScheme(.dark)
}
