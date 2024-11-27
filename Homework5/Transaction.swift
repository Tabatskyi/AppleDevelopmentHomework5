import Foundation

class Transaction {
    enum TransactionType {
        case deposit
        case withdrawal
        case credit
    }
    
    let amount: Double
    let date: Date
    let type: TransactionType
    
    init(amount: Double, date: Date = Date(), type: TransactionType) {
        self.amount = amount
        self.date = date
        self.type = type
    }
}
