import Foundation

enum MemoDateFilter: String, CaseIterable, Identifiable {
    case all
    case today
    case yesterday
    case thisWeek
    case lastWeek
    case thisMonth
    case lastMonth
    case last3Days
    case last7Days
    case last30Days
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .all: return NSLocalizedString("memo.date_filter.all", comment: "All time")
        case .today: return NSLocalizedString("memo.date_filter.today", comment: "Today")
        case .yesterday: return NSLocalizedString("memo.date_filter.yesterday", comment: "Yesterday")
        case .thisWeek: return NSLocalizedString("memo.date_filter.this_week", comment: "This week")
        case .lastWeek: return NSLocalizedString("memo.date_filter.last_week", comment: "Last week")
        case .thisMonth: return NSLocalizedString("memo.date_filter.this_month", comment: "This month")
        case .lastMonth: return NSLocalizedString("memo.date_filter.last_month", comment: "Last month")
        case .last3Days: return NSLocalizedString("memo.date_filter.last_3_days", comment: "Last 3 days")
        case .last7Days: return NSLocalizedString("memo.date_filter.last_7_days", comment: "Last 7 days")
        case .last30Days: return NSLocalizedString("memo.date_filter.last_30_days", comment: "Last 30 days")
        }
    }
    
    func dateRange() -> (start: Date?, end: Date?) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .all:
            return (nil, nil)
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            return (startOfDay, nil)
        case .yesterday:
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
            let startOfYesterday = calendar.startOfDay(for: yesterday)
            let endOfYesterday = calendar.date(byAdding: .day, value: 1, to: startOfYesterday)!
            return (startOfYesterday, endOfYesterday)
        case .thisWeek:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return (startOfWeek, nil)
        case .lastWeek:
            let startOfLastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!)!
            let endOfLastWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfLastWeek)!
            return (startOfLastWeek, endOfLastWeek)
        case .thisMonth:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return (startOfMonth, nil)
        case .lastMonth:
            let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: calendar.date(from: calendar.dateComponents([.year, .month], from: now))!)!
            let endOfLastMonth = calendar.date(byAdding: .month, value: 1, to: startOfLastMonth)!
            return (startOfLastMonth, endOfLastMonth)
        case .last3Days:
            let startDate = calendar.date(byAdding: .day, value: -2, to: calendar.startOfDay(for: now))!
            return (startDate, nil)
        case .last7Days:
            let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now))!
            return (startDate, nil)
        case .last30Days:
            let startDate = calendar.date(byAdding: .day, value: -29, to: calendar.startOfDay(for: now))!
            return (startDate, nil)
        }
    }
}