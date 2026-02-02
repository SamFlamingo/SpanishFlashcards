import SwiftUI
import PencilKit

struct DrawingCanvasView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var canvasView = PKCanvasView()

    var onSave: (UIImage) -> Void

    var body: some View {
        DrawingCanvasRepresentable(canvasView: $canvasView)
            .navigationTitle("Add Drawing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
                        onSave(image)
                        dismiss()
                    }
                }
            }
    }
}

struct DrawingCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .secondarySystemBackground
        canvasView.isOpaque = true
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let toolPicker = PKToolPicker.shared(for: windowScene)
            toolPicker?.setVisible(true, forFirstResponder: canvasView)
            toolPicker?.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        }
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
