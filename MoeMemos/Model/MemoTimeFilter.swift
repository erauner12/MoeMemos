import Foundation

enum MemoTimeFilter: String, CaseIterable, Identifiable {
    case all
    case createdToday
    case updatedToday
    case modifiedToday
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .all:
            return NSLocalizedString("memo.filter.all", comment: "All memos")
        case .createdToday:
            return NSLocalizedString("memo.filter.created_today", comment: "Created today")
        case .updatedToday:
            return NSLocalizedString("memo.filter.updated_today", comment: "Updated today")
        case .modifiedToday:
            return NSLocalizedString("memo.filter.modified_today", comment: "Modified today")
        }
    }
}
