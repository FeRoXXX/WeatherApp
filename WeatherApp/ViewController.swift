//
//  ViewController.swift
//  WeatherApp
//
//  Created by Александр Федоткин on 05.11.2023.
//

import UIKit
import SDWebImage
import CoreData
import SystemConfiguration

class ViewController: UIViewController{

    @IBOutlet private weak var locationLable: UILabel!
    @IBOutlet private weak var temperatureLable: UILabel!
    @IBOutlet private weak var typeWeatherLable: UILabel!
    @IBOutlet private weak var maxAndMinTemperature: UILabel!
    @IBOutlet private weak var mainTableView: UITableView!
    @IBOutlet private weak var collectionTempPerHourView: UICollectionView!
    @IBOutlet private weak var saveImage: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bgGif: UIImageView!

    private var timeArray = [String]()
    private var imagePerTimeArray = [String]()
    private var temperatrePerHourArray = [Int]()
    private var dayArray = [String]()
    private var imagePerDayArray = [String]()
    private var maxTempPerDay = [Int]()
    private var minTempPerDay = [Int]()
    private var minTempCurrentDay : Int = 0
    private var maxTempCurrentDay : Int = 0
    private var flag : Int = 0
    private var flagConnection : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bgGif.loadGif(name: "rain")

    }
    override func viewWillAppear(_ animated: Bool) {
        setup()
        customTableView()
        customCollectionView()
        checkInternet()
        if !flagConnection{
            self.loadData()
        }
    }
}

// MARK: - Init project
private extension ViewController {
    
    func setup() {
        mainTableView.delegate = self
        mainTableView.dataSource = self
        collectionTempPerHourView.delegate = self
        collectionTempPerHourView.dataSource = self
    }
}

// MARK: - TableViewDelegate + TableViewDataSource
extension ViewController : UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "weatherPerDay", for: indexPath) as! typeOfWeatherCell
        if !maxTempPerDay.isEmpty{
            cell.maxTemp.text = "\(maxTempPerDay[indexPath.row])°"
            cell.minTemp.text = "\(minTempPerDay[indexPath.row])°"
            if flagConnection{
                cell.weatherImage.sd_setImage(with: URL(string: "https:\(imagePerDayArray[indexPath.row])"))
            }
            cell.dayLable.text = dayArray[indexPath.row]
            cell.backgroundColor = .clear
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView()
        var headerStyle = header.defaultContentConfiguration()
        headerStyle.textProperties.color = .white
        headerStyle.text = "Прогноз на 7 дней"
        header.contentConfiguration = headerStyle
        return header
    }
}

// MARK: - collectionViewDelegate
extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellCollectionView = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionPrototype", for: indexPath) as! collectionViewCell
        if !timeArray.isEmpty{
            cellCollectionView.timeLable.text = timeArray[indexPath.row]
            cellCollectionView.tempLable.text = "\(temperatrePerHourArray[indexPath.row])°"
            if flagConnection{
                deleteData()
                saveData()
                cellCollectionView.imageView.sd_setImage(with: URL(string: "https:\(imagePerTimeArray[indexPath.row])"))
            }
            cellCollectionView.backgroundColor = .clear
        }
        return cellCollectionView
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeArray.count
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: 100, height: 10)
//    }
}

// MARK: -customizing tableView + collectionView
private extension ViewController {
  
    func customTableView() {
        mainTableView.backgroundColor = .clear
    }

    func customCollectionView() {
        collectionTempPerHourView.backgroundColor = .clear
//        collectionTempPerHourView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier)
    }
}

// MARK: - AlertMessage Function
private extension ViewController {
    
    func makeAlert(titleText: String, messageText: String){
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}

// MARK: - save to CoreData
private extension ViewController {
 
