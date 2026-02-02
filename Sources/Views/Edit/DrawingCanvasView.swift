import SwiftUI
import PencilKit

struct DrawingCanvasView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var canvasView = PKCanvasView()

    var onSave: (UIImage) -> Void
    var onCancel: () -> Void

    var body: some View {
        DrawingCanvasRepresentable(canvasView: $canvasView)
            .navigationTitle("Add Drawing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(exportImage())
                        dismiss()
                    }
                }
            }
    }

    private func exportImage() -> UIImage {
        let bounds = canvasView.bounds
        let size = bounds.size == .zero ? CGSize(width: 1, height: 1) : bounds.size
        let drawingRect = CGRect(origin: .zero, size: size)
        let drawingImage = canvasView.drawing.image(from: drawingRect, scale: UIScreen.main.scale)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(drawingRect)
            drawingImage.draw(in: drawingRect)
        }
    }
}

struct DrawingCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .white
        canvasView.isOpaque = true
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvasView.becomeFirstResponder()
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
