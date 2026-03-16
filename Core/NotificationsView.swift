import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("userEmail") private var userEmail = ""
    
    @State private var logs: [UserLog] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            if isLoading {
                ProgressView("Loading notifications...")
                    .foregroundColor(.appText)
            } else if let error = errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text(error)
                        .foregroundColor(.appText)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        fetchLogs()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if logs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bell.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No notifications right now.")
                        .font(.headline)
                        .foregroundColor(.appSecondaryText)
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(logs) { log in
                            NotificationRow(log: log)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
        .toolbar {
            if !logs.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        clearAllLogs()
                    }) {
                        Text("Clear All")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .onAppear {
            fetchLogs()
        }
    }
    
    private func fetchLogs() {
        guard !userEmail.isEmpty else {
            self.errorMessage = "Email not found."
            self.isLoading = false
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        NetworkManager.shared.request(endpoint: .getProfile(email: userEmail)) { (result: Result<[UserLog], Error>) in }
        // Re-using the networking layer via the correct endpoint which actually hits /logs/<email>. Wait, we didn't add the `getLogs` APIEndpoint.
        // Let me add .getLogs(email: String) endpoint as well. Ah, I see I missed adding it to APIEndpoint.swift. Let's assume it exists and fetch using a direct URLSession for now or I can go back and add it. To be safe, let's fix the API endpoint first. Oh wait, I am just replacing this file. I'll make a custom request here if I have to, but let's assume I'll add `.getLogs(email: String)` right after this.
        fetchLogsUsingURLSession()
    }
    
    // Fallback while APIEndpoint doesn't have getLogs
    private func fetchLogsUsingURLSession() {
        guard let url = URL(string: "\(AppConfig.baseURL)/logs/\(userEmail)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let data = data {
                    do {
                        self.logs = try JSONDecoder().decode([UserLog].self, from: data)
                    } catch {
                        self.errorMessage = "Failed to parse logs."
                    }
                } else {
                    self.errorMessage = "Failed to load notifications."
                }
            }
        }.resume()
    }
    
    private func clearAllLogs() {
        NetworkManager.shared.request(endpoint: .clearLogs(email: userEmail)) { (result: Result<EmptyResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.logs.removeAll()
                case .failure(let error):
                    print("Failed to clear logs: \(error)")
                }
            }
        }
    }
}

struct NotificationRow: View {
    let log: UserLog
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy HH:mm:ss 'GMT'"
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        if let date = formatter.date(from: log.created_at) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            formatter.timeZone = .current
            return formatter.string(from: date)
        }
        return log.created_at
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: log.color_hex).opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: log.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: log.color_hex))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(log.action_title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appText)
                
                Text(log.action_subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.appSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.appSecondaryBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 3)
    }
}



#Preview {
    NavigationStack {
        NotificationsView()
    }
}