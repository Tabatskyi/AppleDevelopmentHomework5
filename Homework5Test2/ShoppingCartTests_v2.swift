//
//  ShoppingCartTests.swift
//  ShoppingCartTests
//
//  Created by Roman Mishchenko on 13.11.2024.
//

import XCTest
@testable import Homework5

final class ShoppingCartTests: XCTestCase {

    lazy var cart = ShoppingCart()
    lazy var coupon10Percent = Coupon(code: "SAVE10", discountPercentage: 10, maxDiscount: 50, usageLimit: 1)
    lazy var coupon20PercentWithLimit = Coupon(code: "SAVE20", discountPercentage: 20, maxDiscount: 30, usageLimit: 2)
    
    func testAddItemIncreasesItemCount() {
        let item = Item(name: "Laptop", price: 999.99, quantity: 1)
        cart.addItem(item)
        XCTAssertEqual(cart.items.count, 1)
    }
    
    func testRemoveItemDecreasesItemCount() {
        let item = Item(name: "Phone", price: 599.99, quantity: 1)
        cart.addItem(item)
        XCTAssertEqual(cart.items.count, 1)
        cart.removeItem(item)
        XCTAssertEqual(cart.items.count, 0)
    }
    
    func testCalculateTotalPrice() {
        let item1 = Item(name: "Headphones", price: 49.99, quantity: 2)
        let item2 = Item(name: "Keyboard", price: 89.99, quantity: 1)
        cart.addItem(item1)
        cart.addItem(item2)
        
        XCTAssertEqual(cart.calculateTotalPrice(), 189.97, accuracy: 0.01)
    }
    
    func testNoDiscountAppliedForLowTotal() {
        let item = Item(name: "Book", price: 15.0, quantity: 1)
        cart.addItem(item)
        
        XCTAssertEqual(cart.calculateFinalPrice(), 15.0)
    }
    
    func testApplyCouponDiscount() {
        let item1 = Item(name: "Laptop", price: 1000, quantity: 1)
        let item2 = Item(name: "Phone", price: 500, quantity: 1)
        cart.addItem(item1)
        cart.addItem(item2)
        // Apply 10% coupon
        let isApplied = cart.applyCoupon(coupon10Percent)
        XCTAssertTrue(isApplied, "Coupon should be applied successfully.")
        
        // Calculate final price with 10% discount
        let expectedDiscount = min((1000 + 500) * 0.10, 50)
        let expectedFinalPrice = (1000 + 500) - expectedDiscount
        XCTAssertEqual(cart.calculateFinalPrice(), expectedFinalPrice, accuracy: 0.01, "Final price should reflect 10% discount up to max of $50.")
    }
    
    func testApplyCouponDiscountWithLimit() {
        let item1 = Item(name: "Laptop", price: 1000, quantity: 1)
        let item2 = Item(name: "Phone", price: 500, quantity: 1)
        cart.addItem(item1)
        cart.addItem(item2)
        // Apply 20% coupon with max discount of $30
        let isApplied = cart.applyCoupon(coupon20PercentWithLimit)
        XCTAssertTrue(isApplied, "Coupon should be applied successfully.")
        
        // Calculate final price with 20% discount up to $30
        let expectedDiscount = min((1000 + 500) * 0.20, 30)
        let expectedFinalPrice = (1000 + 500) - expectedDiscount
        XCTAssertEqual(cart.calculateFinalPrice(), expectedFinalPrice, accuracy: 0.01, "Final price should reflect 20% discount up to max of $30.")
    }
    
    func testApplyCouponBeyondUsageLimit() {
        let item1 = Item(name: "Laptop", price: 1000, quantity: 1)
        let item2 = Item(name: "Phone", price: 500, quantity: 1)
        cart.addItem(item1)
        cart.addItem(item2)
        // Apply coupon twice to test usage limit
        let firstApplication = cart.applyCoupon(coupon20PercentWithLimit)
        let secondApplication = cart.applyCoupon(coupon20PercentWithLimit)
        XCTAssertTrue(firstApplication, "Coupon should apply the first time.")
        XCTAssertFalse(secondApplication, "Coupon should not be applied more than its usage limit.")
        
        // Verify discount is only applied once
        let expectedDiscount = min((1000 + 500) * 0.20, 30)
        let expectedFinalPrice = (1000 + 500) - expectedDiscount
        XCTAssertEqual(cart.calculateFinalPrice(), expectedFinalPrice, accuracy: 0.01, "Final price should reflect only the first discount application.")
    }
    
