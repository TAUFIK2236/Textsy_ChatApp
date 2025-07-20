//
//  HomeView.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/16/25.
//


// Views/HomeView.swift

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing:0) {
                    // Custom top bar
                    topBar

                    VStack{
                        searchBar
                            .padding(.top,15)
                            .padding(.horizontal,7)

                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(filteredChats) { chat in
                                    ChatCardView(chat: chat)
                                }
                            }
                        }
                    }
                    .background(Color(.bgc))
                    .cornerRadius(40)
                    .frame( width:geometry.size.width * 1,height: geometry.size.height * 2)
                    .shadow(color: .sdc, radius:10)
                }
                .background(.appbar)
               // .ignoresSafeArea(edges: .bottom)
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button {
                // Menu action
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title.bold())
                    .foregroundColor(.white)
            }

            Spacer()

            Text("Chats")
                .font(.title.bold())
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Spacer()

            Button {
                // Search icon action
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

    // MARK: - Search
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
    
    // Utils/RoundedCorner.swift

 

    struct RoundedCorner: Shape {
        var radius: CGFloat = 20
        var corners: UIRectCorner = [.topLeft, .topRight]

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            return Path(path.cgPath)
        }
    }




    // MARK: - Filtered Chats
    private var filteredChats: [ChatModel] {
        if searchText.isEmpty {
            return viewModel.chats
        } else {
            return viewModel.chats.filter {
                $0.userName.lowercased().contains(searchText.lowercased())
            }
        }
    }
}
#Preview("Home View - Light Mode") {
    HomeView()
        .preferredColorScheme(.dark)
}
