//
//  GTLHelper.swift
//  GoogleCalendarApiDemo
//
//  Created by Ferris Li on 2/24/16.
//  Copyright © 2016 Ferris Li. All rights reserved.
//

import Foundation

class GTLHelper {
    struct config {
        static let keychain_name = "GoogleCalendarApiDemo"
        static let client_id = "750203292978-ang61nhjubjmfjgak8eapbhdf67ertvb.apps.googleusercontent.com"
        static let scopes = [kGTLAuthScopeCalendar]
    }
    class func createGTLCalendarEvent(title: String,description: String, start: NSDate, end: NSDate) -> GTLCalendarEvent   {
        let gtlStartDatetime:GTLDateTime = GTLDateTime(date:start , timeZone: NSTimeZone.systemTimeZone())
        let gtlEndDatetime:GTLDateTime = GTLDateTime(date: end, timeZone: NSTimeZone.systemTimeZone())
        let newEvent:GTLCalendarEvent = GTLCalendarEvent()
        newEvent.summary = title
        newEvent.descriptionProperty = description
        let eventStartDatetime:GTLCalendarEventDateTime = GTLCalendarEventDateTime()
        eventStartDatetime.dateTime = gtlStartDatetime
        newEvent.start = eventStartDatetime
        let eventEndDatetime:GTLCalendarEventDateTime = GTLCalendarEventDateTime()
        eventEndDatetime.dateTime = gtlEndDatetime
        newEvent.end = eventEndDatetime
        return newEvent
    }
}