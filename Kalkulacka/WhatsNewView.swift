//
//  WhatsNewView.swift
//  Kalkulacka
//
//  Created by Jan Hes on 13.08.2025.
//

import SwiftUI

struct WhatsNewView: View {
    @Binding var isPresented: Bool
    
    private let features: [WhatsNewFeature] = [
        WhatsNewFeature(
            icon: "sparkles",
            iconColor: .blue,
            title: NSLocalizedString("feature_splash_screen", comment: ""),
            description: NSLocalizedString("feature_splash_screen_desc", comment: "")
        ),
        WhatsNewFeature(
            icon: "doc.on.doc.fill",
            iconColor: .green,
            title: NSLocalizedString("feature_duplicate_drink", comment: ""),
            description: NSLocalizedString("feature_duplicate_drink_desc", comment: "")
        ),
        WhatsNewFeature(
            icon: "book.fill",
            iconColor: .purple,
            title: NSLocalizedString("feature_tutorial_profile", comment: ""),
            description: NSLocalizedString("feature_tutorial_profile_desc", comment: "")
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.92, blue: 0.99),
                    Color(red: 0.92, green: 0.95, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with App Icon and Title
                VStack(spacing: 16) {
                    Image("AppIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .cornerRadius(20)
                        .shadow(radius: 8)
                    
                    VStack(spacing: 8) {
                        Text(NSLocalizedString("whats_new_title", comment: ""))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 32)
                .padding(.bottom, 24)
                .padding(.horizontal, 20)
                
                // Features List
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(features, id: \.title) { feature in
                            FeatureCardView(feature: feature)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                
                // Close Button
                VStack(spacing: 12) {
                    Button {
                        isPresented = false
                    } label: {
                        Text(NSLocalizedString("whats_new_close", comment: ""))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.8, green: 0.2, blue: 0.3),
                                        Color(red: 0.6, green: 0.1, blue: 0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
    }
}

struct FeatureCardView: View {
    let feature: WhatsNewFeature
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(feature.iconColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: feature.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(feature.iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(feature.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct WhatsNewFeature {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
}

#Preview {
    WhatsNewView(isPresented: .constant(true))
}
