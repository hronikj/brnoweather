//
//  ViewController.swift
//  BrnoWeather
//
//  Created by Jiří Hroník on 16.02.16.
//  Copyright © 2016 Jiří Hroník. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
    
    @IBAction func refreshButton(sender: UIButton) {
        refreshActivityIndicator.hidden = false
        refreshActivityIndicator.startAnimating()
        getWeatherDataFromUrl("https://api.wunderground.com/api/32ca3e99da3f6f09/conditions/q/CA/Brno.json")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshActivityIndicator.hidden = true
        // Do any additional setup after loading the view, typically from a nib.
        
        getWeatherDataFromUrl("https://api.wunderground.com/api/32ca3e99da3f6f09/conditions/q/CA/Brno.json")
    }
    
    override func viewDidAppear(animated: Bool) {}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWeatherDataFromUrl(urlString: String) {
        print("! getWeatherDataFromUrl")
        let url = NSURL(string: urlString)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
            dispatch_sync(dispatch_get_main_queue(), {
                if (error == nil) {
                    self.parseJson(data!)
                } else {
                    // construct new UIAlertController
                    let dataLoadingError = UIAlertController(title: "Error loading data", message: "Error occured while loading data from URL", preferredStyle: UIAlertControllerStyle.Alert)
                    // adds a dismiss button
                    dataLoadingError.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(dataLoadingError, animated: true, completion: nil) // display
                }
            })
        }
        task.resume()
        
    }
    
    func parseJson(dataFromUrl: NSData) {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(dataFromUrl, options: []) as! NSDictionary
            if let currentObservation = json["current_observation"] as? NSDictionary {
                print(currentObservation.allKeys)
                print("Temperature is: \(currentObservation["temp_c"]!)")
                print("Image is: \(currentObservation["image"]!.valueForKey("url")!)")
                
                locationLabel.text = "\(currentObservation["display_location"]!.valueForKey("full")!)"
                temperatureLabel.text = "\(currentObservation["temp_c"]!) °C"
                weatherLabel.text = "\(currentObservation["weather"]!)"
                
                let iconImageURLString = "\(currentObservation["icon_url"]!)"
                let iconImageURL = NSURL(string: iconImageURLString)
                
                if let iconImageData = NSData(contentsOfURL: iconImageURL!) {
                    weatherImage.image = UIImage(data: iconImageData)
                }
            }
            
        }
        
        catch {
            let parseJsonAlert = UIAlertController(title: "JSON Parser Error", message: "Error occured while parsing JSON", preferredStyle: UIAlertControllerStyle.Alert)
            parseJsonAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(parseJsonAlert, animated: true, completion: nil)
        }
        
        refreshActivityIndicator.stopAnimating()
        refreshActivityIndicator.hidden = true
    }

}

