import SwiftUI

struct WheelView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var rotation: Double = 0

    private let segments: [(Color, String)] = [
        (.red, "100"),
        (.blue, "200"),
        (.green, "300"),
        (.yellow, "CLUE")
    ]

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                ForEach(0..<segments.count, id: \.self) { index in
                    WheelSlice(startAngle: .degrees(Double(index)/Double(segments.count) * 360),
                               endAngle: .degrees(Double(index + 1)/Double(segments.count) * 360))
                        .fill(segments[index].0)
                }
                ForEach(0..<segments.count, id: \.self) { index in
                    Text(segments[index].1)
                        .font(.caption)
                        .foregroundColor(.black)
                        .rotationEffect(.degrees(-rotation))
                        .position(position(for: index))
                }
            }
            .frame(width: 200, height: 200)
            .rotationEffect(.degrees(rotation))

            Button("Spin") {
                let spinAmount = Double.random(in: 720...1440)
                withAnimation(.easeOut(duration: 2)) {
                    rotation += spinAmount
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    viewModel.spinWheel()
                }
            }
            .disabled(viewModel.phase == .spinning)
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }

    private func position(for index: Int) -> CGPoint {
        let angle = (Double(index) + 0.5) / Double(segments.count) * 2 * .pi
        let radius: Double = 70
        return CGPoint(x: 100 + radius * cos(angle), y: 100 + radius * sin(angle))
    }
}

struct WheelSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.midY))
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}
