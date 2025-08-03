//import SwiftUI
//import Foundation
//
//struct HomeView: View {
//    @StateObject private var viewModel = ChatViewModel()
//    @EnvironmentObject var appRouter: AppRouter
//   
//    @EnvironmentObject var session: UserSession
//    @State private var searchText = ""
//    @State private var isDrawerOpen = false
//
//    @State private var selectedChatUserId : String? = nil
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                GeometryReader { geometry in
//                    VStack(spacing: 0) {
//                        // 🔝 Custom top bar
//                        topBar
//
//                        VStack {
//                            searchBar
//                                .padding(.top, 15)
//                                .padding(.horizontal, 7)
//
//                            ScrollView {
//                                if !viewModel.errorMessage.isEmpty {
//                                    Text(viewModel.errorMessage)
//                                        .foregroundColor(.red)
//                                        .padding(.bottom, 10)
//                                }
//
//                                LazyVStack(spacing: 0) {
//                                    ForEach(filteredChats) { chat in
//                                        Button{
//                                            selectedChatUserId = chat.id
//                                            appRouter.goToChat(with: chat.id)
//                                        }Label:{
//                                            ChatCardView(chat: chat)}
//                                    }
//                                }
//                            }
//                        }
//                        .background(Color(.bgc))
//                        .cornerRadius(40)
//                        .frame(width: geometry.size.width, height: geometry.size.height * 2)
//                        .shadow(color: .sdc, radius: 10)
//                    }
//                }
//                .blur(radius: isDrawerOpen ? 8 : 0)
//                // 🔒 Background blur + close on tap
//                if isDrawerOpen {
//                    Color.black.opacity(0.4)
//                        .ignoresSafeArea()
//                        .onTapGesture {
//                            withAnimation{
//                                isDrawerOpen = false
//                            }
//                        }
//
//                    SideDrawerView(
//                        isOpen: $isDrawerOpen,
//                        currentPage: appRouter.currentPage,
//                        goTo:{
//                            page in withAnimation {
//                                appRouter.currentPage = page
//                                isDrawerOpen = false
//                            }
//                        },
//                        onLogout: {
//                            UserSession.shared.clear()
//                            isDrawerOpen = false
//                        },
//                        onExit:{ exit(0)
//                        }
//                    )
//                    .transition(.move(edge: .leading))
//                }
//            }
//            .background(.appbar)
//            .task {
//                await viewModel.fetchChats()
//            }
//        }
//    }
//
//    // MARK: - Top Bar
//    private var topBar: some View {
//        HStack {
//            Button {
//                isDrawerOpen.toggle()
//            } label: {
//                Image(systemName: "line.3.horizontal")
//                    .font(.title.bold())
//                    .foregroundColor(.white)
//            }
//
//            Spacer()
//
//            Text("Chats")
//                .font(.title.bold())
//                .foregroundColor(.white)
//
//            Spacer()
//
//            Button {
//                // Profile or settings icon
//            } label: {
//                Image(systemName: "person.crop.circle")
//                    .font(.title.bold())
//                    .foregroundColor(.white)
//            }
//        }
//        .padding(.bottom)
//        .padding(.horizontal)
//        .background(.appbar)
//    }
//
//    // MARK: - Search Bar
//    private var searchBar: some View {
//        HStack {
//            Image(systemName: "magnifyingglass")
//                .foregroundColor(.white)
//
//            TextField("Search", text: $searchText)
//                .foregroundColor(.white)
//        }
//        .padding(12)
//        .background(Color(.fieldT))
//        .cornerRadius(40)
//        .padding(.horizontal)
//        .padding(.vertical, 4)
//    }
//
//    // MARK: - Filtered Chats
//    private var filteredChats: [ChatModel] {
//        if searchText.isEmpty {
//            return viewModel.chats
//        } else {
//            return viewModel.chats.filter {
//                $0.userName.lowercased().contains(searchText.lowercased())
//            }
//        }
//    }
//}
//
//#Preview("Home View - Light Mode") {
//    HomeView()
//        .preferredColorScheme(.dark)
//        .environmentObject(UserSession.shared)
//        .environmentObject(AppRouter())
//}
import SwiftUI
import Foundation

struct HomeView: View {
    @StateObject private var viewModel = ChatViewModel()
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var session: UserSession

    @State private var searchText = ""
    @State private var isDrawerOpen = false

    // 📦 This holds which chat card was tapped
    @State private var selectedChatUserId: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        // 🔝 Top bar
                        topBar

                        VStack {
                            searchBar
                                .padding(.top, 15)
                                .padding(.horizontal, 7)

                            ScrollView {
                                if !viewModel.errorMessage.isEmpty {
                                    Text(viewModel.errorMessage)
                                        .foregroundColor(.red)
                                        .padding(.bottom, 10)
                                }

                                LazyVStack(spacing: 0) {
                                    ForEach(viewModel.chats) { chat in
                                        // 📬 Tap the card to open chat
                                        Button {
                                         //   selectedChatUserId = chat.id
                                            appRouter.goToChat(with: chat.id)
                                        } label: {
                                            ChatCardView(chat: chat)
                                        }
                                    }
                                }
                            }
                        }
                        .background(Color(.bgc))
                        .cornerRadius(40)
                        .frame(width: geometry.size.width, height: geometry.size.height * 2)
                        .shadow(color: .sdc, radius: 10)
                    }
                }
                .blur(radius: isDrawerOpen ? 8 : 0)

                // 🔒 Drawer
                if isDrawerOpen {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { isDrawerOpen = false }
                        }

                    SideDrawerView(
                        isOpen: $isDrawerOpen,
                        currentPage: appRouter.currentPage,
                        goTo: { page in
                            withAnimation {
                                appRouter.currentPage = page
                                isDrawerOpen = false
                            }
                        },
                        onLogout: {
                            UserSession.shared.clear()
                            isDrawerOpen = false
                        },
                        onExit: { exit(0) }
                    )
                    .transition(.move(edge: .leading))
                }
            }
            .background(.appbar)
            .onAppear {
                 viewModel.listenToChats(for: session.uid)
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button {
                isDrawerOpen.toggle()
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title.bold())
                    .foregroundColor(.white)
            }

            Spacer()

            Text("Chats")
                .font(.title.bold())
                .foregroundColor(.white)

            Spacer()

            Button {
                // Optional: profile/settings
            } label: {
                Image(systemName: "person.crop.circle")
                    .font(.title.bold())
                    .foregroundColor(.white)
            }
        }
        .padding(.bottom)
        .padding(.horizontal)
        .background(.appbar)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)

            TextField("Search", text: $searchText)
                .foregroundColor(.white)
        }
        .padding(12)
        .background(Color(.fieldT))
        .cornerRadius(40)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

//    // MARK: - Filtered Chats
//    private var filteredChats: [ChatModel] {
//        if searchText.isEmpty {
//            return viewModel.chats
//        } else {
//            return viewModel.chats.filter {
//                $0.userName.lowercased().contains(searchText.lowercased())
//            }
//        }
//    }
}

#Preview("Home View - Light Mode") {
    HomeView()
        .preferredColorScheme(.dark)
        .environmentObject(UserSession.shared)
        .environmentObject(AppRouter())
}
