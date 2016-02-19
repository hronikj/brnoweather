//
//  ViewController.swift
//  BrnoWeather
//
//  Created by Jiří Hroník on 16.02.16.
//  Copyright © 2016 Jiří Hroník. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func detailButtonPush(sender: UIBarButtonItem) {
        
    }
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var jsonURI: String = "https://api.wunderground.com/api/7ca42c8c31208b05/conditions/q/CA/Brno.json"
    
    var weather: String!
    var weatherImg: UIImage!
    var location: String!
    var temperature: String!
    var data: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add pull to refresh
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        
        // scroll view needs to bounce for pull to refresh
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.addSubview(self.refreshControl)
        
        getWeatherDataFromUrl(self.jsonURI)
        updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetailSegue" {
            if let destinationViewController = segue.destinationViewController as? DetailViewController {
                destinationViewController.data = self.data;
            }
        }
    }
    
    func refreshData(sender: AnyObject) {
        getWeatherDataFromUrl(self.jsonURI)
        updateUI()
        self.refreshControl.endRefreshing()
    }
    
    func updateUI() {
        temperatureLabel.text = self.temperature
        weatherLabel.text = self.weather
        locationLabel.text = self.location
        weatherImage.image = self.weatherImg
    }
    
    func throwCustomAlert(title: String, message: String) {
        // construct new UIAlertController
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        // adds a dismiss button
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
        // display
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func getWeatherDataFromUrl(urlString: String) {
        let url = NSURL(string: urlString)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
            dispatch_sync(dispatch_get_main_queue(), {
                if (error == nil) {
                    self.parseJSON(data!)
                } else {
                    self.throwCustomAlert("Error loading data", message: "Error occured while loading data from URL")
                }
            })
        }
        task.resume()
    }
    
    func parseJSON(dataFromUrl: NSData) {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(dataFromUrl, options: []) as! NSDictionary
            
            if let possibleError = json["response"]?.valueForKey("error")?.valueForKey("type") {
                // print(json["response"]!.valueForKey("error")!.valueForKey("type")!)
                if (possibleError as! String == "invalidkey") {
                    self.throwCustomAlert("Invalid API Key", message: "The API key is not valid due to exceeding rate plan!")
                    return
                }
            }
            
            if let currentObservation = json["current_observation"] as? NSDictionary {
                // print(currentObservation.allKeys)
                print("Temperature is: \(currentObservation["temp_c"]!)")
                print("Image is: \(currentObservation["image"]!.valueForKey("url")!)")
                
                self.location = "\(currentObservation["display_location"]!.valueForKey("full")!)"
                self.temperature = "\(currentObservation["temp_c"]!) °C"
                self.weather = "\(currentObservation["weather"]!)"
                
                let iconImageURLString = "\(currentObservation["icon_url"]!)"
                let iconImageURL = NSURL(string: iconImageURLString)
        
                if let iconImageData = NSData(contentsOfURL: iconImageURL!) {
                    self.weatherImg = UIImage(data: iconImageData)
                }
                
                self.data = currentObservation
            }
            updateUI()
        }
        
        catch {
            self.throwCustomAlert("JSON Parser Error", message: "Error occured while parsing JSON")
        }
        
    }

}

