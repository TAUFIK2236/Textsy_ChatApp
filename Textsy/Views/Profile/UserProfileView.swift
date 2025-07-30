import SwiftUI

struct UserProfileView: View {
    let user: UserModel

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Profile Image
                    profileImageView
                        .frame(width: geometry.size.width * 0.4,
                               height: geometry.size.width * 0.4)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 10)
                        .padding(.top, 30)

                    // MARK: - Name + Age
                    Text("\(user.name), \(user.age)")
                        .font(.system(size: geometry.size.width * 0.06, weight: .bold))
                        .foregroundColor(.white)

                    // MARK: - Location
                    Text(user.location)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    // MARK: - Bio Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(user.bio)
                            .font(.body)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                   
                    .cornerRadius(16)
                    .padding(.horizontal, geometry.size.width * 0.08)
                    
                    Spacer()
                    Spacer()
                    // MARK: - Action Buttons (Static Icons)
                    HStack(spacing: 20) {
                        Button {
                            // ❤️ placeholder
                        } label: {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }

                        Button {
                            // 💬 placeholder
                        } label: {
                            Image(systemName: "message.fill")
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }

                        Button {
                            // ➕ placeholder
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 10)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
            }
            .background(Color(.bgc))
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Profile Image View
    private var profileImageView: some View {
        if let urlStr = user.profileImageUrl,
           let url = URL(string: urlStr),
           !urlStr.isEmpty {
            return AnyView(
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image("profile")
                        .resizable().scaledToFill()
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

// MARK: - Preview
#Preview("User Profile View - Clean") {
    let mockUser = UserModel([
        "name": "Zara",
        "age": 24,
        "location": "San Francisco",
        "bio": "Techie, traveler, and taco lover 🌮",
        "profileImageUrl": ""
    ], id: "mockUser123")

    return UserProfileView(user: mockUser)
        .preferredColorScheme(.light)
}
