//
//  Constants.swift
//  Advantage
//
//  Created by macbook on 7/26/18.
//  Copyright © 2018 Anjali Panjawani. All rights reserved.
//

import Foundation
struct Constants {
    public struct FirebaseKeys {
        

        // Screen view events.
        static let LANDING_SCREEN_VIEW = "splash_screen"
        static let FIND_A_CAR_PAGE_VIEW = "search_view"
        static let RESERVE_PAGE_VIEW = "reservation_reserve"
        static let RESERVATION_CONFIRMATION_PAGE_VIEW = "reservation_confirm"
        static let RESERVATION_CONF_PAY_NOW_PAGE = "reservation_pay_now"
        static let VIEW_RESERVATION_PAGE_VIEW = "view_reservation"
        static let CANCEL_RESERVATION = "reservation_cancel"
        
        //Find Car Page Event
        static let PICK_UP_LOCATION_SELECT = "pick_up_location_select"
        static let DROP_OFF_LOCATION_SELECT = "drop_off_location_select"

        // Selected car event.
        static let SELECTED_CAR_PAY_NOW = "select_car_pay_now"
        static let SELECTED_CAR_PAY_LATER = "select_car_pay_later"
        static let DAILY_RATE = "daily_rate"
        static let WEEKLY_RATE = "weekly_rate"

        // Logout Event
        static let LOGOUT = "logout";

        
        
    }

}

