//
//  ViewController.swift
//  logit-ios
//
//  Created by William Bradley on 10/12/14.
//  Copyright (c) 2014 wbbradley. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

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

		buttonLogIt.setTitle("Log It", forState: UIControlState.Normal)

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
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func findMyLocation(sender: AnyObject) {
		labelDebug.text = textViewNotes.text
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
