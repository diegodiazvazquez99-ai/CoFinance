// View+Extensions.swift
// Extensiones para View

import SwiftUI

// MARK: - Liquid Glass Modifiers (iOS 26)
extension View {
    func liquidGlassBackground() -> some View {
        self.background(
            Material.liquidGlass // Nuevo material en iOS 26
                .opacity(0.95)
                .blur(radius: 0.5)
        )
    }
    
    func liquidGlassToolbar() -> some View {
        self.background(
            Material.liquidGlass
                .ignoresSafeArea(edges: .top)
        )
    }
    
    /// Aplica efecto de brillo Liquid Glass
    func liquidGlassEffect() -> some View {
        self.modifier(LiquidGlassEffect())
    }
}

// MARK: - General View Extensions
extension View {
    /// Aplica esquinas redondeadas específicas
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    /// Oculta el teclado
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Aplica efecto de sacudida para errores
    func shake(times: Float = 2, amplitude: CGFloat = 5, duration: Double = 0.3) -> some View {
        self.modifier(ShakeEffect(times: times, amplitude: amplitude, duration: duration))
    }
    
    /// Añade efecto de haptic feedback
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: style)
            impact.impactOccurred()
        }
    }
    
    /// Tab bar adaptativa para iPad y iPhone
    func adaptiveTabBar() -> some View {
        self.modifier(AdaptiveTabBarModifier())
    }
}

// MARK: - Custom Shapes
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Shake Effect Modifier
struct ShakeEffect: ViewModifier {
    let times: Float
    let amplitude: CGFloat
    let duration: Double
    @State private var shake = false
    
    func body(content: Content) -> some View {
        content
            .offset(x: shake ? amplitude : 0)
            .animation(
                Animation.easeInOut(duration: duration / Double(times))
                    .repeatCount(Int(times), autoreverses: true),
                value: shake
            )
            .onAppear {
                shake = true
            }
    }
}

// MARK: - Liquid Glass Effect Modifier
struct LiquidGlassEffect: ViewModifier {
    @State private var shimmer = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .rotationEffect(.degrees(shimmer ? 0 : 45))
                .offset(x: shimmer ? 200 : -200)
                .animation(
                    Animation.linear(duration: 2)
                        .repeatForever(autoreverses: false),
                    value: shimmer
                )
                .mask(content)
            )
            .onAppear {
                shimmer = true
            }
    }
}

// MARK: - Adaptive Tab Bar Modifier
struct AdaptiveTabBarModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    func body(content: Content) -> some View {
        if horizontalSizeClass == .regular {
            // iPad: permitir transformación a sidebar
            content
                .tabViewStyle(.sidebarAdaptable) // iOS 18+
        } else {
            // iPhone: tab bar flotante
            content
                .tabViewStyle(.floatingBar) // iOS 26 Liquid Glass
        }
    }
}
