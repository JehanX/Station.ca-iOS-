//
//  ViewController.swift
//  Station.ca
//
//  Created by fwsstaff adminsitrator on 2016-05-17.
//  Copyright © 2016 Register.ca Inc. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, UIGestureRecognizerDelegate {
    
    //Outlet definition
    @IBOutlet var webView: UIWebView!
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var button4: UIButton!
    @IBOutlet var button5: UIButton!
    @IBOutlet var Exp_list: UITableView!
    @IBOutlet var ErrorMessage: UITextView!
    
    //View between tableView and webView
    @IBOutlet var mask: UIView!
    
    //Outlet constraints definition


    @IBOutlet var TBWidthConstraint: NSLayoutConstraint!
    @IBOutlet var TBHeightConstraint: NSLayoutConstraint!
    @IBOutlet var button1_width: NSLayoutConstraint!
    @IBOutlet var button2_width: NSLayoutConstraint!
    @IBOutlet var button3_width: NSLayoutConstraint!
    @IBOutlet var button4_width: NSLayoutConstraint!
    @IBOutlet var button5_width: NSLayoutConstraint!
    
    //Button action definition
    @IBAction func button1_action(sender: AnyObject) {
        ButtonClicked(1)
    }
    @IBAction func button2_action(sender: AnyObject) {
        ButtonClicked(2)
    }
    @IBAction func button3_action(sender: AnyObject) {
        ButtonClicked(3)
    }
    @IBAction func button4_action(sender: AnyObject) {
        ButtonClicked(4)
    }
    @IBAction func button5_action(sender: AnyObject) {
        ButtonClicked(5)
    }
    
    //Variable definition
    var Home_URL = ""
    var Phone_Number = ""
    var Contact_Email = ""
    var visibleRows = [Int]()
    var Num_Menu = 0
    var Num_Button = 0
    var Menu_Info: NSMutableArray! = [] //Every entries is a dictionary stores both the information of menu and submenu
    var Buttons_Info : NSMutableArray! = [] //Every entries is a dictionary stores the information of buttons
    var internet : Bool = false
    var jsonwrong : Bool = false
    var total_menu_submenu = 0
    var Color_List: NSMutableArray! = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        //Hide all buttons
        button1.hidden = true
        button2.hidden = true
        button3.hidden = true
        button4.hidden = true
        button5.hidden = true
        ErrorMessage.hidden = true
        
        //Share cookies between different servers
        NSHTTPCookieStorage.sharedHTTPCookieStorage().cookieAcceptPolicy = NSHTTPCookieAcceptPolicy.Always
        //Attach tap gesture recognizer to mask
        let selector : Selector = #selector(ViewController.maskViewTouch(_:))
        let tapGesture = UITapGestureRecognizer(target: self, action: selector)
        tapGesture.numberOfTapsRequired = 1
        mask.addGestureRecognizer(tapGesture)
        
        //Make mask as clear
        mask.backgroundColor = UIColor.clearColor()
        //Disable mask
        mask.userInteractionEnabled = false
        
        webView.delegate = self
        
        //Hide menu section
        Exp_list.hidden = true
        
        //Set border and corner radius of buttons
        button1.layer.cornerRadius = 5
        button1.layer.borderWidth = 1
        button1.layer.borderColor = UIColor.blackColor().CGColor
        button2.layer.cornerRadius = 5
        button2.layer.borderWidth = 1
        button2.layer.borderColor = UIColor.blackColor().CGColor
        button3.layer.cornerRadius = 5
        button3.layer.borderWidth = 1
        button3.layer.borderColor = UIColor.blackColor().CGColor
        button4.layer.cornerRadius = 5
        button4.layer.borderWidth = 1
        button4.layer.borderColor = UIColor.blackColor().CGColor
        button5.layer.cornerRadius = 5
        button5.layer.borderWidth = 1
        button5.layer.borderColor = UIColor.blackColor().CGColor
        
        //Set default width of buttons
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let buttonSize = screenWidth / 5
        button1_width.constant = buttonSize
        button2_width.constant = buttonSize
        button3_width.constant = buttonSize
        button4_width.constant = buttonSize
        button5_width.constant = buttonSize
        
        //Default text on buttons
        button1.setTitle("BACK", forState: UIControlState.Normal)
        button2.setTitle("PHONE", forState: UIControlState.Normal)
        button3.setTitle("HOME", forState: UIControlState.Normal)
        button4.setTitle("EMAIL", forState: UIControlState.Normal)
        button5.setTitle("MENU", forState: UIControlState.Normal)
        
        //Default image on buttons
        button1.setImage(UIImage(named: "back_button"), forState: .Normal)
        button2.setImage(UIImage(named: "phone_button"), forState: .Normal)
        button3.setImage(UIImage(named: "home_button"), forState: .Normal)
        button4.setImage(UIImage(named: "email_button"), forState: .Normal)
        button5.setImage(UIImage(named: "menu_button"), forState: .Normal)
        
        //Center image and text on buttons
        let spacing: CGFloat=6.0
        
        let imageSize1: CGSize = button1.imageView!.image!.size
        button1.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize1.width, -(imageSize1.height + spacing), 0.0)
        let labelString1 = NSString(string: button1.currentTitle!)
        let titleSize1 = labelString1.sizeWithAttributes([NSFontAttributeName: button1.titleLabel!.font])
        button1.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize1.height + spacing), 0.0, 0.0, -titleSize1.width)
        let edgeOffset1 = abs(titleSize1.height - imageSize1.height) / 2.0;
        button1.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset1, 0.0, edgeOffset1, 0.0)
        
        let imageSize2: CGSize = button2.imageView!.image!.size
        button2.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize2.width, -(imageSize2.height + spacing), 0.0)
        let labelString2 = NSString(string: button2.currentTitle!)
        let titleSize2 = labelString2.sizeWithAttributes([NSFontAttributeName: button2.titleLabel!.font])
        button2.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize2.height + spacing), 0.0, 0.0, -titleSize2.width)
        let edgeOffset2 = abs(titleSize2.height - imageSize2.height) / 2.0;
        button2.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset2, 0.0, edgeOffset2, 0.0)
        
        let imageSize3: CGSize = button3.imageView!.image!.size
        button3.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize3.width, -(imageSize3.height + spacing), 0.0)
        let labelString3 = NSString(string: button3.currentTitle!)
        let titleSize3 = labelString3.sizeWithAttributes([NSFontAttributeName: button3.titleLabel!.font])
        button3.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize3.height + spacing), 0.0, 0.0, -titleSize3.width)
        let edgeOffset3 = abs(titleSize3.height - imageSize3.height) / 2.0;
        button3.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset3, 0.0, edgeOffset3, 0.0)
        
        let imageSize4: CGSize = button4.imageView!.image!.size
        button4.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize4.width, -(imageSize4.height + spacing), 0.0)
        let labelString4 = NSString(string: button4.currentTitle!)
        let titleSize4 = labelString4.sizeWithAttributes([NSFontAttributeName: button4.titleLabel!.font])
        button4.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize4.height + spacing), 0.0, 0.0, -titleSize4.width)
        let edgeOffset4 = abs(titleSize4.height - imageSize4.height) / 2.0;
        button4.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset4, 0.0, edgeOffset4, 0.0)
        
        let imageSize5: CGSize = button5.imageView!.image!.size
        button5.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize5.width, -(imageSize5.height + spacing), 0.0)
        let labelString5 = NSString(string: button5.currentTitle!)
        let titleSize5 = labelString5.sizeWithAttributes([NSFontAttributeName: button5.titleLabel!.font])
        button5.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize5.height + spacing), 0.0, 0.0, -titleSize5.width)
        let edgeOffset5 = abs(titleSize5.height - imageSize5.height) / 2.0;
        button5.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset5, 0.0, edgeOffset5, 0.0)
        
        
        
        CheckInternet()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        //Check the Internet
        
        if (internet == false) {
            button1.hidden = false
            button2.hidden = false
            button3.hidden = false
            button4.hidden = false
            button5.hidden = false
            ErrorMessage.hidden = false
            return
        }
        
        
        //Load and parse Json file
        //loadJSON("http://cloud.training101.asia.php54-3.dfw1-2.websitetestlink.com/emu/index.json")
        loadJSON("http://www.jehanxue.ca/idea/en/station.json")
    }
    func rotated() {
        if (self.internet == false || self.jsonwrong == true) {
            self.Num_Button = 5
        }
        dispatch_async(dispatch_get_main_queue()) {
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            let buttonSize = screenWidth / CGFloat(self.Num_Button)
            let buttonWidthArray = [self.button1_width,self.button2_width,self.button3_width,self.button4_width,self.button5_width]
            for i in 0...4 {
                if i < self.Num_Button {
                    buttonWidthArray[i].constant = buttonSize
                }
                else {
                    buttonWidthArray[i].constant = 0
                }
            }
            self.MenuSection_HW()
            
        }
    }
    
    //Control the height and width of menu section
    func MenuSection_HW() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let height = min(screenHeight*2/5, CGFloat(50) * CGFloat(total_menu_submenu))
        let width = screenWidth/2
        self.TBHeightConstraint.constant = height
        self.TBWidthConstraint.constant = width
    }
    
    //Check if there is internet connection. If there is internet connect, set internet as false. Otherwise, set as true.
    func CheckInternet() {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            internet = false
        }
        let isReachable = flags == .Reachable
        let needsConnection = flags == .ConnectionRequired
        internet = isReachable && !needsConnection
    }
    
    //When mask view is actived and touched, should disable mask view and hide menu section
    @IBAction func maskViewTouch(sender: AnyObject) {
        Exp_list.hidden = true
        mask.userInteractionEnabled = false
    }

    //Load target URL
    func loadAddressURL(Target: String) {
        let requestURL = NSURL(string:Target)
        let request = NSMutableURLRequest(URL:requestURL!)
        webView.loadRequest(request)
    }
    
    //Handle event when page starts loading
    func webViewDidStartLoad(webView: UIWebView) {
        self.Exp_list.hidden = true
        mask.userInteractionEnabled = false
    }
    
    //Configure menu section(TableView)
    func configureTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.Exp_list.delegate = self
            self.Exp_list.dataSource = self
            self.Exp_list.tableFooterView = UIView(frame: CGRectZero)
            self.Exp_list.registerNib(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "idCellMenu")
            self.Exp_list.registerNib(UINib(nibName: "SubmenuCell", bundle: nil), forCellReuseIdentifier: "idCellSubmenu")
            
        }
    }
    
    //Load menu section(TableView)
    func loadTableView() {
            getIndicesOfVisibleRows()
            Exp_list.reloadData()
    }
    
    //Get visible rows for each menu
    func getIndicesOfVisibleRows() {
        visibleRows = [Int]()
        if Menu_Info.count == 0 {
            visibleRows = []
        }
        else {
            for row in 0...(Menu_Info.count - 1) {
                if Menu_Info[row]["isVisible"] as! Bool == true {
                    visibleRows.append(row)
                }
            }
        }
    }
    
    //Get menu cell from indexpath
    func getMenuFromIndexPath(indexPath: NSIndexPath) -> [String: AnyObject] {
        let indexOfVisibleRow = visibleRows[indexPath.row]
        let Menu_Cell = Menu_Info[indexOfVisibleRow] as! [String: AnyObject]
        return Menu_Cell
    }
    
    //Get the total number of visible rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleRows.count
    }
    
    //Set text and image on both menu and submenu cell. Return the cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Get the current cell
        let currentCell = getMenuFromIndexPath(indexPath)
        
        //Convert the cell to CustomCell
        let cell = tableView.dequeueReusableCellWithIdentifier(currentCell["cellIdentifier"] as! String, forIndexPath: indexPath) as! CustomCell
        
        //When current cell is Menu cell
        if currentCell["cellIdentifier"] as! String == "idCellMenu" {
            if let secondaryTitle = currentCell["secondaryTitle"] {
                let indexOfTappedRow = visibleRows[indexPath.row]
                cell.MenuText.setTitle(secondaryTitle as? String, forState: .Normal)
                cell.MenuText.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                cell.MenuText.tag = indexOfTappedRow
                if (Color_List.count > 0) {
                    cell.MenuText.setTitleColor(UIColor(red: Color_List.objectAtIndex(0) as! CGFloat/255.0, green: Color_List.objectAtIndex(1) as! CGFloat/255.0, blue: Color_List.objectAtIndex(2) as! CGFloat/255.0, alpha: 1.0), forState: .Normal)
                }
                else {
                    cell.MenuText.setTitleColor(UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0), forState: .Normal)
                }
                //When menu is expanded
                if (Menu_Info[indexOfTappedRow]["isExpanded"] as! Bool == true && Menu_Info[indexOfTappedRow]["additionalRows"] as! Int != 0) {
                    cell.ExpandImage.image = UIImage(named: "arrowdown.jpg")
                }
                //When menu is not expanded
                else if (Menu_Info[indexOfTappedRow]["additionalRows"] as! Int != 0){
                    cell.ExpandImage.image = UIImage(named: "arrowright.jpg")
                }
                //When menu doesn't have submenu
                else {
                    cell.ExpandImage.image = nil
                }
                cell.MenuText.addTarget(self, action: #selector(ViewController.Menu_Click(_:)), forControlEvents: .TouchUpInside)
            }
        }
        //When current cell is submenu cell
        else {
            cell.SubmenuLabel.text = currentCell["primaryTitle"] as? String
            if (Color_List.count > 3) {
                cell.SubmenuLabel.textColor = UIColor(red: Color_List.objectAtIndex(3) as! CGFloat/255.0, green: Color_List.objectAtIndex(4) as! CGFloat/255.0, blue: Color_List.objectAtIndex(5) as! CGFloat/255.0, alpha: 1.0)
            }
        }
        return cell
    }
    
    //Return the height of cell
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    //Handle the click on cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexOfTappedRow = visibleRows[indexPath.row]
        //Menu is clicked
        if Menu_Info[indexOfTappedRow]["isExpandable"] as! Bool == true {
            var shouldExpandAndShowSubRows = false
            //Expand submenu
            if Menu_Info[indexOfTappedRow]["isExpanded"] as! Bool == false {
                shouldExpandAndShowSubRows = true
                for i in 0...Menu_Info.count-1 {
                    if Menu_Info[i]["cellIdentifier"] as! String == "idCellSubmenu" {
                        Menu_Info[i].setValue(false, forKey: "isVisible")
                    }
                    else {
                        Menu_Info[i].setValue(false, forKey: "isExpanded")
                        total_menu_submenu = Menu_Info[indexOfTappedRow]["additionalRows"] as! Int + Num_Menu
                        
                        MenuSection_HW()
                        
                    }
                    
                }
            }
            else {
                total_menu_submenu = Num_Menu
                MenuSection_HW()
            }
            Menu_Info[indexOfTappedRow].setValue(shouldExpandAndShowSubRows, forKey: "isExpanded")
            for i in (indexOfTappedRow + 1)...(indexOfTappedRow + (Menu_Info[indexOfTappedRow]["additionalRows"] as! Int)) {
                Menu_Info[i].setValue(shouldExpandAndShowSubRows, forKey: "isVisible")
            }
        }
        //Submenu is clicked
        else {
            if Menu_Info[indexOfTappedRow]["cellIdentifier"] as! String == "idCellSubmenu" {
                let targeturl = Menu_Info[indexOfTappedRow]["url"] as! String
                self.loadAddressURL(targeturl)
                for i in 0...Menu_Info.count-1 {
                    if Menu_Info[i]["cellIdentifier"] as! String == "idCellSubmenu" {
                        Menu_Info[i].setValue(false, forKey: "isVisible")
                    }
                    else {
                        Menu_Info[i].setValue(false, forKey: "isExpanded")
                    }
                }
                show_close_tbl()
            }
        }
        getIndicesOfVisibleRows()

        Exp_list.reloadData()
    }

    //Handle when menu is clicked
    func Menu_Click(sender: UIButton!) {
        let targeturl = Menu_Info[sender.tag]["url"] as! String
        //Open pop-up window
        if (targeturl == "") {
            let targetid = Menu_Info[sender.tag]["id"] as! String
            webView.stringByEvaluatingJavaScriptFromString("javascript:(function(){l=document.getElementById('\(targetid)');e=document.createEvent('HTMLEvents');e.initEvent('click',true,true);l.dispatchEvent(e);})()")
        }
            //Go to URL directly
        else {
            loadAddressURL(targeturl)
        }
        for i in 0...Menu_Info.count-1 {
            if Menu_Info[i]["cellIdentifier"] as! String == "idCellSubmenu" {
                Menu_Info[i].setValue(false, forKey: "isVisible")
            }
            else {
                Menu_Info[i].setValue(false, forKey: "isExpanded")
            }
        }
        show_close_tbl()
        getIndicesOfVisibleRows()
        Exp_list.reloadData()
        
    }
    
    //Load json file
    func loadJSON(JSONAddress: String) {
        let JSONURL = NSURL(string: JSONAddress)!
        let URLSession = NSURLSession.sharedSession()
        let jsonQuery = URLSession.dataTaskWithURL(JSONURL, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                    
                    if (jsonResult.objectForKey("homeURL") != nil) {
                        self.Home_URL = jsonResult["homeURL"] as! String
                        self.loadAddressURL(self.Home_URL)
                    }
                    if (jsonResult.objectForKey("contactPhone") != nil) {
                        self.Phone_Number = jsonResult["contactPhone"] as! String
                    }
                    if (jsonResult.objectForKey("contactEmail") != nil) {
                        self.Contact_Email = jsonResult["contactEmail"] as! String
                    }
                    
                    if (jsonResult.objectForKey("Color") != nil) {
                        let Colors: NSArray = jsonResult["Color"] as! NSArray
                        for color in Colors {
                            self.Color_List.addObject(color["r"] as! Int)
                            self.Color_List.addObject(color["g"] as! Int)
                            self.Color_List.addObject(color["b"] as! Int)
                        }
                    }
            
                    //Custimze menu section
                    if (jsonResult.objectForKey("Menu") != nil) {
                        let Menu_List: NSArray = jsonResult["Menu"] as! NSArray
                        self.Num_Menu = Menu_List.count
                        self.total_menu_submenu = Menu_List.count
                        for menu in Menu_List {
                            //When menu has submenu
                            if(menu["submenu"] as! String=="Yes") {
                                let SubMenu = jsonResult[menu["name"] as! String] as! NSArray
                                let num_submenu = SubMenu.count
                                let Menu_Name = menu["name"] as! String
                                let Menu_Url = menu["url"] as! String
                                let Menu_Id = menu["id"] as! String
                                var menu_info = ["additionalRows":num_submenu,"cellIdentifier":"idCellMenu","isExpandable":true,"isExpanded":false,"isVisible":true,"primaryTitle":"","secondaryTitle":Menu_Name,"url":Menu_Url,"id":Menu_Id] as! NSMutableDictionary
                                self.Menu_Info.addObject(menu_info as! NSMutableDictionary)
                                for submenu in SubMenu {
                                    let submenu_name = submenu["name"] as! String
                                    let submenu_url = submenu["url"] as! String
                                    let submenu_info = ["additionalRows":0,"cellIdentifier":"idCellSubmenu","isExpandable":false,"isExpanded":false,"isVisible":false,"primaryTitle":submenu_name,"secondaryTitle":"","url":submenu_url,"id":""] as! NSMutableDictionary
                                    self.Menu_Info.addObject(submenu_info as! NSMutableDictionary)
                                }
                            }
                            //When menu doesn't have submenu
                            else {
                                let Menu_Name = menu["name"] as! String
                                let Menu_Url = menu["url"] as! String
                                let Menu_Id = menu["id"] as! String
                                var menu_info = ["additionalRows":0,"cellIdentifier":"idCellMenu","isExpandable":false,"isExpanded":false,"isVisible":true,"primaryTitle":"","secondaryTitle":Menu_Name,"url":Menu_Url,"id":Menu_Id] as! NSMutableDictionary
                                self.Menu_Info.addObject(menu_info)
                            }
                        }
                    }
                    if (jsonResult.objectForKey("Buttons") != nil) {
                        let Button_List: NSArray = jsonResult["Buttons"] as! NSArray
                        //Custimze buttons
                        if Button_List.count != 0 {
                            dispatch_async(dispatch_get_main_queue()) {
                                let UIButtons : NSMutableArray! = [self.button1, self.button2, self.button3, self.button4, self.button5]
                                for i in 0...Button_List.count-1 {
                                    let button = Button_List[i]
                                    let button_text = button["button_text"] as! String
                                    let button_icon = button["button_icon"] as! String
                                    let button_func = button["button_func"] as! String
                                    let button_url = button["button_url"] as! String
                                    let button_info = ["button_text": button_text, "button_icon": button_icon, "button_func": button_func, "button_url": button_url]
                                    self.Buttons_Info.addObject(button_info)
                                    if let url = NSURL(string: button_icon) {
                                        if let data = NSData(contentsOfURL: url) {
                                            UIGraphicsBeginImageContext(CGSizeMake(24, 24))
                                            UIImage(data: data)?.drawInRect(CGRectMake(0, 0, 24, 24))
                                            let newImage = UIGraphicsGetImageFromCurrentImageContext()
                                            UIGraphicsEndImageContext()
                                            UIButtons[i].setTitle(button_text, forState: UIControlState.Normal)
                                            UIButtons[i].setImage(newImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), forState: UIControlState.Normal)
                                        }
                                    }
                                }
                                let spacing: CGFloat=6.0
                                
                                let imageSize1: CGSize = self.button1.imageView!.image!.size
                                self.button1.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize1.width, -(imageSize1.height + spacing), 0.0)
                                let labelString1 = NSString(string: self.button1.currentTitle!)
                                let titleSize1 = labelString1.sizeWithAttributes([NSFontAttributeName: self.button1.titleLabel!.font])
                                self.button1.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize1.height + spacing), 0.0, 0.0, -titleSize1.width)
                                let edgeOffset1 = abs(titleSize1.height - imageSize1.height) / 2.0;
                                self.button1.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset1, 0.0, edgeOffset1, 0.0)
                                
                                let imageSize2: CGSize = self.button2.imageView!.image!.size
                                self.button2.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize2.width, -(imageSize2.height + spacing), 0.0)
                                let labelString2 = NSString(string: self.button2.currentTitle!)
                                let titleSize2 = labelString2.sizeWithAttributes([NSFontAttributeName: self.button2.titleLabel!.font])
                                self.button2.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize2.height + spacing), 0.0, 0.0, -titleSize2.width)
                                let edgeOffset2 = abs(titleSize2.height - imageSize2.height) / 2.0;
                                self.button2.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset2, 0.0, edgeOffset2, 0.0)
                                
                                let imageSize3: CGSize = self.button3.imageView!.image!.size
                                self.button3.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize3.width, -(imageSize3.height + spacing), 0.0)
                                let labelString3 = NSString(string: self.button3.currentTitle!)
                                let titleSize3 = labelString3.sizeWithAttributes([NSFontAttributeName: self.button3.titleLabel!.font])
                                self.button3.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize3.height + spacing), 0.0, 0.0, -titleSize3.width)
                                let edgeOffset3 = abs(titleSize3.height - imageSize3.height) / 2.0;
                                self.button3.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset3, 0.0, edgeOffset3, 0.0)
                                
                                let imageSize4: CGSize = self.button4.imageView!.image!.size
                                self.button4.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize4.width, -(imageSize4.height + spacing), 0.0)
                                let labelString4 = NSString(string: self.button4.currentTitle!)
                                let titleSize4 = labelString4.sizeWithAttributes([NSFontAttributeName: self.button4.titleLabel!.font])
                                self.button4.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize4.height + spacing), 0.0, 0.0, -titleSize4.width)
                                let edgeOffset4 = abs(titleSize4.height - imageSize4.height) / 2.0;
                                self.button4.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset4, 0.0, edgeOffset4, 0.0)
                                
                                let imageSize5: CGSize = self.button5.imageView!.image!.size
                                self.button5.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize5.width, -(imageSize5.height + spacing), 0.0)
                                let labelString5 = NSString(string: self.button5.currentTitle!)
                                let titleSize5 = labelString5.sizeWithAttributes([NSFontAttributeName: self.button5.titleLabel!.font])
                                self.button5.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize5.height + spacing), 0.0, 0.0, -titleSize5.width)
                                let edgeOffset5 = abs(titleSize5.height - imageSize5.height) / 2.0;
                                self.button5.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset5, 0.0, edgeOffset5, 0.0)
                            }
                        }
                        self.Num_Button = Button_List.count
                    }
                }
                //Handle menu section height
                dispatch_async(dispatch_get_main_queue()) {
                    let screenSize: CGRect = UIScreen.mainScreen().bounds
                    let screenWidth = screenSize.width
                    let buttonSize = screenWidth / CGFloat(self.Num_Button)
                    let buttonWidthArray = [self.button1_width,self.button2_width,self.button3_width,self.button4_width,self.button5_width]
                    for i in 0...4 {
                        if i < self.Num_Button {
                            buttonWidthArray[i].constant = buttonSize
                        }
                        else {
                            buttonWidthArray[i].constant = 0
                        }
                    }

                    self.button1.hidden = false
                    self.button2.hidden = false
                    self.button3.hidden = false
                    self.button4.hidden = false
                    self.button5.hidden = false
                    self.configureTableView()
                    self.loadTableView()
                }
                
            } catch let error as NSError {
                dispatch_async(dispatch_get_main_queue()) {
                    let screenSize: CGRect = UIScreen.mainScreen().bounds
                    let screenWidth = screenSize.width
                    let buttonSize = screenWidth / 5
                    self.button1_width.constant = buttonSize
                    self.button2_width.constant = buttonSize
                    self.button3_width.constant = buttonSize
                    self.button4_width.constant = buttonSize
                    self.button5_width.constant = buttonSize
                    self.button1.hidden = false
                    self.button2.hidden = false
                    self.button3.hidden = false
                    self.button4.hidden = false
                    self.button5.hidden = false
                    self.ErrorMessage.text = "There is something wrong.\n Please try it again later."
                    self.mask.userInteractionEnabled = false
                    self.webView.userInteractionEnabled = false
                    self.ErrorMessage.hidden = false
                }
                self.jsonwrong = true
            }
        });
        jsonQuery.resume()
        
    }
    
    
    //Handle buttons' functionality
    func ButtonClicked(button_num : Int) {
        if jsonwrong == true || internet == false {
            return
        }
        var button_func : String! = ""
        var button_url : String! = ""
        
        //No customized buttons, use default
        if Buttons_Info.count == 0 {
            switch button_num {
            case 1:
                button_func = "Back"
                break
            case 2:
                button_func = "Phone"
                break
            case 3:
                button_func = "Home"
                break
            case 4:
                button_func = "Email"
                break
            case 5:
                button_func = "Menu"
                break
            default:
                break
            }
        }
            //Customize
        else {
            let button = Buttons_Info[button_num-1]
            button_func = button["button_func"] as! String
            button_url = button["button_url"] as! String
        }
        
        //Set functionaliy
        switch button_func {
        case "Back":
            Exp_list.hidden = true
            webView.goBack()
            break
        case "Home":
            Exp_list.hidden = true
            loadAddressURL(Home_URL)
            break
        case "Phone":
            Exp_list.hidden = true
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://"+Phone_Number)!)
            break
        case "Email":
            Exp_list.hidden = true
            if (Contact_Email == "") {
                return
            }
            let url = NSURL(string: "mailto:\(Contact_Email)")
            UIApplication.sharedApplication().openURL(url!)
            break
        case "Menu":
            show_close_tbl()
            break
        case "URLlink":
            Exp_list.hidden = true
            loadAddressURL(button_url)
            break
        case "Modal":
            Exp_list.hidden = true
            webView.stringByEvaluatingJavaScriptFromString("javascript:(function(){l=document.getElementById('\(button_url)');e=document.createEvent('HTMLEvents');e.initEvent('click',true,true);l.dispatchEvent(e);})()")
        default:
            break
        }
    }
    
    //Handle status of menu section, when menu section is hidden, disable the mask. Otherwise, active mask.
    func show_close_tbl() {
        if (Exp_list.hidden == true) {
            Exp_list.hidden = false
            mask.userInteractionEnabled = true
        }
        else {
            Exp_list.hidden = true
            mask.userInteractionEnabled = false
        }
        MenuSection_HW()
    }
    
    
    
    
}

