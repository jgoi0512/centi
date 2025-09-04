//
//  EmptyAccountsVie.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI

struct EmptyAccountsView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "creditcard")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No accounts yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add your first account to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)

    }
}

#Preview {
    EmptyAccountsView()
}
