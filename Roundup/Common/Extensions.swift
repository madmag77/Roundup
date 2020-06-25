import Foundation

// Format date to in the format 2020-06-09T18:31:42Z
extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone
    }
}

extension Formatter {
    static let iso8601 = ISO8601DateFormatter([.withInternetDateTime])
}

extension Date {
    var iso8601: String { return Formatter.iso8601.string(from: self) }
}

extension Date {
    func toDateWeekAgo() -> Date {
        var dayComponent = DateComponents()
        dayComponent.day = -7
        return Calendar.current.date(byAdding: dayComponent, to: self)!
    }
    
    // Strip time portion
    func toDateOnly() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }
}