    func saveData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newDate = NSEntityDescription.insertNewObject(forEntityName: "CashView", into: context)
        let appDelegateDay = UIApplication.shared.delegate as! AppDelegate
        let contextDay = appDelegateDay.persistentContainer.viewContext
        let appDelegateHour = UIApplication.shared.delegate as! AppDelegate
        let contextHour = appDelegateHour.persistentContainer.viewContext
        
        firstSaving(newDate: newDate, context: context)
        saveDayOfWeek(contextDay: contextDay)
        saveHoursForDay(contextHour: contextHour)
    }
    
    func firstSaving(newDate: NSManagedObject, context : NSManagedObjectContext) {
        newDate.setValue(locationLable.text, forKey: "place")
        newDate.setValue(temperatureLable.text, forKey: "temp")
        newDate.setValue(typeWeatherLable.text, forKey: "type")
        newDate.setValue(String(minTempCurrentDay), forKey: "minTemp")
        newDate.setValue(String(maxTempCurrentDay), forKey: "maxTemp")
        
        do{
            try context.save()
        } catch{
            print("error")
        }
    }
    
    func saveDayOfWeek(contextDay : NSManagedObjectContext) {
        for index in 0...6{
            let newDateDay = NSEntityDescription.insertNewObject(forEntityName: "CashTable", into: contextDay)
            newDateDay.setValue(Int(maxTempPerDay[index]), forKey: "maxTempPerDay")
            newDateDay.setValue(Int(minTempPerDay[index]), forKey: "minTempPerDay")
            newDateDay.setValue(dayArray[index], forKey: "dayArray")
            do{
                try contextDay.save()
            } catch{
                print("error")
            }
        }
    }
    
    func saveHoursForDay(contextHour : NSManagedObjectContext) {
        for index in 0...23{
            let newHour = NSEntityDescription.insertNewObject(forEntityName: "CashCollection", into: contextHour)
            newHour.setValue(String(temperatrePerHourArray[index]), forKey: "temperaturePerHourArray")
            newHour.setValue(timeArray[index], forKey: "timeArray")
            do{
                try contextHour.save()
            } catch{
                print("error")
            }
        }
    }
}

// MARK: - get + convert Dates
private extension ViewController {

    func convertStringintoDate(dateStr: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.init(identifier: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let startDate = dateFormatter.date(from: dateStr){
            return startDate as Date
        }
        return Date() as Date
    }

    func getDate() -> String{
        let currentTimeAndDay = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "rw_RW")
        formatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH")
        return "\(formatter.string(from: currentTimeAndDay)):00"
    }
}

//MARK: - get + write data
extension ViewController{

    func getApi(){
        let url = URL(string: "http://api.weatherapi.com/v1/forecast.json?key=93cf608577b04951b7b130650230611&q=54.932332441300055,82.89899110794069&days=7&lang=ru")
        let session = URLSession.shared
        parseData(gettingUrl: url, currentSession: session)
    }

