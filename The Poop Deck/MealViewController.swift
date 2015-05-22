//
//  MealViewController.swift
//  West Point
//
//  Created by Sean on 11/6/14.
//  Copyright (c) 2014 Sean Deaton. All rights reserved.
//

import UIKit

var didAppearCount = 0

var savedMeals: NSUserDefaults = NSUserDefaults(suiteName: "group.com.seandeaton.meals")!

enum UIUserInterfaceIdiom : Int {
    case Unspecified
    
    case Phone // iPhone and iPod touch style UI
    case Pad // iPad style UI
}

class MealViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var mealTableView: UITableView!
    
    var cellTapped:Bool = true
    var currentRow = 0
    
    var arrayOfMeals: [Meal] = [Meal]()
    var weekDayArray = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //addPictureToView WithAlpha(targetTableView: self.mealTableView, imageName: "Ted.png", alpha: 0.85, contentMode: .ScaleAspectFill)
        self.mealTableView.backgroundColor = UIColor.whiteColor()
        navigationController?.navigationBar.topItem?.title = "The Meals"
        addPullToRefreshToTableView(target: self, tableView: mealTableView)
        mealTableView.addSubview(refreshControl)
        
        showActivityIndicatory(self.view)
        
        let urlString = ("http://www.seandeaton.com/meals/Meals")
        retrieveJSON(urlString) {
            (responseObject, error) -> () in
            
            if responseObject == nil {
                println(error)
                hideActivityIndicator()
                self.presentViewController(displayMealFetchFailure(), animated: true, completion: nil)
                return
            }
            
            
            for days in self.weekDayArray {
                var newResponse: NSArray = responseObject![days] as! NSArray
                for obj: AnyObject in newResponse{
                    var breakfast = (obj.objectForKey("breakfast")! as! String)
                    var lunch = (obj.objectForKey("lunch")! as! String)
                    var dinner = obj.objectForKey("dinner")! as! String
                    
                    var breakfastArrayForDifferentDevices = breakfast.componentsSeparatedByString("|")
                    var lunchArrayForDifferentDevices = lunch.componentsSeparatedByString("|")
                    var dinnerArrayForDifferentDevices = dinner.componentsSeparatedByString("|")
                    //println(breakfastArrayForDifferentDevices)
                    
                    if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
                        if (breakfastArrayForDifferentDevices.count > 1){
                            breakfast = (breakfastArrayForDifferentDevices[0] + breakfastArrayForDifferentDevices[1])
                        }else {
                            breakfast = breakfastArrayForDifferentDevices[0]
                        }
                        if (lunchArrayForDifferentDevices.count>1){
                            lunch = (lunchArrayForDifferentDevices[0] + lunchArrayForDifferentDevices[1])
                        }else{
                            lunch = lunchArrayForDifferentDevices[0]
                        }
                        if (dinnerArrayForDifferentDevices.count>1){
                            dinner = (dinnerArrayForDifferentDevices[0] + dinnerArrayForDifferentDevices[1])
                        }else {
                            dinner = dinnerArrayForDifferentDevices[0]
                        }
                    }
                    else {
                        breakfast = breakfastArrayForDifferentDevices[0]
                        lunch = lunchArrayForDifferentDevices[0]
                        dinner = dinnerArrayForDifferentDevices[0]
                        
                    }
                    
                    let dateString = obj.objectForKey("dateString")! as! String
                    let dayOfWeek = obj.objectForKey("dayOfWeek")! as! String
                    let newMeal = Meal(breakfast: breakfast, lunch: lunch, dinner: dinner, dayOfWeek: dayOfWeek, dateString: dateString)
                    if theDays(newMeal.dateString) >= -1 {
                        self.arrayOfMeals.append(newMeal)
                    }
                }
            }
            
            
            self.mealTableView.reloadData()
            
            if self.arrayOfMeals.isEmpty == true {
                self.presentViewController(displayNoMeals(), animated: true, completion: nil)
            }
            self.updateAppGroupForMeals()
            
            hideActivityIndicator()
            
        }
        
        self.mealTableView.reloadData()
        
    }
    
    func updateAppGroupForMeals(){
        println(self.arrayOfMeals.count)
        var savedBreakfast: String
        var savedLunch: String
        var savedDinner: String
        
        if self.arrayOfMeals.isEmpty {
            savedBreakfast = "No meals"
            savedLunch = "No meals"
            savedDinner = "No meals"
        }
        else{
            savedBreakfast = self.arrayOfMeals.first!.breakfast
            savedLunch = self.arrayOfMeals.first!.lunch
            savedDinner = self.arrayOfMeals.first!.dinner
        }
        
        
        savedMeals.setValue(savedBreakfast, forKey: "MealBreakfast")
        savedMeals.setValue(savedLunch, forKey: "MealLunch")
        savedMeals.setValue(savedDinner, forKey: "MealDinner")
        println(savedMeals.valueForKey("MealArray"))
    }
    
    override func viewDidAppear(animated: Bool) {
        didAppearCount++
        navigationController?.navigationBar.topItem?.title = "The Meals"
        if (didAppearCount > 1) {
            if self.arrayOfMeals.isEmpty == true {
                self.presentViewController(displayNoMeals(), animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func handleRefreshForMeals() {
        refreshControl.beginRefreshing()
        arrayOfMeals.removeAll(keepCapacity: false)
        let urlString = ("http://www.seandeaton.com/meals/Meals")
        retrieveJSON(urlString) {
            (responseObject, error) -> () in
            
            if responseObject == nil {
                println(error)
                refreshControl.endRefreshing()
                self.presentViewController(displayMealFetchFailure(), animated: true, completion: nil)
                return
            }
            for days in self.weekDayArray {
                var newResponse: NSArray = responseObject![days] as! NSArray
                
                for obj: AnyObject in newResponse{
                    
                    var breakfast = (obj.objectForKey("breakfast")! as! String)
                    var lunch = (obj.objectForKey("lunch")! as! String)
                    var dinner = obj.objectForKey("dinner")! as! String
                    let dateString = obj.objectForKey("dateString")! as! String
                    let dayOfWeek = obj.objectForKey("dayOfWeek")! as! String
                    
                    var breakfastArrayForDifferentDevices = breakfast.componentsSeparatedByString("|")
                    var lunchArrayForDifferentDevices = lunch.componentsSeparatedByString("|")
                    var dinnerArrayForDifferentDevices = dinner.componentsSeparatedByString("|")
                    //println(breakfastArrayForDifferentDevices)
                    if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
                        if (breakfastArrayForDifferentDevices.count > 1){
                            breakfast = (breakfastArrayForDifferentDevices[0] + breakfastArrayForDifferentDevices[1])
                        }else {
                            breakfast = breakfastArrayForDifferentDevices[0]
                        }
                        if (lunchArrayForDifferentDevices.count>1){
                            lunch = (lunchArrayForDifferentDevices[0] + lunchArrayForDifferentDevices[1])
                        }else{
                            lunch = lunchArrayForDifferentDevices[0]
                        }
                        if (dinnerArrayForDifferentDevices.count>1){
                            dinner = (dinnerArrayForDifferentDevices[0] + dinnerArrayForDifferentDevices[1])
                        }else {
                            dinner = dinnerArrayForDifferentDevices[0]
                        }
                    }
                    else {
                        breakfast = breakfastArrayForDifferentDevices[0]
                        lunch = lunchArrayForDifferentDevices[0]
                        dinner = dinnerArrayForDifferentDevices[0]
                        
                    }
                    
                    let newMeal = Meal(breakfast: breakfast, lunch: lunch, dinner: dinner, dayOfWeek: dayOfWeek, dateString: dateString)
                    if theDays(newMeal.dateString) >= -1 {
                        //self.arrayOfMeals.removeAtIndex(find(self.weekDayArray, days)!)
                        //self.arrayOfMeals.insert(newMeal, atIndex: find(self.weekDayArray, days)! - 1)
                        self.arrayOfMeals.append(newMeal)
                        //self.arrayOfMeals.removeAtIndex(0)
                    }
                }
                
                
                self.mealTableView.reloadData()
                
            }
            
            
            if self.arrayOfMeals.isEmpty == true {
                self.presentViewController(displayNoMeals(), animated: true, completion: nil)
            }
            
            hideActivityIndicator()
            self.mealTableView.reloadData()
            //println(self.arrayOfMeals.count)
        }
        
        
        refreshControl.endRefreshing()
    }
    
    func convertDateToString(aDate: NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString: String = (dateFormatter.stringFromDate(aDate) as String)
        return dateString
        
    }
    
    
    //MARK: Table Functions
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfMeals.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:CustomMealCellTableViewCell = tableView.dequeueReusableCellWithIdentifier("MealCell") as! CustomMealCellTableViewCell
        var oneMeal = arrayOfMeals[indexPath.row]
        
        
        cell.setCell(oneMeal.dayOfWeek, breakfastLabel: oneMeal.breakfast, lunchLabel: oneMeal.lunch, dinnerLabel: oneMeal.dinner, dateString: oneMeal.dateString)
        return cell
        
        
        
    }
    
    
    
    //    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //        var selectedRowIndex = indexPath
    //        currentRow = selectedRowIndex.row
    //
    //        tableView.beginUpdates()
    //        tableView.endUpdates()
    //    }
    //
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        if indexPath.row == currentRow {
    //            if cellTapped == false {
    //                cellTapped = true
    //                return 150
    //            } else {
    //                cellTapped = false
    //                return 350
    //            
    //            }
    //        }
    //        return 163
    //    }
    
    
}
