import SwiftUI

// MARK: - FILTER BUTTON COMPONENT
struct FilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let accentColor: Color
    var isDestructive: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(buttonForegroundColor)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(buttonForegroundColor)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(buttonBackgroundMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(buttonBorderColor, lineWidth: isSelected ? 1.5 : 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPressed = false
                    }
                }
        )
    }
    
    // MARK: - Computed Properties for Styling
    private var buttonBackgroundMaterial: some ShapeStyle {
        if isSelected {
            if isDestructive {
                return AnyShapeStyle(.red.opacity(0.15))
            } else {
                return AnyShapeStyle(accentColor.opacity(0.15))
            }
        } else {
            return AnyShapeStyle(.thinMaterial)
        }
    }
    
    private var buttonForegroundColor: Color {
        if isSelected {
            return isDestructive ? .red : accentColor
        } else {
            return .primary
        }
    }
    
    private var buttonBorderColor: Color {
        if isSelected {
            return isDestructive ? .red.opacity(0.3) : accentColor.opacity(0.3)
        } else {
            return .clear
        }
    }
}

// MARK: - PREVIEW
#Preview {
    VStack(spacing: 16) {
        // Filter buttons examples
        HStack(spacing: 12) {
            FilterButton(
                title: "Todas",
                icon: "line.3.horizontal.decrease.circle",
                isSelected: false,
                accentColor: .blue
            ) {
                print("All selected")
            }
            
            FilterButton(
                title: "Ingresos",
                icon: "arrow.down.circle",
                isSelected: true,
                accentColor: .blue
            ) {
                print("Income selected")
            }
            
            FilterButton(
                title: "Limpiar",
                icon: "xmark.circle.fill",
                isSelected: false,
                accentColor: .red,
                isDestructive: true
            ) {
                print("Clear selected")
            }
        }
        
        // Account filter example
        FilterButton(
            title: "Cuenta: Banco Principal",
            icon: "creditcard",
            isSelected: true,
            accentColor: .green
        ) {
            print("Account selected")
        }
        
        // Subscription filter example
        FilterButton(
            title: "Activas",
            icon: "bolt.badge.a",
            isSelected: true,
            accentColor: .orange
        ) {
            print("Active selected")
        }
    }
    .padding()
    .background(.ultraThinMaterial)
    .appTheme(AppTheme())
}
