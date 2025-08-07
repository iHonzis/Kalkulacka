import SwiftUI

struct ActivityRingView: View {
    let progress: Double
    let maxValue: Double
    let color: Color
    let size: CGFloat
    
    private var percentage: Double {
        min(progress / maxValue, 1.0)
    }
    
    init(progress: Double, maxValue: Double, color: Color, size: CGFloat = 120) {
        self.progress = progress
        self.maxValue = maxValue
        self.color = color
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 12)
                .frame(width: size, height: size)
            
                // Progress ring
                Circle()
                    .trim(from: 0, to: percentage)
                    .stroke(
                        color,
                        style: StrokeStyle(
                            lineWidth: 12,
                            lineCap: .round
                        )
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: percentage)
            
            // Center content
            VStack(spacing: 4) {
                Text(String(format: "%.1f", progress))
                    .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                    Text(String(format: NSLocalizedString("of_max", comment: ""), Int(maxValue)))
                        .font(.system(size: size * 0.15, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
    }

struct ActivityRingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ActivityRingView(progress: 3.5, maxValue: 4.0, color: .red)
            ActivityRingView(progress: 180, maxValue: 400, color: .orange)
        }
        .padding()
    }
} 
