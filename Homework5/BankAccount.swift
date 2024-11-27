import Foundation

final class BankAccount {
    
    var balance: Double {
        creditBalance + deposit
    }
    
    private(set) var creditBalance: Double = 0.0
    private(set) var creditLoan: Double = 0.0
    
    private(set) var creditLimit: Double = 10000
    
    private(set) var deposit: Double = 0.0
    private(set) var transactionHistory: [Transaction] = []
    
    // Deposit method
    func deposit(amount: Double) {
        guard amount > 0 else { return }
        deposit += amount
        let transaction = Transaction(amount: amount, type: .deposit)
        transactionHistory.append(transaction)
    }
    
    // Withdrawal method
    func withdraw(amount: Double) -> Bool {
        guard amount > 0, amount <= balance else { return false }
        deposit -= amount
        let transaction = Transaction(amount: amount, type: .withdrawal)
        transactionHistory.append(transaction)
        return true
    }
    
    // Method to take credit and add it to balance
    func takeCredit(amount: Double) -> Bool {
        guard amount > 0, amount <= creditLimit, creditLoan == 0 else { return false }
        creditBalance += amount
        creditLoan += amount
        let transaction = Transaction(amount: amount, type: .credit)
        transactionHistory.append(transaction)
        return true
    }
    
    // Pay credit loan to allow taking new credit
    func payCredit(amount: Double) -> Bool {
        guard amount > 0, amount <= creditLoan else { return false }
        creditLoan -= amount
        
        let transaction = Transaction(amount: amount, type: .credit)
        transactionHistory.append(transaction)
        return true
    }
    
    // Method to get all transactions
    func getTransactionHistory() -> [Transaction] {
        return transactionHistory
    }
}
