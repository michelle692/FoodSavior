//
//  foodItem.swift
//  FoodItemTracker
//

import Foundation

struct FoodItem: Identifiable {
    var id = UUID()
    var name: String
    var quantity: Int
    var shelfLife: Int
}

class MyFoodItems: Identifiable, ObservableObject {
    var id = UUID()
    @Published var foodItems: [FoodItem] = []
    
    func addFoodItem(foodItem: FoodItem) {
        foodItems.insert(foodItem, at: 0)
    }
}



