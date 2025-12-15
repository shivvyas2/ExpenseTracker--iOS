//
//  SignUpView.swift
//  ExpenseTracker
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingPassword = false
    @State private var showingConfirmPassword = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var passwordStrength: PasswordStrength = .none
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstName, lastName, email, password, confirmPassword
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        headerSection
                        inputFieldsSection
                        passwordStrengthIndicator
                        actionButtonsSection
                        socialSignupSection
                        loginLink
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Signup Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {
                errorMessage = ""
            }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: authViewModel.errorMessage) { newValue in
            if let error = newValue {
                errorMessage = error
                showingError = true
            }
        }
        .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
            // Signup successful - user is now authenticated
            // The app will automatically navigate to authenticated view
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Create your account")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 40)
            
            Text("Sign up to start managing your expenses and track your financial goals.")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 32)
    }
    
    private var inputFieldsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ModernTextField(
                    text: $firstName,
                    placeholder: "First name",
                    icon: "person",
                    keyboardType: .default,
                    autocapitalization: .words
                )
                .focused($focusedField, equals: .firstName)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .lastName
                }
                
                ModernTextField(
                    text: $lastName,
                    placeholder: "Last name",
                    icon: "person",
                    keyboardType: .default,
                    autocapitalization: .words
                )
                .focused($focusedField, equals: .lastName)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .email
                }
            }
            
            ModernTextField(
                text: $email,
                placeholder: "Email",
                icon: "envelope",
                keyboardType: .emailAddress,
                autocapitalization: .characters
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .password
            }
            
            Group {
                if showingPassword {
                    ModernTextField(
                        text: $password,
                        placeholder: "Password",
                        icon: "lock",
                        isSecure: false,
                        trailingIcon: "eye.slash",
                        onTrailingIconTap: {
                            showingPassword.toggle()
                        }
                    )
                } else {
                    ModernTextField(
                        text: $password,
                        placeholder: "Password",
                        icon: "lock",
                        isSecure: true,
                        trailingIcon: "eye",
                        onTrailingIconTap: {
                            showingPassword.toggle()
                        }
                    )
                }
            }
            .focused($focusedField, equals: .password)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .confirmPassword
            }
            .onChange(of: password) { _ in
                updatePasswordStrength()
            }
            
            Group {
                if showingConfirmPassword {
                    ModernTextField(
                        text: $confirmPassword,
                        placeholder: "Confirm password",
                        icon: "lock",
                        isSecure: false,
                        trailingIcon: "eye.slash",
                        onTrailingIconTap: {
                            showingConfirmPassword.toggle()
                        }
                    )
                } else {
                    ModernTextField(
                        text: $confirmPassword,
                        placeholder: "Confirm password",
                        icon: "lock",
                        isSecure: true,
                        trailingIcon: "eye",
                        onTrailingIconTap: {
                            showingConfirmPassword.toggle()
                        }
                    )
                }
            }
            .focused($focusedField, equals: .confirmPassword)
            .submitLabel(.go)
            .onSubmit {
                performSignup()
            }
        }
        .padding(.bottom, 16)
    }
    
    private var passwordStrengthIndicator: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !password.isEmpty {
                HStack(spacing: 4) {
                    ForEach(0..<4) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(passwordStrengthColor(for: index))
                            .frame(height: 4)
                    }
                }
                
                Text(passwordStrengthText)
                    .font(.system(size: 12))
                    .foregroundColor(passwordStrengthColor(for: 3))
            }
        }
        .padding(.bottom, 24)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: performSignup) {
                Text("Sign Up")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!isFormValid || authViewModel.isLoading)
        }
        .padding(.bottom, 32)
    }
    
    private var socialSignupSection: some View {
        VStack(spacing: 20) {
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                
                Text("Or sign up with")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
            
            HStack(spacing: 12) {
                SocialAccountButton(
                    icon: "apple.logo",
                    text: "Apple ID",
                    isApple: true
                ) {
                    authViewModel.signupWithApple()
                }
                
                SocialAccountButton(
                    icon: "",
                    text: "Google",
                    isGoogle: true
                ) {
                    authViewModel.signupWithGoogle()
                }
            }
        }
        .padding(.bottom, 32)
    }
    
    private var loginLink: some View {
        HStack {
            Text("Already have an account?")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            NavigationLink(destination: LoginView(authViewModel: authViewModel)) {
                Text("Sign in")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
            }
        }
        .padding(.bottom, 40)
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        isValidEmail(email) &&
        password.count >= 8 &&
        password == confirmPassword &&
        passwordStrength != .weak
    }
    
    private func performSignup() {
        guard isFormValid else {
            if password != confirmPassword {
                errorMessage = "Passwords do not match"
            } else if password.count < 8 {
                errorMessage = "Password must be at least 8 characters"
            } else {
                errorMessage = "Please fill in all required fields"
            }
            showingError = true
            return
        }
        
        authViewModel.signup(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password
        )
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func updatePasswordStrength() {
        let length = password.count
        var strength: Int = 0
        
        if length >= 8 { strength += 1 }
        if length >= 12 { strength += 1 }
        if password.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil { strength += 1 }
        if password.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil { strength += 1 }
        if password.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil { strength += 1 }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil { strength += 1 }
        
        if strength <= 2 {
            passwordStrength = .weak
        } else if strength <= 4 {
            passwordStrength = .medium
        } else {
            passwordStrength = .strong
        }
    }
    
    private func passwordStrengthColor(for index: Int) -> Color {
        let strengthLevel = passwordStrength.rawValue
        if index < strengthLevel {
            switch passwordStrength {
            case .weak:
                return .red
            case .medium:
                return .orange
            case .strong:
                return .green
            case .none:
                return .gray.opacity(0.3)
            }
        }
        return .gray.opacity(0.3)
    }
    
    private var passwordStrengthText: String {
        switch passwordStrength {
        case .none:
            return ""
        case .weak:
            return "Weak password"
        case .medium:
            return "Medium strength"
        case .strong:
            return "Strong password"
        }
    }
    
    enum PasswordStrength: Int {
        case none = 0
        case weak = 1
        case medium = 2
        case strong = 3
    }
    
}

