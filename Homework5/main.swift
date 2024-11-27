import Foundation

struct Item {
    let name: String
    let price: Double
    let quantity: Int
}

struct Coupon {
    let code: String
    let discountPercentage: Double
    let maxDiscount: Double
    var usageLimit: Int
    var used: Int = 0
    
    private static var globalUsage: [String: Int] = [:]

        func canBeApplied() -> Bool {
            let used = Coupon.globalUsage[code, default: 0]
            return used < usageLimit
        }

        mutating func markUse() -> Bool {
            guard canBeApplied() else { return false }
            Coupon.globalUsage[code, default: 0] += 1
            return true
        }
}

final class ShoppingCart {
    private(set) var items: [Item] = []
    private(set) var appliedCoupons: [Coupon] = []
    private var totalCouponUsage: [String: Int] = [:]

    func addItem(_ item: Item) {
        items.append(item)
    }
    // https://stackoverflow.com/questions/40577719/how-can-i-remove-a-struct-element-from-an-array-of-structs-based-on-the-id-of-th
    func removeItem(_ item: Item) {
        if let index:Int = items.firstIndex(where: {$0.name == item.name}) {
            items.remove(at: index)
        }
    }

    func calculateTotalPrice() -> Double {
        var total = 0.0
        for item in items {
            total += item.price * Double(item.quantity)
        }
        return total
    }

    func applyCoupon(_ coupon: Coupon) -> Bool {
        if appliedCoupons.contains(where: { $0.code == coupon.code }) {
                    return false
        }
        var mutableCoupon = coupon
        if !mutableCoupon.markUse() {
            return false
        }
        
        appliedCoupons.append(mutableCoupon)
        return true
    }

    func calculateFinalPrice() -> Double {
        let totalPrice = calculateTotalPrice()
        var totalDiscount = 0.0

        for coupon in appliedCoupons {
            let discount = min(totalPrice * (coupon.discountPercentage / 100), coupon.maxDiscount)
            totalDiscount += totalPrice > coupon.maxDiscount ? discount : 0.0
        }

        return max(totalPrice - totalDiscount, 0.0)
    }
}
