//
//  TutorialView.swift
//  Kalkulacka
//
//  Created by Jan Hes on 13.08.2025.
//

import SwiftUI

struct TutorialView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPresented: Bool
    
    private let steps: [TutorialStep] = [
        TutorialStep(
            icon: "person.crop.circle.fill",
            iconColor: .blue,
            title: NSLocalizedString("tutorial_step_1", comment: ""),
            description: NSLocalizedString("tutorial_step_1_desc", comment: "")
        ),
        TutorialStep(
            icon: "cup.and.saucer.fill",
            iconColor: .orange,
            title: NSLocalizedString("tutorial_step_2", comment: ""),
            description: NSLocalizedString("tutorial_step_2_desc", comment: "")
        ),
        TutorialStep(
            icon: "pencil.and.list.clipboard",
            iconColor: .green,
            title: NSLocalizedString("tutorial_step_3", comment: ""),
            description: NSLocalizedString("tutorial_step_3_desc", comment: "")
        ),
        TutorialStep(
            icon: "star.fill",
            iconColor: .yellow,
            title: NSLocalizedString("tutorial_step_4", comment: ""),
            description: NSLocalizedString("tutorial_step_4_desc", comment: "")
        )
    ]
    
    var backgroundColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.1, green: 0.1, blue: 0.15),
                Color(red: 0.05, green: 0.1, blue: 0.15)
            ]
        } else {
            return [
                Color(red: 0.95, green: 0.92, blue: 0.99),
                Color(red: 0.92, green: 0.95, blue: 1.0)
            ]
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with Title
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text(NSLocalizedString("tutorial_title", comment: ""))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 32)
                .padding(.bottom, 24)
                .padding(.horizontal, 20)
                
                // Steps List
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(Array(steps.enumerated()), id: \.element.title) { index, step in
                            TutorialStepCardView(step: step, stepNumber: index + 1)
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
                        Text(NSLocalizedString("tutorial_close", comment: ""))
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

struct TutorialStepCardView: View {
    @Environment(\.colorScheme) var colorScheme
    let step: TutorialStep
    let stepNumber: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Step Number Circle
            ZStack {
                Circle()
                    .fill(step.iconColor.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                VStack(spacing: 2) {
                    Image(systemName: step.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(step.iconColor)
                    
                    Text("\(stepNumber)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(step.iconColor)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text(step.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(colorScheme == .dark ? .gray : .gray)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(colorScheme == .dark ? Color(white: 0.15) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct TutorialStep {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
}

#Preview {
    TutorialView(isPresented: .constant(true))
}
