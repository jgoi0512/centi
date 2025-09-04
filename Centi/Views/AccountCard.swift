//
//  AccountCard.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI

struct AccountCard: View {
    let account: Account
    
    var body: some View {
        HStack {
            Image(systemName: account.icon)
                .font(.title2)
                .foregroundColor(Color(account.color))
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color(account.color).opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.headline)
                
                Text(account.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(account.balance, specifier: "%.2f")")
                    .font(.headline)
                
                Text("Current Balance")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
//    AccountCard()
}
