//
//  ProfileTab.swift
//  ExpenseTracker
//

import SwiftUI

struct ProfileTab: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    statsSection
                    actionButtons
                    contentTabs
                    postsSection
                }
                .padding()
            }
            .background(Color.Background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: {
                            showingLogoutAlert = true
                        }) {
                            Label("Sign Out", systemImage: "arrow.right.square")
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    private var profileHeader: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay {
                    if let userInfo = authViewModel.userInfo {
                        Text(userInfo.name.prefix(1).uppercased())
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(authViewModel.userInfo?.name ?? "User Name")
                    .font(.system(size: 24, weight: .bold))
                
                Text("@\(authViewModel.userInfo?.email.components(separatedBy: "@").first ?? "username")")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var quoteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dream big, work hard, stay focused, and surround yourself with good energy.")
                .font(.system(size: 15))
                .foregroundColor(.primary)
            
            Text("💪")
                .font(.system(size: 20))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(value: "600", label: "Following")
            StatCard(value: "120k", label: "Followers")
            StatCard(value: "\(authViewModel.userInfo != nil ? "24" : "0")", label: "Posts")
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                Text("Follow")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            
            Button(action: {}) {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }
    
    private var contentTabs: some View {
        HStack(spacing: 0) {
            ContentTabButton(title: "Post", icon: "doc.badge.plus", isSelected: true)
            ContentTabButton(title: "Video", icon: "play.fill", isSelected: false)
            ContentTabButton(title: "Tag", icon: "person.fill", isSelected: false)
        }
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var postsSection: some View {
        VStack(spacing: 16) {
            PostCard(
                userName: authViewModel.userInfo?.name ?? "User Name",
                timeAgo: "2 hr ago",
                content: "Happiness is a perfectly cooked meal. 🍽️😋",
                likes: "10k",
                comments: "172",
                shares: "80",
                reposts: "12",
                saves: "19"
            )
            
            PostCard(
                userName: authViewModel.userInfo?.name ?? "User Name",
                timeAgo: "2 hr ago",
                content: "Dream big, work hard, stay focused, and surround yourself with good energy. 💪",
                likes: "8.5k",
                comments: "142",
                shares: "65",
                reposts: "9",
                saves: "15"
            )
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ContentTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .primary : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color.white : Color.clear)
            .cornerRadius(12)
        }
    }
}

struct PostCard: View {
    let userName: String
    let timeAgo: String
    let content: String
    let likes: String
    let comments: String
    let shares: String
    let reposts: String
    let saves: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Text(userName.prefix(1).uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.blue)
                    }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(userName)
                        .font(.system(size: 15, weight: .semibold))
                    Text(timeAgo)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
            }
            
            Text(content)
                .font(.system(size: 15))
                .lineSpacing(4)
            
            HStack(spacing: 20) {
                EngagementButton(icon: "heart.fill", count: likes, color: .red)
                EngagementButton(icon: "bubble.right.fill", count: comments, color: .blue)
                EngagementButton(icon: "paperplane.fill", count: shares, color: .blue)
                EngagementButton(icon: "arrow.2.squarepath", count: reposts, color: .green)
                EngagementButton(icon: "bookmark.fill", count: saves, color: .orange)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(16)
    }
}

struct EngagementButton: View {
    let icon: String
    let count: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(count)
                    .font(.system(size: 13))
            }
            .foregroundColor(color)
        }
    }
}