    func parseData(gettingUrl: URL?, currentSession: URLSession){
        let task = currentSession.dataTask(with: gettingUrl!) { data, response, error in
            if error != nil{
                self.makeAlert(titleText: "Error", messageText: error?.localizedDescription as? String ?? "Error")
            } else{
                if data != nil{
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, Any>
                        DispatchQueue.main.async{
                            if let location = jsonResponse["location"] as? [String : Any]{
                                if let place = location["name"] as? String{
                                    self.locationLable.text = place
                                }
                            }
                            if let currentWeather = jsonResponse["current"] as? [String : Any]{
                                if let temp = currentWeather["temp_c"] as? Int{
                                    self.temperatureLable.text = "\(String(temp))°"
                                }
                                if let condition = currentWeather["condition"] as? [String : Any]{
                                    if let type = condition["text"] as? String{
                                        self.typeWeatherLable.text = type
                                    }
                                }
                            }
                            if let forecast = jsonResponse["forecast"] as? [String : Any]{
                                if let forecastDay = forecast["forecastday"] as? [Any]{
                                    if let dict = forecastDay.first as? [String : Any]{
                                        if let day = dict["day"] as? [String : Any]{
                                            if let maxTemp = day["maxtemp_c"] as? Double{
                                                if let minTemp = day["mintemp_c"] as? Double{
                                                    self.maxAndMinTemperature.text = "Макс.:\(Int(maxTemp))°,Мин.:\(Int(minTemp))°"
                                                    self.maxTempCurrentDay = Int(maxTemp)
                                                    self.minTempCurrentDay = Int(minTemp)
                                                }
                                            }
                                        }
                                        for indexDate in forecastDay{
                                            if let dict = indexDate as? [String : Any]{
                                                if let day = dict["day"] as? [String : Any]{
                                                    if let maxTemp = day["maxtemp_c"] as? Double{
                                                        self.maxTempPerDay.append(Int(maxTemp))
                                                    }
                                                    if let minTemp = day["mintemp_c"] as? Double{
                                                        self.minTempPerDay.append(Int(minTemp))
                                                    }
                                                    if let condition = day["condition"] as? [String : Any]{
                                                        if let image = condition["icon"] as? String{
                                                            self.imagePerDayArray.append(image)
                                                            self.saveImage.sd_setImage(with: URL(string: "https:\(image)"))
                                                        }
                                                    }
                                                }
                                                if let date = dict["date"] as? String{
                                                    let chooseDate = self.convertStringintoDate(dateStr: date)
                                                    let formatter = DateFormatter()
                                                    formatter.setLocalizedDateFormatFromTemplate("EE")
                                                    formatter.locale = Locale(identifier: "ru_RU")
                                                    let currentDate = Date()
                                                    if formatter.string(from: currentDate) == formatter.string(from: chooseDate){
                                                        self.dayArray.append("Сегодня")
                                                    } else{
                                                        self.dayArray.append(formatter.string(from: chooseDate))
                                                    }
                                                }
                                            }
                                            if let hour = dict["hour"] as? [Any]{
                                                for indexHour in hour{
                                                    if let hourDict = indexHour as? [String : Any]{
                                                        if let time = hourDict["time"] as? String{
                                                            let currentTime = self.getDate()
                                                            if self.flag > 0 || time >= currentTime && self.flag != 24{
                                                                self.flag += 1
                                                                if let temp = hourDict["temp_c"] as? Double{
                                                                    self.temperatrePerHourArray.append(Int(temp))
                                                                }
                                                                if let condition = hourDict["condition"] as? [String : Any]{
                                                                    if let image = condition["icon"] as? String{
                                                                        self.imagePerTimeArray.append(image)
                                                                        self.saveImage.sd_setImage(with: URL(string: "https:\(image)"))
                                                                    }
                                                                }
                                                                let dateFormatter = DateFormatter()
                                                                dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
                                                                dateFormatter.timeZone = TimeZone.init(identifier: "GMT")
                                                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                                let formattedDate = dateFormatter.date(from: time)!
                                                                dateFormatter.setLocalizedDateFormatFromTemplate("HH")
                                                                self.timeArray.append(dateFormatter.string(from: formattedDate))
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        self.collectionTempPerHourView.reloadData()
                                        self.mainTableView.reloadData()
                                    }
                                }
                            }
                        }
                    } catch{
                        self.makeAlert(titleText: "Error!", messageText: "Data is empty!")
                    }
                }
            }
        }
        task.resume()
    }
}

//MARK: - Check internet connection

private extension ViewController{

    func checkInternet(){
        if Reachability.isConnectedToNetwork(){
            self.getApi()
            self.flagConnection = true
        } else{
            self.flagConnection = false
        }
    }
}

//MARK: - Delete file in CoreData

private extension ViewController{

    func deleteData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let appDelegateDay = UIApplication.shared.delegate as! AppDelegate
        let contextDay = appDelegateDay.persistentContainer.viewContext
        let appDelegateHour = UIApplication.shared.delegate as! AppDelegate
        let contextHour = appDelegateHour.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CashView")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do{
            try context.execute(deleteRequest)
        } catch{
            print("error")
        }
        
        let fetchRequestD = NSFetchRequest<NSFetchRequestResult>(entityName: "CashTable")
        let deleteRequestD = NSBatchDeleteRequest(fetchRequest: fetchRequestD)
        
        do{
            try contextDay.execute(deleteRequestD)
        } catch{
            print("error")
        }
        
        let fetchRequestH = NSFetchRequest<NSFetchRequestResult>(entityName: "CashCollection")
        let deleteRequestH = NSBatchDeleteRequest(fetchRequest: fetchRequestH)
        
        do{
            try contextHour.execute(deleteRequestH)
        } catch{
            print("error")
        }
    }
}

//MARK: - Load cash data

extension ViewController{

    func loadData(){
        timeArray.removeAll()
        imagePerTimeArray.removeAll()
        temperatrePerHourArray.removeAll()
        dayArray.removeAll()
        imagePerDayArray.removeAll()
        maxTempPerDay.removeAll()
        minTempPerDay.removeAll()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CashView")
        fetchRequest.returnsObjectsAsFaults = false
        
        let appDelegateTable = UIApplication.shared.delegate as! AppDelegate
        let contextTable = appDelegateTable.persistentContainer.viewContext
        
        let fetchRequestTable = NSFetchRequest<NSFetchRequestResult>(entityName: "CashTable")
        fetchRequestTable.returnsObjectsAsFaults = false
        
        let appDelegateCollection = UIApplication.shared.delegate as! AppDelegate
        let contextCollection = appDelegateCollection.persistentContainer.viewContext
        
        let fetchRequestCollection = NSFetchRequest<NSFetchRequestResult>(entityName: "CashCollection")
        fetchRequestCollection.returnsObjectsAsFaults = false
        
        cashView(fetchRequest: fetchRequest, context: context)
        cashTable(fetchRequest: fetchRequestTable, context: contextTable)
        cashCollection(fetchRequest: fetchRequestCollection, context: contextCollection)
    }

    func cashView(fetchRequest: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext){
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "place") as? String{
                        self.locationLable.text = name
                    }
                    if let temp = result.value(forKey: "temp") as? String{
                        self.temperatureLable.text = temp
                    }
                    if let type = result.value(forKey: "type") as? String{
                        self.typeWeatherLable.text = type
                    }
                    if let minTemp = result.value(forKey: "minTemp") as? String{
                        if let maxTemp = result.value(forKey: "maxTemp") as? String{
                            self.maxAndMinTemperature.text = "Макс.:\(maxTemp)°,Мин.:\(minTemp)°"
                        }
                    }
                }
            }
        }catch{
            print("error")
        }
    }

    func cashTable(fetchRequest: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext){
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let day = result.value(forKey: "dayArray") as? String{
                        self.dayArray.append(day)
                    }
                    if let maxTemp = result.value(forKey: "maxTempPerDay") as? Int{
                        self.maxTempPerDay.append(maxTemp)
                    }
                    if let minTemp = result.value(forKey: "minTempPerDay") as? Int{
                        self.minTempPerDay.append(minTemp)
                    }
                }
            }
        } catch{
            print("error")
        }
        mainTableView.reloadData()
    }

    func cashCollection(fetchRequest: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext){
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let hour = result.value(forKey: "timeArray") as? String{
                        self.timeArray.append(hour)
                    }
                    if let temp = result.value(forKey: "temperaturePerHourArray") as? String{
                        self.temperatrePerHourArray.append(Int(temp)!)
                    }
                }
            }
        } catch{
            print("error save")
        }
        collectionTempPerHourView.reloadData()
    }
}

//MARK: - test internet connection
public class Reachability {

    class func isConnectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret

    }
}
