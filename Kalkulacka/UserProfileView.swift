import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var drinkStore: DrinkStore
    
    @State private var age: Double = 25
    @State private var gender: Gender = .male
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var showAbout: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(NSLocalizedString("Personal Information", comment: "")) {
                    Picker(NSLocalizedString("Age", comment: ""), selection: $age) {
                        ForEach(16...122, id: \.self) { ageValue in
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
                
                // Feedback button section
                Section {
                    Button(NSLocalizedString("Report feedback", comment: "")) {
                        sendFeedbackEmail()
                    }
                    .foregroundColor(.accentColor)
                    
                    Button(NSLocalizedString("About", comment: "")) {
                        showAbout = true
                    }
                    .foregroundColor(.accentColor)
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Save", comment: "")) {
                        saveProfile()
                    }
                    .disabled(height.isEmpty || (Double(weight) ?? 0) <= 0)
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
    }
    
    private func sendFeedbackEmail() {
        let subject = "AlCaf feedback"
        let email = "hesja1@uhk.cz"
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject
        let urlString = "mailto:\(email)?subject=\(encodedSubject)"
        if let url = URL(string: urlString) {
            #if os(iOS)
            UIApplication.shared.open(url)
            #elseif os(macOS)
            NSWorkspace.shared.open(url)
            #endif
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
        guard ageValue >= 16 && ageValue <= 122,
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

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Alcohol Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(NSLocalizedString("Alcohol", comment: ""))
                            .font(.headline)
                        
                        Text(NSLocalizedString("This app uses Widmark's method to calculate blood alcohol content (BAC).", comment: ""))
                            .font(.body)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("Calculation:", comment: ""))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(NSLocalizedString("‰ BAC = (Volume × % Alcohol × 0.789) / (Body Weight × Constant) × 1000", comment: ""))
                                .font(.caption)
                                .italic()
                            
                            Text(NSLocalizedString("Where:", comment: ""))
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(NSLocalizedString("• Volume: Drink volume in ml", comment: ""))
                                Text(NSLocalizedString("• % Alcohol: Alcohol percentage of the drink", comment: ""))
                                Text(NSLocalizedString("• 0.789: Density of ethanol (g/cm³)", comment: ""))
                                Text(NSLocalizedString("• Body Weight: User's weight in kg", comment: ""))
                                Text(NSLocalizedString("• Constant: Proportion of water in the body (0.68 for males, 0.55 for females)", comment: ""))
                            }
                            .font(.caption)
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(NSLocalizedString("Sources:", comment: ""))
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 4) {
                                Text(NSLocalizedString("Kubička, J. 2011. Metody a principy měření alkoholu v těle. Theses.cz", comment: ""))
                                    .font(.caption2)
                                Spacer()
                                Link(NSLocalizedString("More", comment: ""), destination: URL(string: "https://theses.cz/id/m0kmef/BP.pdf") ?? URL(string: "https://theses.cz")!)
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack(spacing: 4) {
                                Text(NSLocalizedString("Searle, J. 2014. Alcohol calculations. Sagepub.com", comment: ""))
                                    .font(.caption2)
                                Spacer()
                                Link(NSLocalizedString("More", comment: ""), destination: URL(string: "https://journals.sagepub.com/doi/10.1177/0025802414524385") ?? URL(string: "https://journals.sagepub.com")!)
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Caffeine Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(NSLocalizedString("Caffeine", comment: ""))
                            .font(.headline)
                        
                        Text(NSLocalizedString("This app uses first-order kinetics to calculate caffeine metabolism, as caffeine is not eliminated linearly.", comment: ""))
                            .font(.body)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("Calculation:", comment: ""))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(NSLocalizedString("m(t) = m₀ × e^(-t × ln2 / t₁/₂)", comment: ""))
                                .font(.caption)
                                .italic()
                            
                            Text(NSLocalizedString("Where:", comment: ""))
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(NSLocalizedString("• m(t): Caffeine amount at time t", comment: ""))
                                Text(NSLocalizedString("• m₀: Initial caffeine amount in mg", comment: ""))
                                Text(NSLocalizedString("• t: Time elapsed in hours", comment: ""))
                                Text(NSLocalizedString("• t₁/₂: Half-life of caffeine (avg 5 hours, varies with age)", comment: ""))
                                Text(NSLocalizedString("• e: Euler's number (exponential decay)", comment: ""))
                            }
                            .font(.caption)
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(NSLocalizedString("Sources:", comment: ""))
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 4) {
                                Text(NSLocalizedString("Lávičková, K. 2021. Metabolismus kofeinu. Jcu.cz", comment: ""))
                                    .font(.caption2)
                                Spacer()
                                Link(NSLocalizedString("More", comment: ""), destination: URL(string: "https://dspace.jcu.cz/bitstream/handle/20.500.14390/44832/Lavickova_Katerina_2021_BP.pdf") ?? URL(string: "https://dspace.jcu.cz")!)
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack(spacing: 4) {
                                Text(NSLocalizedString("Ritter, F. E. & Yeh, M. 2011. Pharmacokinetics & Pharmacodynamics.", comment: ""))
                                    .font(.caption2)
                                Spacer()
                                Link(NSLocalizedString("More", comment: ""), destination: URL(string: "https://acs.ist.psu.edu/papers/ritterY11.pdf") ?? URL(string: "https://acs.ist.psu.edu")!)
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack(spacing: 4) {
                                Text(NSLocalizedString("McLean, A.J. & Le Couteur, D.G. 2004. Aging biology & pharmacology.", comment: ""))
                                    .font(.caption2)
                                Spacer()
                                Link(NSLocalizedString("More", comment: ""), destination: URL(string: "https://www.sciencedirect.com/science/article/abs/pii/S0031699724016120") ?? URL(string: "https://www.sciencedirect.com")!)
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("About", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Cancel", comment: "")) {
                        dismiss()
                    }
                }
            }
        }
    }
}
