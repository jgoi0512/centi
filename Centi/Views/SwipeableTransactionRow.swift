//
//  SwipeableTransactionRow.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI

struct SwipeableTransactionRow: View {
    let transaction: Transactions
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var offset: CGSize = .zero
    @State private var isSwiped: Bool = false
    
    private let deleteButtonWidth: CGFloat = 80
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button (behind the transaction row)
            Button(action: {
                onDelete()
                withAnimation(.spring(response: 0.4)) {
                    offset = .zero
                    isSwiped = false
                }
            }) {
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .font(.title2)
                        Text("Delete")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .frame(width: deleteButtonWidth)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.red)
            
            // Transaction row (slides over the delete button)
            TransactionRow(transaction: transaction)
                .background(Color(.systemBackground))
                .contentShape(Rectangle())
                .onTapGesture {
                    if !isSwiped {
                        onTap()
                    }
                }
                .offset(x: offset.width)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let dragWidth = value.translation.width
                    
                    // Only allow leftward swipe (negative x)
                    if dragWidth < 0 {
                        offset = CGSize(width: max(dragWidth, -deleteButtonWidth), height: 0)
                    } else if isSwiped {
                        // Allow rightward swipe only if already swiped
                        offset = CGSize(width: min(dragWidth - deleteButtonWidth, 0), height: 0)
                    }
                }
                .onEnded { value in
                    withAnimation(.spring(response: 0.4)) {
                        if value.translation.width < -40 && !isSwiped {
                            // Swipe left to reveal delete
                            offset = CGSize(width: -deleteButtonWidth, height: 0)
                            isSwiped = true
                        } else if value.translation.width > 40 && isSwiped {
                            // Swipe right to hide delete
                            offset = .zero
                            isSwiped = false
                        } else {
                            // Snap back to current state
                            offset = isSwiped ? CGSize(width: -deleteButtonWidth, height: 0) : .zero
                        }
                    }
                }
        )
        .clipped()
        .onTapGesture {
            // Tap anywhere to close swipe if open
            if isSwiped {
                withAnimation(.spring(response: 0.4)) {
                    offset = .zero
                    isSwiped = false
                }
            }
        }
    }
}