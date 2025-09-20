// AccountMainCard.swift
// Tarjeta principal de cuenta (estilo tarjeta de crédito)

import SwiftUI

struct AccountMainCard: View {
let account: Account
@State private var isFlipped = false

```
var body: some View {
    VStack(spacing: 16) {
        // Diseño tipo tarjeta de crédito
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.bankName ?? "Banco")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(account.name ?? "Mi Cuenta")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
            
            Spacer()
            
            Image(systemName: getAccountIcon())
                .font(.largeTitle)
                .foregroundStyle(.white.opacity(0.9))
                .symbolRenderingMode(.hierarchical)
        }
        
        Spacer()
        
        // Chip de tarjeta
        if account.type == "Crédito" || account.type == "Débito" {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 50, height: 35)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                
                Spacer()
                
                // Contactless symbol
                Image(systemName: "wave.3.right")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        
        Spacer()
        
        VStack(alignment: .leading, spacing: 8) {
            if let accountNumber = account.accountNumber {
                Text("•••• •••• •••• \(accountNumber)")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))
                    .tracking(2)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Balance")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(account.balance.formatted(.currency(code: account.currency ?? "MXN")))
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }
                
                Spacer()
                
                if account.type == "Crédito", let creditLimit = account.creditLimit, creditLimit > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Disponible")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        Text((creditLimit - account.balance).formatted(.currency(code: account.currency ?? "MXN")))
                            .font(.headline)
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                    }
                }
            }
        }
    }
    .padding(20)
    .frame(height: 200)
    .frame(maxWidth: .infinity)
    .background(
        RoundedRectangle(cornerRadius: 16)
            .fill(cardGradient)
    )
    .overlay(
        // Patrón de tarjeta
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Líneas diagonales sutiles
                for i in stride(from: -height, through: width + height, by: 40) {
                    path.move(to: CGPoint(x: i, y: 0))
                    path.addLine(to: CGPoint(x: i + height, y: height))
                }
            }
            .stroke(
                LinearGradient(
                    colors: [.white.opacity(0.1), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 0.5
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    )
    .shadow(color: getAccountColor().opacity(0.4), radius: 12, y: 6)
    .rotation3DEffect(
        .degrees(isFlipped ? 180 : 0),
        axis: (x: 0, y: 1, z: 0)
    )
    .onTapGesture {
        withAnimation(.spring()) {
            isFlipped.toggle()
            HapticManager.shared.impact(.light)
        }
    }
}

private var cardGradient: LinearGradient {
    LinearGradient(
        colors: gradientColors,
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

private var gradientColors: [Color] {
    switch account.type {
    case "Débito":
        return [Color.blue, Color.blue.darker(by: 0.3)]
    case "Crédito":
        return [Color.purple, Color.purple.darker(by: 0.3)]
    case "Ahorros":
        return [Color.green, Color.green.darker(by: 0.3)]
    case "Inversión":
        return [Color.orange, Color.orange.darker(by: 0.3)]
    default:
        return [Color.gray, Color.gray.darker(by: 0.3)]
    }
}

private func getAccountIcon() -> String {
    switch account.type {
    case "Débito": return "creditcard"
    case "Crédito": return "creditcard.fill"
    case "Ahorros": return "piggybank.fill"
    case "Inversión": return "chart.line.uptrend.xyaxis"
    default: return "dollarsign.circle.fill"
    }
}

private func getAccountColor() -> Color {
    switch account.type {
    case "Débito": return .blue
    case "Crédito": return .purple
    case "Ahorros": return .green
    case "Inversión": return .orange
    default: return .gray
    }
}
```

}