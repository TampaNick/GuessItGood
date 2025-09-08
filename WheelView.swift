import SwiftUI

struct WheelView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var rotation: Double = 0

    private let segments: [(Color, String)] = [
        (.red, "100"),
        (.blue, "200"),
        (.green, "300"),
        (.yellow, "400"),
        (.orange, "500"),
        (.purple, "600"),
        (.pink, "700"),
        (.gray, "CLUE")
    ]

    var body: some View {
        GeometryReader { geometry in
            let fullSize = min(geometry.size.width, geometry.size.height) * 0.8
            let sideWidth = fullSize * 0.1
            let wheelSize = fullSize - sideWidth
            let pointerSize = sideWidth

            VStack(spacing: 20) {
                ZStack {
                    ZStack {
                        // Draw side band that continues each wedge color
                        ForEach(0..<segments.count, id: \.self) { index in
                            WheelSideSlice(startAngle: .degrees(Double(index)/Double(segments.count) * 360),
                                           endAngle: .degrees(Double(index + 1)/Double(segments.count) * 360),
                                           thickness: sideWidth)
                                .fill(segments[index].0)
                        }
                        // Draw top of wheel
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
                                    .position(position(for: index, in: wheelSize))
                            }
                        }
                        .frame(width: wheelSize, height: wheelSize)
                    }
                    .frame(width: fullSize, height: fullSize)
                    .rotationEffect(.degrees(rotation))

                    WheelPointer()
                        .fill(Color.black)
                        .frame(width: pointerSize, height: pointerSize)
                        .offset(y: -(fullSize / 2 + pointerSize / 2))
                }

                Button("Spin") {
                    viewModel.spinWheel()
                    let spinAmount = Double.random(in: 720...1440)
                    withAnimation(.easeOut(duration: 2)) {
                        rotation += spinAmount
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                        let normalized = rotation.truncatingRemainder(dividingBy: 360)
                        // Adjust for pointer orientation by adding 180 degrees
                        let adjusted = (360 - normalized + 270).truncatingRemainder(dividingBy: 360)
                        let segmentSize = 360.0 / Double(segments.count)
                        let index = Int(adjusted / segmentSize) % segments.count
                        let value = segments[index].1
                        let outcome: GameViewModel.WheelOutcome = value == "CLUE" ? .clue : .points(Int(value) ?? 0)
                        viewModel.handleWheelStop(outcome)
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
    }

    private func position(for index: Int, in size: CGFloat) -> CGPoint {
        let angle = (Double(index) + 0.5) / Double(segments.count) * 2 * .pi
        let radius = size * 0.35
        return CGPoint(
            x: size / 2 + radius * CGFloat(cos(angle)),
            y: size / 2 + radius * CGFloat(sin(angle))
        )
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

struct WheelSideSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let thickness: CGFloat

    func path(in rect: CGRect) -> Path {
        let outerRadius = rect.width / 2
        let innerRadius = outerRadius - thickness
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: outerRadius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: innerRadius,
                    startAngle: endAngle,
                    endAngle: startAngle,
                    clockwise: true)
        path.closeSubpath()
        return path
    }
}

struct WheelPointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
