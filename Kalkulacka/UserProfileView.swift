import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var drinkStore: DrinkStore
    
    @State private var age: Double = 25
    @State private var gender: Gender = .male
    @State private var weight: String = ""
    @State private var height: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(NSLocalizedString("Personal Information", comment: "")) {
                    Picker(NSLocalizedString("Age", comment: ""), selection: $age) {
                        ForEach(18...122, id: \.self) { ageValue in
                            Text("\(ageValue) \(NSLocalizedString("years", comment: ""))")
                                .tag(Double(ageValue))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker(NSLocalizedString("Gender", comment: ""), selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.localizedName).tag(gender)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(NSLocalizedString("Physical Measurements", comment: "")) {
                    HStack {
                        Text(NSLocalizedString("Weight", comment: ""))
                        Spacer()
                        TextField(NSLocalizedString("Weight", comment: ""), text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("kg")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(NSLocalizedString("Height", comment: ""))
                        Spacer()
                        TextField(NSLocalizedString("Height", comment: ""), text: $height)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("cm")
                            .foregroundColor(.secondary)
                    }
                }
                
                if let bmi = calculateBMI() {
                    Section(NSLocalizedString("Health Information", comment: "")) {
                        HStack {
                            Text(NSLocalizedString("BMI", comment: ""))
                            Spacer()
                            Text(String(format: "%.1f", bmi))
                                .foregroundColor(bmiColor(bmi))
                        }
                        
                        HStack {
                            Text(NSLocalizedString("BMI Category", comment: ""))
                            Spacer()
                            Text(bmiCategory(bmi))
                                .foregroundColor(bmiColor(bmi))
                        }
                    }
                }
                
                Section {
                    Button(NSLocalizedString("Save Profile", comment: "")) {
                        saveProfile()
                    }
                    .disabled(height.isEmpty || (Double(weight) ?? 0) <= 0)
                }
            }
            .navigationTitle(NSLocalizedString("My Profile", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("Cancel", comment: "")) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
        }
    }
    
    private func loadCurrentProfile() {
        let profile = drinkStore.userProfile
        age = Double(profile.age)
        gender = profile.gender
        weight = String(format: "%.1f", profile.weight)
        height = String(format: "%.1f", profile.height)
    }
    
    private func saveProfile() {
        // Validate required input
        let ageValue = Int(age)
        guard ageValue >= 18 && ageValue <= 122,
              let heightValue = Double(height), heightValue > 0, heightValue < 300 else {
            return
        }
        
        // Handle optional weight
        let weightValue: Double
        let trimmedWeight = weight.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedWeight.isEmpty {
            weightValue = 70.0 // Default weight if empty
        } else {
            if let parsedWeight = Double(trimmedWeight), parsedWeight > 0, parsedWeight < 500 {
                weightValue = parsedWeight
            } else {
                weightValue = 70.0 // Default if invalid (<=0 or too large)
            }
        }
        
        let newProfile = UserProfile(
            age: ageValue,
            gender: gender,
            weight: weightValue,
            height: heightValue
        )
        
        // Update the profile in the drink store
        drinkStore.updateUserProfile(newProfile)
        
        // Dismiss the view immediately
        dismiss()
    }
    
    private func calculateBMI() -> Double? {
        guard let weightValue = Double(weight),
              let heightValue = Double(height) else { return nil }
        
        let heightInMeters = heightValue / 100.0
        return weightValue / (heightInMeters * heightInMeters)
    }
    
    private func bmiCategory(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5:
            return NSLocalizedString("Underweight", comment: "")
        case 18.5..<25:
            return NSLocalizedString("Normal", comment: "")
        case 25..<30:
            return NSLocalizedString("Overweight", comment: "")
        default:
            return NSLocalizedString("Obese", comment: "")
        }
    }
    
    private func bmiColor(_ bmi: Double) -> Color {
        switch bmi {
        case ..<18.5:
            return .orange
        case 18.5..<25:
            return .green
        case 25..<30:
            return .orange
        default:
            return .red
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(drinkStore: DrinkStore())
    }
} 