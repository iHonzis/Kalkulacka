import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var drinkStore: DrinkStore
    
    @State private var age: String = ""
    @State private var gender: Gender = .male
    @State private var weight: String = ""
    @State private var height: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    HStack {
                        Text("Age")
                        Spacer()
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("years")
                            .foregroundColor(.secondary)
                    }
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section("Physical Measurements") {
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("kg")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Height")
                        Spacer()
                        TextField("Height", text: $height)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("cm")
                            .foregroundColor(.secondary)
                    }
                }
                
                if let bmi = calculateBMI() {
                    Section("Health Information") {
                        HStack {
                            Text("BMI")
                            Spacer()
                            Text(String(format: "%.1f", bmi))
                                .foregroundColor(bmiColor(bmi))
                        }
                        
                        HStack {
                            Text("BMI Category")
                            Spacer()
                            Text(bmiCategory(bmi))
                                .foregroundColor(bmiColor(bmi))
                        }
                    }
                }
                
                Section {
                    Button("Save Profile") {
                        saveProfile()
                    }
                    .disabled(age.isEmpty || height.isEmpty || (Double(weight) ?? 0) <= 0)
                }
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
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
        age = String(profile.age)
        gender = profile.gender
        weight = String(format: "%.1f", profile.weight)
        height = String(format: "%.1f", profile.height)
    }
    
    private func saveProfile() {
        // Validate required input
        guard let ageValue = Int(age), ageValue > 0, ageValue < 150,
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
            return "Underweight"
        case 18.5..<25:
            return "Normal"
        case 25..<30:
            return "Overweight"
        default:
            return "Obese"
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