//
//  EmptyTransactionView.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI

struct EmptyTransactionView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No transactions yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Tap the + button to add your first transaction")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

#Preview {
    EmptyTransactionView()
}
