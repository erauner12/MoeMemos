import Foundation

enum MemoTimeFilter: String, CaseIterable, Identifiable {
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
    case custom
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .all:
            return NSLocalizedString("memo.filter.all", comment: "All memos")
        case .today:
            return NSLocalizedString("memo.filter.today", comment: "Today")
        case .yesterday:
            return NSLocalizedString("memo.filter.yesterday", comment: "Yesterday")
        case .thisWeek:
            return NSLocalizedString("memo.filter.this_week", comment: "This week")
        case .lastWeek:
            return NSLocalizedString("memo.filter.last_week", comment: "Last week")
        case .thisMonth:
            return NSLocalizedString("memo.filter.this_month", comment: "This month")
        case .lastMonth:
            return NSLocalizedString("memo.filter.last_month", comment: "Last month")
        case .last3Days:
            return NSLocalizedString("memo.filter.last_3_days", comment: "Last 3 days")
        case .last7Days:
            return NSLocalizedString("memo.filter.last_7_days", comment: "Last 7 days")
        case .last30Days:
            return NSLocalizedString("memo.filter.last_30_days", comment: "Last 30 days")
        case .custom:
            return NSLocalizedString("memo.filter.custom", comment: "Custom")
        }
    }
}