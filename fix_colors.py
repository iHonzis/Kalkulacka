import os

files = ["Kalkulacka/WhatsNewView.swift", "Kalkulacka/TutorialView.swift"]

for f in files:
    with open(f, 'r') as file:
        content = file.read()
    
    # Add @Environment(\.colorScheme) var colorScheme to the main view if not present
    if "@Environment(\\.colorScheme) var colorScheme" not in content:
        content = content.replace("@Binding var isPresented: Bool", "@Environment(\\.colorScheme) var colorScheme\n    @Binding var isPresented: Bool")
    
    # Add @Environment(\.colorScheme) var colorScheme to the card views
    if "struct FeatureCardView: View {" in content:
        content = content.replace("struct FeatureCardView: View {\n    let feature: WhatsNewFeature", "struct FeatureCardView: View {\n    @Environment(\\.colorScheme) var colorScheme\n    let feature: WhatsNewFeature")
    
    if "struct TutorialStepCardView: View {" in content:
        content = content.replace("struct TutorialStepCardView: View {\n    let step: TutorialStep\n    let stepNumber: Int", "struct TutorialStepCardView: View {\n    @Environment(\\.colorScheme) var colorScheme\n    let step: TutorialStep\n    let stepNumber: Int")

    # Replace hardcoded colors in card views with dynamic ones
    content = content.replace(".foregroundColor(.black)", ".foregroundColor(colorScheme == .dark ? .white : .black)")
    content = content.replace(".foregroundColor(.gray)", ".foregroundColor(colorScheme == .dark ? .gray : .gray)")
    content = content.replace(".background(Color.white)", ".background(colorScheme == .dark ? Color(white: 0.15) : Color.white)")
    
    with open(f, 'w') as file:
        file.write(content)
