//
//  ImagePickerView.swift
//  ObjectDetection
//
//  Created by Sharan Thakur on 20/05/23.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {

    @Environment(\.presentationMode)
    var presentationMode

    @Binding var uiImage: UIImage
    
    var completionHandler: ((UIImage) -> Void)?

    func makeCoordinator() -> Coordinator {
        return Coordinator(
            presentationMode: presentationMode,
            image: $uiImage,
            onImagePickSuccess: completionHandler
        )
    }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ImagePicker>
    ) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>
    ) {
        
    }

}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @Binding var presentationMode: PresentationMode
    @Binding var image: UIImage
    var onImagePickSuccess: ((UIImage) -> Void)?

    init(presentationMode: Binding<PresentationMode>, image: Binding<UIImage>) {
        _presentationMode = presentationMode
        _image = image
    }
    
    init(
        presentationMode: Binding<PresentationMode>,
        image: Binding<UIImage>,
        onImagePickSuccess: ((UIImage) -> Void)?
    ) {
        _presentationMode = presentationMode
        _image = image
        self.onImagePickSuccess = onImagePickSuccess
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = uiImage
            DispatchQueue.global(qos: .background).async {
                self.onImagePickSuccess?(uiImage)
            }
        }
        presentationMode.dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        presentationMode.dismiss()
    }
}
