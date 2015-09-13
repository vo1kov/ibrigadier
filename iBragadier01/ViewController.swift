//
//  ViewController.swift
//  iBragadier01
//
//  Created by Mikhail Volkov on 15.02.15.
//  Copyright (c) 2015 imsut. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate {

      
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        
    }
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var typePicker: UIPickerView!
    var imagePicker: UIImagePickerController!
    var defectType : String!
    
    
    var longitudeN:NSNumber!
    var latitudeN:NSNumber!
    
    
 
    let pickerData = ["Pav11ement","Shoulder","Markings","Водосброс","Брус","Знак","Полоса съезда","Прочее"]

    override func viewDidLoad() {
        
        self.latitude = "37"
        self.longitude = "55"
        self.defectType = "Покрытие"
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        typePicker.dataSource = self
        typePicker.delegate = self
        
        
        backLabel.backgroundColor = UIColor.whiteColor()
        
        
        
        var nav = self.navigationController?.navigationBar
        
      // nav?.barStyle = UIBarStyle.Black
        
        nav?.barTintColor =  UIColor(red: 63.0/256.0, green: 102.0/256.0, blue: 190.0/256.0, alpha: 1.0)

        //nav?.backgroundColor = UIColor(red: 63.0, green: 102.0, blue: 190.0, alpha: 1.0)
        

        
        
       // nav?.barTintColor = UIColor.blueColor()
        
     
        nav?.tintColor = UIColor.whiteColor()
        let prefButton = UIBarButtonItem(image: UIImage(named: "pref"), style: UIBarButtonItemStyle.Bordered , target: self, action: "tabBarPrefClicked")
        let listButton = UIBarButtonItem(image: UIImage(named: "list"), style: UIBarButtonItemStyle.Bordered , target: self, action: "tabBarListClicked")

        navigationItem.title = "Бригадир"
        
        nav?.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        navigationItem.rightBarButtonItem = prefButton
        navigationItem.leftBarButtonItem = listButton

        
        
        
        
    }
    
    func tabBarListClicked(){
        performSegueWithIdentifier("listSegue", sender: self)
    }
    
    func tabBarPrefClicked(){
        performSegueWithIdentifier("prefSegue", sender: self)
    }
    
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       // myLabel.text = pickerData[row]
        defectType = pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let pickerLabel = UILabel()
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 20.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.attributedText = myTitle
        
        //let hue = CGFloat(row)/CGFloat(pickerData.count)
        //pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness:1.0, alpha: 1.0)
        pickerLabel.textAlignment = .Center
        return pickerLabel
        
        //return pickerLabel
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var coordinatesLabel: UILabel!
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBAction func testNS(sender: AnyObject) {
        
        if let moc = self.managedObjectContext {
            
        DefectItem.createInManagedObjectContext(moc, type:self.defectType , adress: self.adressLabel.text!, image: self.data, latitude: self.latitudeN, longitude: self.longitudeN)
        }

        
    }
   
    
    func makePhoto()
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .Camera
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    
    func get(path: String) {
        let url = NSURL(string: path)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            //println("Task completed")
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            else
            {
                var err: NSError?
            
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
                if(err != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                else
                {
                    if let adress : NSArray = jsonResult.valueForKeyPath("response.GeoObjectCollection.featureMember.GeoObject.name") as? NSArray{
                        if let city : NSArray = jsonResult.valueForKeyPath("response.GeoObjectCollection.featureMember.GeoObject.description") as? NSArray{
                            dispatch_async(dispatch_get_main_queue()) {
                                self.adressLabel.text = city[0].description! + ", " + adress[0].description!
                            }}
                    }
                }
            }
        })
        task.resume()
    }

    func sendPosition(path: String) {
        let url = NSURL(string: path)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            //println("sendPosition completed")
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
        })
        task.resume()
    }
    
    @IBAction func takePhoto() {
        
      //let 😈 = "трололо"
       makePhoto()
    }
    
    
    @IBOutlet weak var adressLabel: UILabel!
    //var imageArray: Array<Byte>
    //var array = [Byte](count: 1, repeatedValue: 0)
    var data:NSData = NSData()
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        
        let image = imageView.image! //UIImage(contentsOfFile: self.URL.absoluteString!)
        
        let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.1, 0.1))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imageView.contentMode = .ScaleAspectFit
        imageView.image = scaledImage
        
        
      /*if(scaledImage.size.height<scaledImage.size.width)
      {
        let height = imageView.frame.height
        
       let size = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: imageView.frame.height, height: imageView.frame.width))
        
        imageView.frame = size
        
        println("landscape detected")
        
        //imageView.frame.height = imageView.frame.width
        //imageView.frame.width = height
        
        }*/
        
        var compression :CGFloat
        compression = 0.5
        self.data = UIImageJPEGRepresentation(scaledImage, compression)
        
        
        let count = data.length / sizeof(UInt32)
        
        
        sendButton.enabled = true
    }

    let locationManager = CLLocationManager()
    var target : CLLocation!
    var latitude : String!
    var longitude :String!
    
    @IBOutlet weak var backLabel: UILabel!
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
            //self.target = CLLocation(:  55.802049, longitude: 37.529035)
            //+ "\nДо точки:" + manager.location.distanceFromLocation(self.target).description
        //if(manager.location.coordinate != nil)
       // {
            self.coordinatesLabel.text =  manager.location.coordinate.longitude.description
                             + ", " + manager.location.coordinate.latitude.description + " (\(Int(manager.location.horizontalAccuracy)) м)"
        
            self.latitude = manager.location.coordinate.latitude.description//.substringToIndex(advance(self.latitude.startIndex, 11))
            self.longitude = manager.location.coordinate.longitude.description//.substringToIndex(advance(self.longitude.startIndex, 11))
        
       
         self.latitudeN = manager.location.coordinate.latitude
         self.longitudeN = manager.location.coordinate.longitude
        
        
        
            get("http://geocode-maps.yandex.ru/1.x/?format=json&geocode=\(self.longitude),\(self.latitude)&results=1")
        //http://mkiit.ru/dep/addPoint.php?latitude=42&longitude=42&workerId=0
         sendPosition("http://mkiit.ru/dep/addPoint.php?latitude=\(self.latitude)&longitude=\(self.longitude)&workerId=0")
        
        
      //  }
    }
    
    
    @IBAction func sendDefect(sender: AnyObject) {
        //http://mkiit.ru/dep/addDefect.php?latitude=42&longitude=42&defectType=Покрытие
        //var surl = "http://109.188.74.153:8080/ObjectMonitoring/addDefect.htm?latitude="+self.latitude + "&longitude=" + self.longitude + "&defectType=" + self.defectType
        
        var surl = "http://mkiit.ru/dep/addDefect.php?latitude="+self.latitude + "&longitude=" + self.longitude + "&defectType=" + self.defectType
        
        
        //var escapedAddress = surl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var escapedUrl = surl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())

        let urlpath = escapedUrl!
       
        //stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding
        var url: NSURL = NSURL(string: urlpath)!
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        request.HTTPMethod = "POST"
        request.HTTPBody = data
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            {
                (response, data, error) in
                if(error != nil)
                {
                    println("JSON Error \(error!.localizedDescription)")
                }
                else
                {
                    
                    let count = data.length / sizeof(UInt8)
                    
                    // create array of appropriate length:
                    var array = [UInt8](count: count, repeatedValue: 0x0)
                    
                    // copy bytes into array
                    data.getBytes(&array, length: count * sizeof(UInt8))
                    let str = NSString(bytes: &array, length: count, encoding: NSUTF8StringEncoding)
                    
                    let alertController = UIAlertController(title: "Статус", message:
                        str! as String, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    println(str)
                }
                //парсить результат
                //let str = NSString(bytes: &char, length: 1, encoding: NSUTF8StringEncoding)
                
        }
        
        
        //var alert = UIAlertView(title: "Success!", message: surl, delegate: nil, cancelButtonTitle: "Okay.")
        //alert.show()
        
    }
}