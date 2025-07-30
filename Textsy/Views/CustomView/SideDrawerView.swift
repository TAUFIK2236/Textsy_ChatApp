//
//  SideDrawerView.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/25/25.
//


import SwiftUI

struct SideDrawerView: View {
 

    @Binding var isOpen: Bool

    var onSettings: () -> Void
    var onEditProfile: () -> Void
    var onExplore: () -> Void
    var onNotification: () -> Void
    var onLogout: () -> Void
    var onExit: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let drawerWidth = geometry.size.width * 0.65

            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    // App Name
                    Text("Textsy")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.sdc)

                    Text("Choose an option")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Divider()
                        .background(Color.gray.opacity(0.3))

                    // Functional Buttons
                    drawerButton(title: "Edit Profile", systemIcon: "person.crop.circle.badge", action: onEditProfile)
                    drawerButton(title: "Explore", systemIcon: "magnifyingglass", action: onExplore)
                    drawerButton(title: "Notifications", systemIcon: "bell.fill", action: onNotification)
                    drawerButton(title: "Settings", systemIcon: "gearshape.fill", action: onSettings)

                    Divider()
                        .padding(.vertical, 10)

                    // Logout & Exit
                    drawerButton(title: "Log Out", systemIcon: "arrow.backward.circle", action: onLogout, background: .gray)
                    drawerButton(title: "Exit", systemIcon: "xmark.circle", action: onExit, background: .gray)

                    Spacer()
                }
                .padding(.top, 50)
                .padding(.horizontal, 20)
                .frame(width: drawerWidth, height: geometry.size.height)
                
                .background(Color(.fieldT))
                .clipShape(RoundedCorner(radius: 30, corners: [.topRight, .bottomRight]))
                .shadow(color: .black.opacity(0.2), radius: 10)
                .offset(x: isOpen ? 0 : -drawerWidth)
                .animation(.easeInOut(duration: 0.5), value: isOpen)

                Spacer()
            }
        }
    }

    // MARK: - Reusable Drawer Button
    func drawerButton(title: String, systemIcon: String, action: @escaping () -> Void, background: Color = .gray.opacity(0.3)) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemIcon)
                    .foregroundColor(.white)
                    .font(.headline)

                Text(title)
                    .foregroundColor(.white)
                    .font(.title3.bold())

                Spacer()
            }
            .padding()
            .background(background)
            .cornerRadius(12)
        }
    }
}



#Preview("Side Drawer – Full Buttons") {
    SideDrawerPreviewWrapper()
        .preferredColorScheme(.light)
}

struct SideDrawerPreviewWrapper: View {
    @State private var isOpen = true

    var body: some View {
        ZStack {
            Color(.bgc).ignoresSafeArea()

            SideDrawerView(
                isOpen: $isOpen,
                onSettings: { print("⚙️ Settings") },
                onEditProfile: { print("✏️ Edit Profile") },
                onExplore: { print("🔍 Explore") },
                onNotification: { print("🔔 Notification") },
                onLogout: { print("🚪 Log Out") },
                onExit: { print("❌ Exit App") }
            )
        }
    }
}
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = []

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
