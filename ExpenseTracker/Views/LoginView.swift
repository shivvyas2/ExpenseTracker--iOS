//
//  LoginView.swift
//  ExpenseTracker
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingPassword = false
    @State private var showingError = false
    @State private var errorMessage: String = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
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
                        actionButtonsSection
                        socialLoginSection
                        registrationLink
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Authentication Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {
                errorMessage = ""
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sign in to your account")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 40)
            
            Text("Enter your credentials to access your financial information and manage your money with ease.")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 32)
    }
    
    private var inputFieldsSection: some View {
        VStack(spacing: 16) {
            ModernTextField(
                text: $email,
                placeholder: "Email",
                icon: "envelope",
                keyboardType: .emailAddress,
                autocapitalization: .never,
                autocorrectionDisabled: true
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
            .submitLabel(.go)
            .onSubmit {
                performLogin()
            }
            
            HStack {
                Spacer()
                Button("Forgot password?") {
                    // Handle forgot password
                }
                .font(.system(size: 14))
                .foregroundColor(.blue)
            }
            .padding(.top, 4)
        }
        .padding(.bottom, 24)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: performLogin) {
                Text("Login")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!isFormValid || authViewModel.isLoading)
            
            Button(action: {
                // Handle skip
            }) {
                Text("Skip")
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(12)
            }
        }
        .padding(.bottom, 32)
    }
    
    private var socialLoginSection: some View {
        VStack(spacing: 20) {
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                
                Text("Or use social account")
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
                    authViewModel.loginWithApple()
                }
                
                SocialAccountButton(
                    icon: "",
                    text: "Google",
                    isGoogle: true
                ) {
                    authViewModel.loginWithGoogle()
                }
            }
        }
        .padding(.bottom, 32)
    }
    
    private var registrationLink: some View {
        HStack {
            Text("Don't have an account?")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            NavigationLink(destination: SignUpView(authViewModel: authViewModel)) {
                Text("Register")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
            }
        }
        .padding(.bottom, 40)
    }
    
    private var isFormValid: Bool {
        isValidEmail(email) && !password.isEmpty
    }
    
    private func performLogin() {
        guard isFormValid else { return }
        authViewModel.login()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

struct ModernTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var isSecure: Bool = false
    var trailingIcon: String? = nil
    var onTrailingIconTap: (() -> Void)? = nil
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var autocorrectionDisabled: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled(autocorrectionDisabled)
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled(autocorrectionDisabled)
                    .focused($isFocused)
            }
            
            if let trailingIcon = trailingIcon {
                Button(action: {
                    onTrailingIconTap?()
                }) {
                    Image(systemName: trailingIcon)
                        .foregroundColor(.gray)
                        .frame(width: 20)
                }
            }
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: isFocused ? 2 : 1)
        )
        .cornerRadius(12)
    }
}

struct SocialAccountButton: View {
    let icon: String
    let text: String
    var isApple: Bool = false
    var isGoogle: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isGoogle {
                    GoogleLogoView()
                        .frame(width: 20, height: 20)
                } else if isApple {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 20)
                } else {
                    Image(systemName: icon)
                        .foregroundColor(.gray)
                        .frame(width: 20)
                }
                
                Text(text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(12)
        }
    }
}

struct GoogleLogoView: View {
    var body: some View {
        ZStack {
            // Official Google "G" logo
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)
                let center = CGPoint(x: size/2, y: size/2)
                let radius = size/2
                
                ZStack {
                    // Blue section (top right)
                    Path { path in
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: .degrees(-45),
                            endAngle: .degrees(45),
                            clockwise: false
                        )
                        path.addLine(to: center)
                        path.closeSubpath()
                    }
                    .fill(Color(red: 0.26, green: 0.52, blue: 0.96))
                    
                    // Red section (top)
                    Path { path in
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: .degrees(45),
                            endAngle: .degrees(135),
                            clockwise: false
                        )
                        path.addLine(to: center)
                        path.closeSubpath()
                    }
                    .fill(Color(red: 0.96, green: 0.26, blue: 0.21))
                    
                    // Yellow section (bottom right)
                    Path { path in
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: .degrees(135),
                            endAngle: .degrees(225),
                            clockwise: false
                        )
                        path.addLine(to: center)
                        path.closeSubpath()
                    }
                    .fill(Color(red: 0.99, green: 0.75, blue: 0.18))
                    
                    // Green section (bottom left)
                    Path { path in
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: .degrees(225),
                            endAngle: .degrees(315),
                            clockwise: false
                        )
                        path.addLine(to: center)
                        path.closeSubpath()
                    }
                    .fill(Color(red: 0.13, green: 0.59, blue: 0.31))
                    
                    // White center to create "G" shape
                    Circle()
                        .fill(Color.white)
                        .frame(width: size * 0.55, height: size * 0.55)
                        .position(center)
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authViewModel: AuthenticationViewModel())
    }
}
