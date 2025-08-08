import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    let isFromSignUp: Bool
    
    @State private var name = ""
    @State private var age = ""
    @State private var location = ""
    @State private var bio = ""
    @State private var profileImage: Image = Image("profile")
    @StateObject private var viewModel = UserProfileViewModel()
    @EnvironmentObject var session: UserSession
    @EnvironmentObject var appRouter : AppRouter
    @State private var isDrawerOpen: Bool = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
             ZStack{
                ScrollView {
                    VStack(spacing: 20) {
                        if isFromSignUp{
                            Text("Profile")
                                .font(.title.bold())
                                .foregroundColor(.white)
                        }else{
                            topBar(isDrawerOpen: $isDrawerOpen)
                        }
              
                        // MARK: - Profile Picture
                        ZStack(alignment: .bottomTrailing) {
                            profileImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width * 0.4,
                                       height: geometry.size.width * 0.4)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 10)
                                .onTapGesture {
                                    showingImagePicker = true
                                }
                            
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: -20, y: -10)
                        }
                        .padding(.top, 30)
                        
                        // MARK: - Editable Fields
                        VStack(spacing: 16) {
                            profileField(title: "Name", text: $name)
                            profileField(title: "Age", text: $age, keyboard: .numberPad)
                            profileField(title: "Location", text: $location)
                            profileField(title: "Bio", text: $bio)
                        }
                        .padding(.horizontal, geometry.size.width * 0.08)
                        
                        // MARK: - Save Button
                        Button(action: {
                            guard
                                !name.isEmpty,
                                let ageInt = Int(age),
                                !location.isEmpty,
                                !bio.isEmpty
                            else {
                                print("dont keep any thing Empty")
                                return
                            }
                            
                            Task {
                                await viewModel.saveUserProfile(
                                    name: name,
                                    age: ageInt,
                                    location: location,
                                    bio: bio,
                                    image: inputImage
                                )
                                
                                // ✅ Update session data
                                session.name = name
                                session.age = ageInt
                                session.location = location
                                session.bio = bio
                                
                                // ✅ Navigate to explore
                                withAnimation {
                                    if isFromSignUp{
                                        appRouter.currentPage = .exploraFirstTime
                                    }else{
                                        appRouter.currentPage = .home
                                    }
                                    
                                }
                            }
                        }) {
                            Text("Save Changes")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, geometry.size.width * 0.08)
                        
                        Spacer()
                    }
                    .padding(.bottom, 40)
                    .onAppear {
                        name = session.name
                        age = String(session.age)
                        location = session.location
                        bio = session.bio
                    }

                }
                .background(Color(.bgc))
            }
             .blur(radius: isDrawerOpen ? 8 : 0)
            .sheet(isPresented: $showingImagePicker) {ImagePicker(image: $inputImage)}
            .onChange(of: inputImage) { _ in loadImage() }
                
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
    }
}
    // MARK: - Field UI
    private func profileField(title: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .foregroundColor(.gray)
                .font(.subheadline)

            TextField(title, text: text)
                .padding()
                .background(Color(.fieldT))
                .cornerRadius(10)
                .foregroundColor(.white)
                .keyboardType(keyboard)
        }
    }

    // MARK: - Load Image
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
    }
}

// MARK: - Preview
#Preview("Profile View - Clean") {
    ProfileEditView( isFromSignUp:true)
        .preferredColorScheme(.dark)
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

        Text("Profile")
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



// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            picker.dismiss(animated: true)
        }
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
