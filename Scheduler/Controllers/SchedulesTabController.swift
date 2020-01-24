//
//  SchedulesTabController.swift
//  Scheduler
//
//  Created by Maitree Bain on 1/24/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class SchedulesTabController: UITabBarController {
    
    private let dataPersistence = DataPersistence<Event>(filename: "schedules.plist")
    
    private lazy var schedulesNavController: UINavigationController = {
        guard let navController = storyboard?.instantiateViewController(identifier: "ScheduleNavController") as? UINavigationController,
            let schedulesListController = navController.viewControllers.first as? ScheduleListController else {
                fatalError("could not load nav controller")
        }
        schedulesListController.dataPersistence = dataPersistence
        
        return navController
    }()
    
    //first we get access to the UINavigationController
    //then we access the first view controller
    private lazy var completedNavController: UINavigationController = {
        guard let navController = storyboard?.instantiateViewController(identifier: "CompletedNavController") as? UINavigationController,
            let completedController = navController.viewControllers.first as? CompletedScheduleController else {
                fatalError("could not load nav controller")
        }
        completedController.dataPersistence = dataPersistence
        // step 4: custom delegation - set delegate object
        completedController.dataPersistence.delegate = completedController
        return navController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [schedulesNavController, completedNavController]
    }
    
    
}
