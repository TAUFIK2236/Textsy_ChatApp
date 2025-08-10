
import SwiftUI
import Foundation

struct HomeView: View {
    @StateObject private var viewModel = ChatViewModel()
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var session: UserSession
    @State private var filteredChats: [ChatModel] = []
    @State private var isSearching = false


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
                                
                                let chatList = isSearching ? filteredChats : viewModel.chats

                             
                                    if chatList.isEmpty {
                                        VStack(alignment:.center,spacing:10){
                                            Image("Nothing")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width:300,height:300)
                                            Text("Chat List is Empty !!!")
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                        }
                                        .frame(maxWidth:.infinity,maxHeight: .infinity)
                                        .padding(.top,70)
                                    } else {
                                        LazyVStack(spacing: 0) {
                                        ForEach(viewModel.chats) { chat in
                                            Button {
                                                appRouter.goToChat(with: chat.id)
                                            } label: {
                                                ChatCardView(chat: chat)
                                            }
                                        }
                                    }
                                }

                            }
                        }
                        .background(Color(.bgc))
                        .cornerRadius(40)
                        .frame(width: geometry.size.width, height: geometry.size.height * 2)
                        .shadow(color: .sdc, radius: 10)
                        .blur(radius: isDrawerOpen ? 8 : 0)
                    }
                }
                

                // 🔒 Drawer
                .overlay(
                    SideDrawerView(
                        isOpen: $isDrawerOpen,
                        currentPage: appRouter.currentPage,
                        goTo: { page in withAnimation { appRouter.currentPage = page; isDrawerOpen = false } },
                        onLogout: { UserSession.shared.clear(); isDrawerOpen = false },
                        onExit: { exit(0) }
                    )
                    .transition(.move(edge: .leading))
                    .animation(.easeInOut, value: isDrawerOpen)
                    .opacity(isDrawerOpen ? 1 : 0)
                )
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
                appRouter.goToUserProfile(id: session.uid)
                
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
                .onChange(of: searchText) { newValue in
                    if newValue.isEmpty {
                        isSearching = false
                        filteredChats = []
                    } else {
                        isSearching = true
                        filteredChats = viewModel.chats.filter { chat in
                            let nameMatch = chat.senderName.lowercased().contains(newValue.lowercased()) ||
                                            chat.receiverName.lowercased().contains(newValue.lowercased())
                            let messageMatch = chat.lastMessage.lowercased().contains(newValue.lowercased())
                            return nameMatch || messageMatch
                        }
                    }
                }

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isSearching = false
                    filteredChats = []
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
        }
        .padding(12)
        .background(Color(.fieldT))
        .cornerRadius(40)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }



}

#Preview("Home View - Light Mode") {
    HomeView()
        .preferredColorScheme(.dark)
        .environmentObject(UserSession.shared)
        .environmentObject(AppRouter())
}
