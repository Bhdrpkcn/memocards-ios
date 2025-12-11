import Foundation

enum APIConfig {

    //for testing simulator's phone
    //    static let baseURL = URL(string: "http://localhost:3001")!

    //for testing real phone via wifi
//        static let baseURL = URL(string: "http://192.168.0.21:3001")!

    //for testing real phone via hotspot
    static let baseURL = URL(string: "http://172.20.10.6:3001")!

    /// Shared API client instance
    static let client = APIClient(baseURL: APIConfig.baseURL)
}

///  tofind out what ip you're on
///  ipconfig getifaddr en0
