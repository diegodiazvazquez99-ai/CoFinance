// StatisticView.swift
// Vista de estadística

import SwiftUI

struct StatisticView: View {
let value: String
let label: String
let icon: String
let color: Color
var isLarge: Bool = false

```
var body: some View {
    VStack(spacing: 8) {
        Image(systemName: icon)
            .font(isLarge ? .title : .title2)
            .foregroundStyle(color)
            .symbolRenderingMode(.hierarchical)
        
        Text(value)
            .font(isLarge ? .title2.bold() : .headline)
            .contentTransition(.numericText())
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        
        Text(label)
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
    }
    .frame(maxWidth: .infinity)
    .padding(isLarge ? 16 : 12)
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(color.opacity(0.1))
    )
}
```

}