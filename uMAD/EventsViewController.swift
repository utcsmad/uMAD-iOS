
import UIKit

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView: UITableView!
    private var events: [Event] = [Event]()
    private var rowsPerSection: [String : Int] = [String : Int]()
    private var sectionHeaders: [String] = [String]()
    private var thumbnails: [String : UIImage] = [String : UIImage]()
    
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    
    override init() {
        super.init()
        
        self.reloadData()
    }
    
     override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

     required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Events"
        
        self.tableView = UITableView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - TABBAR_HEIGHT), style: .Plain)
        self.tableView.registerClass(EventTableViewCell.self, forCellReuseIdentifier: EVENTS_TABLEVIEW_CELL_IDENTIFIER)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        view.addSubview(self.tableView)
        
        self.refreshControl.addTarget(self, action: Selector("reloadData"), forControlEvents: .ValueChanged)
        self.tableView.addSubview(self.refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func calculateIndex(indexPath: NSIndexPath) -> Int {
        var result: Int = 0
        for (var i: Int = 0; i <= indexPath.section; i++) {
            var headerString: String = self.sectionHeaders[i]
            
            if i == indexPath.section {
                result += indexPath.row
            } else if let sectionTotal: Int = self.rowsPerSection[headerString] {
                result += sectionTotal
            }
        }
        
        return result
    }
    
    func monthToInt(month: String) -> Int {
        switch month {
            case "January":
                return 0
            case "February":
                return 1
            case "March":
                return 2
            case "April":
                return 3
            case "May":
                return 4
            case "June":
                return 5
            case "July":
                return 6
            case "August":
                return 7
            case "September":
                return 8
            case "October":
                return 9
            case "November":
                return 10
            case "December":
                return 11
            default:
                fatalError("Unidentifiable month string")
        }
    }
    
    func reloadData() {
        var eventsQuery: PFQuery = PFQuery(className:"Events")
        eventsQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) in
            if error == nil {
                self.events = [Event]()
                self.rowsPerSection = [String : Int]()
                self.sectionHeaders = [String]()
                
                for object in objects {
                    var info: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
                    
                    if let sessionName: String = object["sessionName"] as? String {
                        info["sessionName"] = sessionName
                    }
                    
                    if let companyName: String = object["company"] as? String {
                        info["companyName"] = companyName
                    }
                    
                    if let room: String = object["room"] as? String {
                        info["room"] = room
                    }
                    
                    if let speaker: String = object["speaker"] as? String {
                        info["speaker"] = speaker
                    }
                    
                    if let description: String = object["description"] as? String {
                        info["description"] = description
                    }
                    
                    if let startTime: NSDate = object["startTime"] as? NSDate {
                        info["startTime"] = startTime
                        
                        var timeFormatter: NSDateFormatter = NSDateFormatter()
                        timeFormatter.timeZone = NSTimeZone(name: "America/Chicago")
                        timeFormatter.dateFormat = "MMMM d - hh:00 a";
                        
                        var timeString: String = timeFormatter.stringFromDate(startTime)
                        
                        if self.rowsPerSection[timeString] == nil {
                            self.rowsPerSection[timeString] = 1
                        } else if let rowsPerSection: Int = self.rowsPerSection[timeString] {
                            self.rowsPerSection[timeString] = rowsPerSection + 1
                        }
                    }
                    
                    if let endTime: NSDate = object["endTime"] as? NSDate {
                        info["endTime"] = endTime
                    }
                    
                    if let email: String = object["email"] as? String {
                        info["email"] = email
                    }
                    
                    if let companyWebsite: NSURL = NSURL(string: object["companyWebsite"] as String) {
                        info["companyWebsite"] = companyWebsite
                    }
                    
                    if let image: PFFile = object["image"] as? PFFile {
                        info["image"] = image
                    }
                    
                    if let companyID: NSNumber = object["companyID"] as? NSNumber {
                        info["companyID"] = companyID
                    }
                    
                    var event: Event = Event(info: info)
                    self.events.append(event)
                }
                
                self.events = self.events.sorted({
                    (firstEvent: Event, secondEvent: Event) -> Bool in
                    return firstEvent.startTime?.description < secondEvent.startTime?.description
                })
                
                self.sectionHeaders = []
                
                for key in self.rowsPerSection.keys {
                    self.sectionHeaders.append(key)
                }
                
                self.sectionHeaders = self.sectionHeaders.sorted({
                    (s1: String, s2: String) -> Bool in
                    let s1Array: [String] = s1.componentsSeparatedByString(" ")
                    let s2Array: [String] = s2.componentsSeparatedByString(" ")
                    
                    let s1Month: Int = self.monthToInt(s1Array[0])
                    let s2Month: Int = self.monthToInt(s2Array[0])
                    let s1Day: Int = s1Array[1].toInt()!
                    let s2Day: Int = s2Array[1].toInt()!
                    let s1Split: Int = s1Array[4] == "AM" ? 0 : 1
                    let s2Split: Int = s2Array[4] == "AM" ? 0 : 1
                    let s1Time: Int = s1Array[3].componentsSeparatedByString(":")[0].toInt()!
                    let s2Time: Int = s2Array[3].componentsSeparatedByString(":")[0].toInt()!
                    
                    if s1Month == s2Month {
                        if s1Day == s2Day {
                            if s1Split == s2Split {
                                if s1Time != 12 {
                                    return s1Time > s2Time
                                }
                                return s1Time < s2Time
                            }
                            return s1Split < s2Split
                        }
                        return s1Day < s2Day
                    }
                    return s1Month < s2Month
                })
                
                dispatch_async(dispatch_get_main_queue(), { () in
                    UIView.transitionWithView(self.tableView, duration: 0.1, options: UIViewAnimationOptions.ShowHideTransitionViews, animations: {
                        () -> Void in
                        
                        let delayTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.20 * Double(NSEC_PER_SEC)))
                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                            self.refreshControl.endRefreshing()
                        }
                        
                        self.tableView.reloadData()
                        }, completion: nil)
                })
            } else {
                // Log details of the failure
                println("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowsPerSection[self.sectionHeaders[section]]!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionHeaders.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let index: Int = calculateIndex(indexPath)
        let event: Event = self.events[index]
        var thumbnail: UIImage = UIImage(named: "mad_thumbnail.png")!
        
        if let companyID: String = event.companyID?.stringValue {
            if let mappedThumbnail: UIImage = self.thumbnails[companyID] {
                thumbnail = mappedThumbnail
            }
        }
        
        var eventViewController: EventViewController = EventViewController(image: thumbnail, event: event)
        
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return EVENTS_TABLEVIEW_CELL_HEIGHT
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeaders[section];
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        var sectionHeaderView: UITableViewHeaderFooterView = view as UITableViewHeaderFooterView
        
        sectionHeaderView.textLabel.font = UIFont.systemFontOfSize(FONT_SIZE)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: EventTableViewCell = tableView.dequeueReusableCellWithIdentifier(EVENTS_TABLEVIEW_CELL_IDENTIFIER, forIndexPath: indexPath) as EventTableViewCell
        
        let index: Int = calculateIndex(indexPath)
        let companyName: String? = self.events[index].companyName
        let sessionName: String? = self.events[index].sessionName
        let startTime: NSDate?   = self.events[index].startTime
        let endTime: NSDate?     = self.events[index].endTime
        let room: String?        = self.events[index].room
        let companyIDNumber: NSNumber? = self.events[index].companyID
        let companyIDString: String? = self.events[index].companyID?.stringValue
        
        let timeFormatter: NSDateFormatter  = NSDateFormatter()
        timeFormatter.timeZone              = NSTimeZone(name: "America/Chicago")
        timeFormatter.dateFormat            = "hh:mm a";
        var startTimeString: String         = "00:00"
        var endTimeString: String           = "00:00"
        
        if let time: NSDate = startTime {
            startTimeString = timeFormatter.stringFromDate(time)
        }
        
        if let time: NSDate = endTime {
            endTimeString = timeFormatter.stringFromDate(time)
        }
        
        cell.textLabel?.font = UIFont.systemFontOfSize(FONT_SIZE)
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(DETAIL_FONT_SIZE)
        
        cell.textLabel?.text        = companyName
        cell.detailTextLabel?.text  = sessionName
        cell.timeLabel?.text        = startTimeString + " - " + endTimeString
        cell.locationLabel?.text    = room
        cell.imageView?.image       = UIImage(named: "mad_thumbnail.png")?.imageScaledToSize(CGSizeMake(50, 50))
        
        if let companyIDString: String = companyIDString {
            if let thumbnail: UIImage = self.thumbnails[companyIDString] {
                cell.imageView?.image = thumbnail.imageScaledToSize(CGSizeMake(50, 50))
            }
        }
        
        var sponsorsQuery: PFQuery = PFQuery(className: "Sponsors")
        sponsorsQuery.whereKey("identifierNumber", equalTo: companyIDNumber)
        sponsorsQuery.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) in
            if error == nil {
                for object in objects {
                    if let companyIDNumber: NSNumber = object["identifierNumber"] as? NSNumber {
                        let companyIDString: String = companyIDNumber.stringValue
                        
                        if self.thumbnails[companyIDString] == nil || cell.imageView?.image != self.thumbnails[companyIDString] {
                            if let imageFile: PFFile = object["thumbnail"] as? PFFile {
                                imageFile.getDataInBackgroundWithBlock({
                                    (data: NSData!, error: NSError!) -> Void in
                                    if data != nil {
                                        self.thumbnails[companyIDString] = UIImage(data: data)
                                        cell.imageView?.image = self.thumbnails[companyIDString]?.imageScaledToSize(CGSizeMake(50.00, 50.00))
                                    } else {
                                        println(error.localizedDescription)
                                    }
                                })
                            }
                        }
                    }
                }
                
            } else {
                // Log details of the failure
                println("Error: %@ %@", error, error.userInfo!)
            }
        })
        return cell
    }
    
}