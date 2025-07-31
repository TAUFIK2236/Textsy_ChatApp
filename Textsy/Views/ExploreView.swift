import SwiftUI

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    @EnvironmentObject var session: UserSession
    @State private var selectedUser: UserModel? = nil
    @EnvironmentObject var appRouter: AppRouter
    var isFirstTime: Bool = false                    //ProfileEdit and Drawer identify  Flag
    @State private var isDrawerOpen: Bool = false

    
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack{
            VStack{
                if isFirstTime{
                            Text("Profile")
                                .font(.title.bold())
                                .foregroundColor(.white)

                    FloatingButton(icon:"arrow.right.to.line", backgroundColor:.blue){
                        appRouter.goToHome()
                    }
                    
                }else{
                    topBar(isDrawerOpen: $isDrawerOpen)
                }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.users) { user in
                            Button {
                                appRouter.goToUserProfile(id: user.id)
                                // selectedUser = user
                            } label: {
                                UserCardView(user: user)
                            }
                        }
                        
                    }
                    
                    .padding()
                }


            }                .blur(radius: isDrawerOpen ? 8 : 0)
            // 🔒 Background blur + close on tap
            if isDrawerOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation{
                            isDrawerOpen = false
                        }
                    }

                SideDrawerView(
                    isOpen: $isDrawerOpen,
                    currentPage: appRouter.currentPage,
                    goTo:{
                        page in withAnimation {
                            appRouter.currentPage = page
                            isDrawerOpen = false
                        }
                    },
                    onLogout: {
                        UserSession.shared.clear()
                        isDrawerOpen = false
                    },
                    onExit:{ exit(0)
                    }
                )
                .transition(.move(edge: .leading))
            }
        }
        .background(.appbar)
            .task {
                await viewModel.fetchOtherUsers(currentUserId: session.uid)
            }
            
        }
    }
}


private func topBar(isDrawerOpen: Binding<Bool>) -> some View {
    HStack {
        Button {
            isDrawerOpen.wrappedValue.toggle()
        } label: {
            Image(systemName: "line.3.horizontal")
                .font(.title.bold())
                .foregroundColor(.white)
        }

        Spacer()

        Text("Explore")
            .font(.title.bold())
            .foregroundColor(.white)

        Spacer()

        Image(systemName: "person.crop.circle")
            .font(.title.bold())
            .foregroundColor(.bgc)
//        Button {
//            // Future: Profile or settings
//        } label: {
//            Image(systemName: "person.crop.circle")
//                .font(.title.bold())
//                .foregroundColor(.white)
//        }
    }
    .padding(.bottom)
    .padding(.horizontal)
    .background(Color.bgc)
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
        .preferredColorScheme(.light)
        .environmentObject(UserSession.shared)

}

