import SwiftUI

struct UserProfileView: View {
    let user: UserProfile1

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Profile Image
                    Image(user.imageName)
                        .resizable()
                        .scaledToFill()
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
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .padding(.horizontal, geometry.size.width * 0.08)

                    // MARK: - Action Buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            // TODO: Like user
                        }) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }

                        Button(action: {
                            // TODO: Start chat
                        }) {
                            Image(systemName: "message.fill")
                                .foregroundColor(.blue)
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
}
#Preview("User Profile View - Dark") {
    UserProfileView(user: sampleUser1)
        .preferredColorScheme(.light)
}

struct UserProfile1: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let bio: String
    let location: String
    let imageName: String
}
//let sampleUser = UserProfile1(
//    name: "Kate",
//    age: 32,
//    bio: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", location: "Los Angeles, CA",
//    imageName: "kate_main"
//   // photos: ["kate1","kate2","kate3"]
//)
let sampleUser1 = UserProfile1(
    name: "Kate",
    age: 32,
    bio: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
    location: "Los Angeles, CA",
    imageName: "kate_main"
)
