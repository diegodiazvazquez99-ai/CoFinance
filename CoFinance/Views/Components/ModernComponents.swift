import SwiftUI

// MARK: - MODERN BALANCE CARD (CORREGIDO)
struct ModernBalanceCard: View {
    let balance: Double
    @Environment(\.appTheme) private var theme
    @EnvironmentObject var settings: SettingsManager // ← USAR SettingsManager en lugar de currencyFormatter
    @State private var animateBalance = false
    @State private var showingDetails = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Balance Total")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    Text("Actualizado ahora")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                // Info button
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showingDetails.toggle()
                    }
                }) {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(theme.accentColor)
                }
            }
            
            // Balance amount
            VStack(spacing: 8) {
                Text(settings.formatCurrency(balance)) // ← CORREGIDO: usar settings
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        balance >= 0 ?
                        LinearGradient(colors: [.primary, theme.accentColor], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
                    )
                    .contentTransition(.numericText())
                    .scaleEffect(animateBalance ? 1.05 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: balance)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: animateBalance)
                
                // Trend indicator
                HStack(spacing: 8) {
                    Image(systemName: balance >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .foregroundColor(balance >= 0 ? .green : .red)
                        .font(.caption)
                        .symbolEffect(.bounce.up, options: .nonRepeating)
                    
                    Text(balance >= 0 ? "En crecimiento" : "Necesita atención")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .opacity(showingDetails ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: showingDetails)
            }
            
            // Progress bar (opcional)
            if showingDetails {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Objetivo mensual")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("75%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(theme.accentColor)
                    }
                    
                    ProgressView(value: 0.75)
                        .tint(theme.accentColor)
                        .scaleEffect(y: 1.5)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        
        // Background with gradient
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(.regularMaterial)
                
                // Animated gradient overlay
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                theme.accentColor.opacity(0.1),
                                theme.accentColor.opacity(0.05),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(animateBalance ? 0.5 : 0.2)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .stroke(.ultraThinMaterial, lineWidth: 1)
        )
        .shadow(
            color: theme.accentColor.opacity(0.2),
            radius: 15,
            x: 0,
            y: 8
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                animateBalance.toggle()
            }
        }
        .onChange(of: balance) { oldValue, newValue in
            if oldValue != newValue {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    animateBalance = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        animateBalance = false
                    }
                }
            }
        }
    }
}

// MARK: - MODERN ACCOUNT CARD (CORREGIDO)
struct ModernAccountCard: View {
    let account: Account
    let onTap: () -> Void
    @Environment(\.appTheme) private var theme
    @EnvironmentObject var settings: SettingsManager // ← AGREGADO
    @State private var isPressed = false
    @State private var hovering = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Enhanced icon with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [account.colorValue, account.colorValue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: account.typeIcon)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .symbolEffect(.bounce, options: .nonRepeating)
                    )
                    .shadow(color: account.colorValue.opacity(0.4), radius: 8, x: 0, y: 4)
                
                Spacer()
                
                Text(account.type)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        account.colorValue.opacity(0.2),
                        in: RoundedRectangle(cornerRadius: 8)
                    )
                    .foregroundColor(account.colorValue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(account.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .contentTransition(.opacity)
                
                Text(settings.formatCurrency(account.balance)) // ← CORREGIDO: usar settings
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(account.balance >= 0 ? .primary : .red)
                    .contentTransition(.numericText())
                    .animation(.smooth(duration: 0.6), value: account.balance)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        
        // Enhanced background with hover effects
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .fill(.thinMaterial)
                .stroke(.ultraThinMaterial, lineWidth: hovering ? 2 : 1)
                .shadow(
                    color: isPressed ? account.colorValue.opacity(0.4) : .black.opacity(0.1),
                    radius: isPressed ? 15 : 8,
                    x: 0,
                    y: isPressed ? 8 : 4
                )
        )
        
        // Smooth scaling and animations
        .scaleEffect(isPressed ? 0.95 : (hovering ? 1.02 : 1.0))
        .animation(.smooth(duration: 0.2), value: isPressed)
        .animation(.smooth(duration: 0.3), value: hovering)
        
        .onTapGesture {
            withAnimation(.smooth(duration: 0.1)) {
                isPressed = true
            }
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.smooth(duration: 0.2)) {
                    isPressed = false
                }
                onTap()
            }
        }
        .onHover { hovering in
            withAnimation(.smooth(duration: 0.2)) {
                self.hovering = hovering
            }
        }
        
        // Enhanced accessibility
        .accessibilityLabel("\(account.name), \(account.type), Balance: \(settings.formatCurrency(account.balance))")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double tap to view account details")
    }
}

// MARK: - FLOATING ACTION BUTTON (CORREGIDO)
struct ModernFloatingActionButton: View {
    let icon: String
    let action: () -> Void
    @Environment(\.appTheme) private var theme
    @State private var isPressed = false
    @State private var rotation: Double = 0
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Rotation animation
            withAnimation(.smooth(duration: 0.3)) {
                rotation += 45
            }
            
            action()
        }) {
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [theme.accentColor, theme.accentColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: theme.accentColor.opacity(0.4),
                            radius: isPressed ? 20 : 12,
                            x: 0,
                            y: isPressed ? 8 : 6
                        )
                )
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .rotationEffect(.degrees(rotation))
        .animation(.smooth(duration: 0.2), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        withAnimation(.smooth(duration: 0.1)) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.smooth(duration: 0.2)) {
                        isPressed = false
                    }
                }
        )
        .accessibilityLabel("Add new transaction")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - PREVIEW (VERSIÓN LIMPIA)
#Preview {
    VStack(spacing: 20) {
        ModernBalanceCard(balance: 12345.67)
        
        HStack(spacing: 16) {
            // ✨ VERSIÓN LIMPIA: Sin UUID manual
            ModernAccountCard(
                account: Account(
                    name: "Cuenta Principal",
                    type: "Banco",
                    balance: 5000.0,
                    color: "blue"
                )
            ) {
                print("Account tapped")
            }
            
            ModernAccountCard(
                account: Account(
                    name: "Tarjeta Crédito",
                    type: "Crédito",
                    balance: -1250.0,
                    color: "red"
                )
            ) {
                print("Credit card tapped")
            }
        }
        
        // 🚀 O usar los ejemplos predefinidos:
        HStack(spacing: 16) {
            ModernAccountCard(account: Account.examples[0]) {
                print("Example account 1 tapped")
            }
            
            ModernAccountCard(account: Account.examples[1]) {
                print("Example account 2 tapped")
            }
        }
        
        ModernFloatingActionButton(icon: "plus") {
            print("FAB tapped")
        }
    }
    .padding()
    .background(.ultraThinMaterial)
    .environmentObject(SettingsManager.shared)
    .appTheme(AppTheme())
}
