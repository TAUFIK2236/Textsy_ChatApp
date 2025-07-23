//
//  ProfileView.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/18/25.
//


import SwiftUI

struct ProfileView: View {
    @State private var name = ""
    @State private var age = ""
    @State private var location = ""
    @State private var bio = ""
    @State private var profileImage: Image = Image("Anika") // Replace with user image
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @StateObject private var authVM = AuthViewModel.shared

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    
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
                            .offset(x: -5, y: -5)
                    }
                    .padding(.top, 30)

                    // MARK: - Editable Fields
                    VStack(spacing: 16) {
                        profileField(title: "Name", text: $name)
                        profileField(title: "Age", text: $age, keyboard: .numberPad)
                        profileField(title: "Location", text: $location)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Bio")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                            
                            TextEditor(text: $bio)
                                .frame(height: 100)
                                .padding(10)
                                .background(Color(.fieldT))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.08)

                    // MARK: - Save Button
                    Button(action: {
                        // TODO: Save changes to Firebase
                        Task{
                            await authVM.updateProfile(name: name, age:age, location: location, bio: bio)
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
            }
            .background(Color(.bgc))
            
            if authVM.isLoading{
                LoadingCircleView()
            }
            if authVM.showAlert , let msg = authVM.alertMessage{
                AlertCardView(title:"Notice", message:msg){
                    authVM.showAlert = false
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .onChange(of: inputImage) { _ in loadImage() }
        .task {
            authVM.isLoading = true
            authVM.fetchUserProfile()
            DispatchQueue.main.asyncAfter(deadline:.now() + 1.2){
                if let user = authVM.currentUser{
                    name = user.name
                    age = String(user.age)
                    location = user.location
                    bio = user.bio
                }
            }
        }
    }

    
    
    
    // MARK: - Helper UI Components
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

    // MARK: - Image Loader
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
    }
}

#Preview("Profile View - Dark") {
    ProfileView()
        .preferredColorScheme(.dark)
}







//import SwiftUI
import PhotosUI

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
