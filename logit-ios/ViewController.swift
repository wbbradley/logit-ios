//
//  ViewController.swift
//  logit-ios
//
//  Created by William Bradley on 10/12/14.
//  Copyright (c) 2014 wbbradley. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate {

	var locationManager = CLLocationManager()
	var labelDebug: UILabel!
	var textViewNotes: UITextView!
	var buttonLogIt: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()
		print(self.view.frame)
		buttonLogIt = UIButton()//frame: CGRectMake(0, 0, view.frame.size.width, 20))
		labelDebug = UILabel()//frame: CGRectMake(0, 0, view.frame.size.width, 20))
		textViewNotes = UITextView()//frame: CGRectMake(0, 0, view.frame.size.width, 20))
		textViewNotes.delegate = self

		buttonLogIt.setTitle("Log It", forState: UIControlState.Normal)
		buttonLogIt.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)

		buttonLogIt.setTranslatesAutoresizingMaskIntoConstraints(false)
		labelDebug.setTranslatesAutoresizingMaskIntoConstraints(false)
		textViewNotes.setTranslatesAutoresizingMaskIntoConstraints(false)

		view.addSubview(labelDebug)
		view.addSubview(textViewNotes)
		view.addSubview(buttonLogIt)

		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
		self.labelDebug.backgroundColor = UIColor.grayColor()
		self.textViewNotes.backgroundColor = UIColor.grayColor()
		self.buttonLogIt.backgroundColor = UIColor.grayColor()
		var viewBindingsDict = NSMutableDictionary()
		viewBindingsDict.setValue(labelDebug, forKey: "labelDebug")
		viewBindingsDict.setValue(textViewNotes, forKey: "textViewNotes")
		viewBindingsDict.setValue(buttonLogIt, forKey: "buttonLogIt")

		self.view.removeConstraints(self.view.constraints())
		NSLayoutConstraint.deactivateConstraints(self.view.constraints())

		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
			"V:|-54-[labelDebug]-20-[buttonLogIt]-20-[textViewNotes]-|",
			options: NSLayoutFormatOptions(0),
			metrics: nil,
			views: viewBindingsDict
		))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
			"H:|-[labelDebug(>=100)]-|",
			options: NSLayoutFormatOptions(0),
			metrics: nil,
			views: viewBindingsDict
			))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
			"H:|-[textViewNotes(>=100)]-|",
			options: NSLayoutFormatOptions(0),
			metrics: nil,
			views: viewBindingsDict
			))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
			"H:|-[buttonLogIt(>=100)]-|",
			options: NSLayoutFormatOptions(0),
			metrics: nil,
			views: viewBindingsDict
			))

		buttonLogIt.addTarget(self, action: "findMyLocation:", forControlEvents: .TouchUpInside)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	var responseMsg : String?

	@IBAction func findMyLocation(sender: AnyObject) {
		labelDebug.text = textViewNotes.text
		var request = NSMutableURLRequest(URL: NSURL(string: "http://wormhorse.com/logit/login"))
		var session = NSURLSession.sharedSession()
		request.HTTPMethod = "POST"

		var params = ["email":"test", "password":"password"] as Dictionary

		var err: NSError?
		request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")

		var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
			println("Response: \(response)")
			var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
			println("Body: \(strData)\n\n")
			var err: NSError?
			var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as NSDictionary
			// json = {"response":"Success","msg":"User login successfully."}
			if (err != nil) {
				println(err!.localizedDescription)
			} else {
				var success = json["response"] as? String
				println("Succes: \(success)")

				if json["response"] as NSString == "Success"
				{
					println("Login Successfull")
				}
				self.responseMsg = json["msg"] as? String
				dispatch_async(dispatch_get_main_queue(), {
					self.textViewNotes.text = self.responseMsg
				})

			}
		})
		task.resume()
	}

	func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
		self.labelDebug.text = "Location \(manager.location.timestamp.timeIntervalSince1970)"
		locationManager.stopUpdatingLocation()
		CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {
			(placemarks, error) -> Void in
			if (error != nil) {
				println("Reverse geocoder failed with error" + error.localizedDescription)
				return
			}

			if placemarks.count > 0 {
				let pm = placemarks[0] as CLPlacemark
				self.updateCurrentLocationInfo(pm)
			} else {
				println("Problem with the data received from geocoder")
			}
		})
	}

	func updateCurrentLocationInfo(placemark: CLPlacemark?) {
		if let containsPlacemark = placemark {
			let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
			let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
			let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
			self.labelDebug.text = "\(locality), \(administrativeArea), \(country)"
		}
	}

	func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
	}
}
