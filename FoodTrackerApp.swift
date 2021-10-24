//
//  FoodItemTrackerApp.swift
//  FoodItemTracker
//

import SwiftUI

@main
struct FoodTrackerApp: App {
    @StateObject var myFoodItems = MyFoodItems()
    
    var body: some Scene {
        WindowGroup {
            FoodItemsView(myFoodItems: myFoodItems)
        }
    }
}
