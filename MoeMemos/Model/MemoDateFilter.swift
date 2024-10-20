import Foundation

enum MemoDateFilter: String, CaseIterable, Identifiable {
    case created
    case modified
    case updated
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .created:
            return NSLocalizedString("memo.date_filter.created", comment: "Created")
        case .modified:
            return NSLocalizedString("memo.date_filter.modified", comment: "Modified")
        case .updated:
            return NSLocalizedString("memo.date_filter.updated", comment: "Updated")
        }
    }
}
