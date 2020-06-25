import Foundation

protocol AccountDateStorage: class {
    var lastRoundupDate: Date? { get set }
}

extension UserDefaults: AccountDateStorage {
    var lastRoundupDate: Date? {
        get {
            object(forKey: #function) as? Date
        }
        
        set {
            set(newValue, forKey: #function)
        }
    }
}
