import XCTest
@testable import Homework5

final class BankAccountTests: XCTestCase {
    var bankAccount: BankAccount!

    override func setUp() {
        super.setUp()
        bankAccount = BankAccount()
    }

    override func tearDown() {
        bankAccount = nil
        super.tearDown()
    }

    func testStartBalance() {
        XCTAssertEqual(bankAccount.balance, 0.0, "Start balance should be 0")
    }

    func testDepositPositiveAmount() {
        bankAccount.deposit(amount: 500.0)
        XCTAssertEqual(bankAccount.deposit, 500.0, "Deposit should increaset")
        XCTAssertEqual(bankAccount.transactionHistory.count, 1, "History should contain the deposit")
    }

    func testDepositNegativeAmount() {
        bankAccount.deposit(amount: -100.0)
        XCTAssertEqual(bankAccount.deposit, 0.0, "Deposit shouldn`t change")
        XCTAssertEqual(bankAccount.transactionHistory.count, 0, "Transactions history shouldn`t contain invalid deposit")
    }

    func testWithdrawValidAmount() {
        bankAccount.deposit(amount: 1000.0)
        let result = bankAccount.withdraw(amount: 500.0)
        XCTAssertTrue(result, "Withdraw of valid amount should be successful")
        XCTAssertEqual(bankAccount.deposit, 500.0, "Remainings should reflect the withdraw")
        XCTAssertEqual(bankAccount.transactionHistory.count, 2, "Transactions history should contain withdraw")
    }

    func testWithdrawInvalidAmount() {
        bankAccount.deposit(amount: 200.0)
        let result = bankAccount.withdraw(amount: 500.0)
        XCTAssertFalse(result, "Withdraw more than balance should fail")
        XCTAssertEqual(bankAccount.deposit, 200.0, "Deposit should remain unchanged")
        XCTAssertEqual(bankAccount.transactionHistory.count, 1, "Transactions history should not contain fail")
    }

    func testTakeCreditValidAmount() {
        let result = bankAccount.takeCredit(amount: 5000.0)
        XCTAssertTrue(result, "Taking credit within limit should be successful")
        XCTAssertEqual(bankAccount.creditBalance, 5000.0, "Credit balance should reflect the credit")
        XCTAssertEqual(bankAccount.creditLoan, 5000.0, "Credit loan should reflect the credit")
        XCTAssertEqual(bankAccount.transactionHistory.count, 1, "Transactions history should contain the credit")
    }

    func testTakeCreditExceedingLimit() {
        let result = bankAccount.takeCredit(amount: 20000.0)
        XCTAssertFalse(result, "Taking credit exceeding the limit should fail")
        XCTAssertEqual(bankAccount.creditBalance, 0.0, "Credit balance should remain unchanged")
        XCTAssertEqual(bankAccount.creditLoan, 0.0, "Credit loan should remain unchanged")
        XCTAssertEqual(bankAccount.transactionHistory.count, 0, "Transactions history should not record invalid credit attempts")
    }

    func testPayCreditValidAmount() {
        let _ = bankAccount.takeCredit(amount: 5000.0)
        let result = bankAccount.payCredit(amount: 3000.0)
        XCTAssertTrue(result, "Paying part of the credit should be successful")
        XCTAssertEqual(bankAccount.creditLoan, 2000.0, "Credit loan should decrease by the paid amount")
        XCTAssertEqual(bankAccount.transactionHistory.count, 2, "Transactions history should record the payment")
    }

    func testPayCreditExceedingLoan() {
        let _ = bankAccount.takeCredit(amount: 3000.0)
        let result = bankAccount.payCredit(amount: 5000.0)
        XCTAssertFalse(result, "Paying more than the credit loan should fail")
        XCTAssertEqual(bankAccount.creditLoan, 3000.0, "Credit loan should remain unchanged")
        XCTAssertEqual(bankAccount.transactionHistory.count, 1, "Transactions history should not record invalid payments")
    }

    func testTransactionHistoryRecordsCorrectly() {
        bankAccount.deposit(amount: 1000.0)
        let _ = bankAccount.withdraw(amount: 200.0)
        let _ = bankAccount.takeCredit(amount: 3000.0)
        let _ = bankAccount.payCredit(amount: 1000.0)
        let transactions = bankAccount.getTransactionHistory()
        XCTAssertEqual(transactions.count, 4, "Transaction history should record all valid transactions in order")
        XCTAssertEqual(transactions[0].type, .deposit, "First transaction should be deposit")
        XCTAssertEqual(transactions[1].type, .withdrawal, "Second transaction should be withdraw")
        XCTAssertEqual(transactions[2].type, .credit, "Third transaction should be credit")
        XCTAssertEqual(transactions[3].type, .credit, "Fourth transaction should be credit payment")
    }
}
