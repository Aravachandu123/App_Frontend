import Foundation

enum APIEndpoint {
    case register(payload: [String: Any])
    case login(payload: [String: Any])
    case getProfile(email: String)
    case updateProfile(email: String, payload: [String: Any])
    case updateLifestyle(email: String, payload: [String: Any])
    case updateFamily(email: String, payload: [String: Any])
    case assessRisk(payload: [String: Any])
    case getRiskHistory(email: String)
    case getBundle(email: String)
    case addLog(payload: [String: Any])
    case clearLogs(email: String)
    case resetPassword(payload: [String: Any])
    
    var path: String {
        switch self {
        case .register: return "/auth/register"
        case .login: return "/auth/login"
        case .getProfile(let email): return "/profile/\(email)"
        case .updateProfile(let email, _): return "/profile/\(email)"
        case .updateLifestyle(let email, _): return "/lifestyle/\(email)"
        case .updateFamily(let email, _): return "/family/\(email)"
        case .assessRisk: return "/assess"
        case .getRiskHistory(let email): return "/risk-history/\(email)"
        case .getBundle(let email): return "/bundle/\(email)"
        case .addLog: return "/logs/"
        case .clearLogs(let email): return "/logs/\(email)"
        case .resetPassword: return "/auth/reset-password"
        }
    }
    
    var method: String {
        switch self {
        case .register, .login, .updateFamily, .assessRisk, .resetPassword, .addLog: return "POST"
        case .getProfile, .getRiskHistory, .getBundle: return "GET"
        case .updateProfile, .updateLifestyle: return "PUT"
        case .clearLogs: return "DELETE"
        }
    }
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: AppConfig.baseURL + path) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        switch self {
        case .register(let payload),
             .login(let payload),
             .updateProfile(_, let payload),
             .updateLifestyle(_, let payload),
             .updateFamily(_, let payload),
             .assessRisk(let payload),
             .resetPassword(let payload),
             .addLog(let payload):
            request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])
        default: break
        }
        
        return request
    }
}
