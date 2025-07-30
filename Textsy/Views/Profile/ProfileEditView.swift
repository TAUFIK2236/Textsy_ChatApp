import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @State private var name = ""
    @State private var age = ""
    @State private var location = ""
    @State private var bio = ""
    @State private var profileImage: Image = Image("profile")

    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?

    var body: some View {
        NavigationStack {
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
                            // Placeholder: No logic here
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
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .onChange(of: inputImage) { _ in loadImage() }
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
    ProfileEditView()
        .preferredColorScheme(.dark)
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
