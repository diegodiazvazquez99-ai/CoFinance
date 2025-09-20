// DetailRow.swift
// Componente de fila de detalle

import SwiftUI

struct DetailRow: View {
let label: String
let value: String
var valueColor: Color = .primary
var icon: String? = nil

```
var body: some View {
    HStack {
        if let icon = icon {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)
        }
        
        Text(label)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        
        Spacer()
        
        Text(value)
            .font(.subheadline.bold())
            .foregroundStyle(valueColor)
            .multilineTextAlignment(.trailing)
    }
}
```

}