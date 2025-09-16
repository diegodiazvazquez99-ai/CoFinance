import SwiftUI

// MARK: - ACCOUNT CARD VIEW
struct AccountCardView: View {
    let account: Account
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(account.colorValue)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: account.typeIcon)
                            .font(.title3)
                            .foregroundColor(.white)
                    )
                    .shadow(color: account.colorValue.opacity(0.3), radius: 6, x: 0, y: 3)
                Spacer()
                
                Text(account.type)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(account.colorValue.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                    .foregroundColor(account.colorValue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(account.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("$\(account.balance, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(account.balance >= 0 ? .primary : .red)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.ultraThinMaterial, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                onTap()
            }
        }
    }
}
