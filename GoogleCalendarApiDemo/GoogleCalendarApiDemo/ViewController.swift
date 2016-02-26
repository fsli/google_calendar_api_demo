//
//  ViewController.swift
//  GoogleCalendarApiDemo
//
//  Created by Ferris Li on 2/24/16.
//  Copyright © 2016 Ferris Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let kKeychainItemName = GTLHelper.config.keychain_name
    private let kClientID = GTLHelper.config.client_id
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = GTLHelper.config.scopes

    
    private let service = GTLServiceCalendar()
    
    @IBOutlet weak var output: UITextView!
    @IBOutlet weak var textEventTitle: UITextField!
    // When the view loads, create necessary subviews
    // and initialize the Google Calendar API service
    @IBOutlet weak var datetimeEventStart: UIDatePicker!
    @IBOutlet weak var textEventDescription: UITextField!
    
    @IBOutlet weak var buttonAddEvent: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let now = NSDate()
        let tomorrow = now.dateByAddingTimeInterval(3600*24)
        datetimeEventStart.date = tomorrow
        buttonAddEvent.addTarget(self, action: "onAddEventButtonTouchUpInside:", forControlEvents: UIControlEvents.TouchUpInside)

        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
                service.authorizer = auth
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // When the view appears, ensure that the Google Calendar API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
                fetchEvents()
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    // Construct a query and get a list of upcoming events from the user calendar
    func fetchEvents() {
       
        let query = GTLQueryCalendar.queryForEventsListWithCalendarId("primary")
        query.maxResults = 10
        query.timeMin = GTLDateTime(date: NSDate(), timeZone: NSTimeZone.localTimeZone())
        query.singleEvents = true
        query.orderBy = kGTLCalendarOrderByStartTime
        service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: "displayResultWithTicket:finishedWithObject:error:"
        )
    }
    
    // Display the start dates and event summaries in the UITextView
    func displayResultWithTicket(
        ticket: GTLServiceTicket,
        finishedWithObject response : GTLCalendarEvents,
        error : NSError?) {
            
            if let error = error {
                showAlert("Error", message: error.localizedDescription)
                return
            }
            
            var eventString = ""
            
            if let events = response.items() where !events.isEmpty {
                for event in events as! [GTLCalendarEvent] {
                    var start : GTLDateTime! = event.start.dateTime ?? event.start.date
                    var startString = NSDateFormatter.localizedStringFromDate(
                        start.date,
                        dateStyle: .ShortStyle,
                        timeStyle: .ShortStyle
                    )
                    eventString += "\(startString) - \(event.summary)\n"
                }
            } else {
                eventString = "No upcoming events found."
            }
            
            output.text = eventString
    }
    
    
    // Creates the auth controller for authorizing access to Google Calendar API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")// " ".join(scopes)
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: "viewController:finishedWithAuth:error:"
        )
    }
    
    // Handle completion of the authorization process, and update the Google Calendar API
    // with the new credentials.
    func viewController(vc : UIViewController,
        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
            
            if let error = error {
                service.authorizer = nil
                showAlert("Authentication Error", message: error.localizedDescription)
                return
            }
            
            service.authorizer = authResult
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertView(
            title: title,
            message: message,
            delegate: nil,
            cancelButtonTitle: "OK"
        )
        alert.show()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func onAddEventButtonTouchUpInside(sender: UIButton) {
        let title:String = self.textEventTitle.text!
        let description:String = self.textEventDescription.text!
        let startDatetime:NSDate = self.datetimeEventStart.date
        let endDatetime:NSDate = self.datetimeEventStart.date.dateByAddingTimeInterval(3600)
        let newEvent = GTLHelper.createGTLCalendarEvent(title, description: description, start: startDatetime, end: endDatetime)
        let query = GTLQueryCalendar.queryForEventsInsertWithObject(newEvent, calendarId: "primary")
        service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: "displayNewEventResultWithTicket:id:error:"
        )
    }
    
    func displayNewEventResultWithTicket(
        ticket: GTLServiceTicket,
        id: GTLObject,
        error : NSError?) {
            
            if let error = error {
                showAlert("Error", message: error.localizedDescription)
                return
            } else {
                showAlert("Success", message: "New event has been added")
                fetchEvents()
            }
            
    }
    
}