    func testApplyMultipleCoupons() {
        let item1 = Item(name: "Laptop", price: 1000, quantity: 1)
        let item2 = Item(name: "Phone", price: 500, quantity: 1)
        cart.addItem(item1)
        cart.addItem(item2)
        // Apply multiple coupons
        let applyFirstCoupon = cart.applyCoupon(coupon10Percent)
        let applySecondCoupon = cart.applyCoupon(coupon20PercentWithLimit)
        
        XCTAssertTrue(applyFirstCoupon, "First coupon should be applied successfully.")
        XCTAssertTrue(applySecondCoupon, "Second coupon should be applied successfully.")
        
        // Calculate combined discount and final price
        let total = Double(1000 + 500)
        let firstDiscount = min(total * 0.10, 50)   // 10% up to $50
        let secondDiscount = min(total * 0.20, 30)  // 20% up to $30
        let expectedFinalPrice = total - (firstDiscount + secondDiscount)
        
        XCTAssertEqual(cart.calculateFinalPrice(), expectedFinalPrice, accuracy: 0.01, "Final price should reflect combined discounts of multiple coupons.")
    }
    
    func testCannotApplySameCouponTwice() {
        let item1 = Item(name: "Laptop", price: 1000, quantity: 1)
        let item2 = Item(name: "Phone", price: 500, quantity: 1)
        cart.addItem(item1)
        cart.addItem(item2)
        // Apply the same coupon twice
        let firstApplication = cart.applyCoupon(coupon10Percent)
        let secondApplication = cart.applyCoupon(coupon10Percent)
        
        XCTAssertTrue(firstApplication, "First application of coupon should succeed.")
        XCTAssertFalse(secondApplication, "Second application of the same coupon should fail.")
        
        // Verify only one discount is applied
        let expectedDiscount = min((1000 + 500) * 0.10, 50)
        let expectedFinalPrice = (1000 + 500) - expectedDiscount
        XCTAssertEqual(cart.calculateFinalPrice(), expectedFinalPrice, accuracy: 0.01, "Final price should only reflect the first application of the coupon.")
    }
    
    func testNoDiscountWhenCouponExceedsMaxDiscountLimit() {
        // Apply a 50% coupon with a maximum discount of $25
        let coupon50Percent = Coupon(code: "HALFOFF", discountPercentage: 50, maxDiscount: 25, usageLimit: 1)
        cart.addItem(Item(name: "Book", price: 10, quantity: 1))
        
        let isApplied = cart.applyCoupon(coupon50Percent)
        XCTAssertTrue(isApplied, "Coupon should be applied successfully.")
        
        // Expected discount should cap at $25, but since total is $10, no discount should be applied
        XCTAssertEqual(cart.calculateFinalPrice(), 10.0, "Final price should be unaffected as discount cap exceeds cart total.")
    }
    
    func testCalculateFinalPriceAfterRemovingItem() {
        // Add items and apply a coupon
        let coupon = Coupon(code: "DISCOUNT10", discountPercentage: 10, maxDiscount: 50, usageLimit: 1)
        let item1 = Item(name: "Shoes", price: 80, quantity: 1)
        let item2 = Item(name: "Jacket", price: 120, quantity: 1)
        cart.addItem(item1)
        cart.addItem(item2)
        
        _ = cart.applyCoupon(coupon)
        
        // Remove one item and calculate the new final price
        cart.removeItem(item2)
        
        let expectedDiscount = min(80 * 0.10, 50)  // Recalculates the discount based on remaining item
        let expectedFinalPrice = 80 - expectedDiscount
        XCTAssertEqual(cart.calculateFinalPrice(), expectedFinalPrice, accuracy: 0.01, "Final price should reflect updated discount after item removal.")
    }

    func testCouponUsageLimitAcrossMultipleCarts() {
        // Test to ensure coupon usage limit persists across multiple carts
        let globalCoupon = Coupon(code: "GLOBAL", discountPercentage: 10, maxDiscount: 20, usageLimit: 2)
        
        // First cart
        let firstCart = ShoppingCart()
        firstCart.addItem(Item(name: "Tablet", price: 150, quantity: 1))
        let isAppliedFirst = firstCart.applyCoupon(globalCoupon)
        _ = firstCart.calculateFinalPrice()
        XCTAssertTrue(isAppliedFirst, "Coupon should apply to the first cart.")
        
        print(globalCoupon.used)
        
        // Second cart
        let secondCart = ShoppingCart()
        secondCart.addItem(Item(name: "Headphones", price: 80, quantity: 1))
        let isAppliedSecond = secondCart.applyCoupon(globalCoupon)
        _ = firstCart.calculateFinalPrice()
        XCTAssertTrue(isAppliedSecond, "Coupon should apply to the second cart within usage limit.")
        
        print(globalCoupon.used)
        
        // Third cart (should fail due to usage limit)
        let thirdCart = ShoppingCart()
        thirdCart.addItem(Item(name: "Camera", price: 200, quantity: 1))
        let isAppliedThird = thirdCart.applyCoupon(globalCoupon)
        _ = firstCart.calculateFinalPrice()
        XCTAssertFalse(isAppliedThird, "Coupon should not apply to the third cart as usage limit has been reached.")
    }

}
