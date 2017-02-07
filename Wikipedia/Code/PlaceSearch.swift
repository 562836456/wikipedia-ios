enum PlaceSearchType: UInt {
    case text
    case location
    case top
    case saved
}

extension MKCoordinateRegion {
    var stringValue: String {
        return String(format: "%.3f,%.3f|%.3f,%.3f", center.latitude, center.longitude, span.latitudeDelta, span.longitudeDelta)
    }
}

struct PlaceSearch {
    let type: PlaceSearchType
    let sortStyle: WMFLocationSearchSortStyle
    let string: String?
    let region: MKCoordinateRegion?
    let localizedDescription: String?
    let articleKey: String?
    var needsWikidataQuery: Bool = true
    
    init(type: PlaceSearchType, sortStyle: WMFLocationSearchSortStyle, string: String?, region: MKCoordinateRegion?, localizedDescription: String?, articleKey: String?) {
        self.type = type
        self.sortStyle = sortStyle
        self.string = string
        self.region = region
        self.localizedDescription = localizedDescription
        self.articleKey = articleKey
    }
    
    var key: String {
        get {
            let baseString = "\(type.rawValue)|\(sortStyle.rawValue)|\(string?.lowercased().precomposedStringWithCanonicalMapping ?? "")"
            switch type {
            case .location:
                guard let region = region else {
                    fallthrough
                }
                return baseString + "|\(region.stringValue )"
            default:
                return baseString
            }
        }
    }
    
    var dictionaryValue: [String: NSCoding] {
        get {
            var dictionary: [String: NSCoding] = [:]
            dictionary["type"] = NSNumber(value: type.rawValue)
            dictionary["sortStyle"] = NSNumber(value: sortStyle.rawValue)
            if let string = string {
                dictionary["string"] = string as NSString
            }
            if let region = region {
                dictionary["lat"] = NSNumber(value: region.center.latitude)
                dictionary["lon"] = NSNumber(value: region.center.longitude)
                dictionary["latd"] = NSNumber(value: region.span.latitudeDelta)
                dictionary["lond"] = NSNumber(value: region.span.longitudeDelta)
            }
            if let localizedDescription = localizedDescription {
                dictionary["localizedDescription"] = localizedDescription as NSString
            }
            if let articleKey = articleKey {
                dictionary["articleKey"] = articleKey as NSString
            }
            return dictionary
        }
    }
    
    init?(dictionary: [String: Any]) {
        guard let typeNumber = dictionary["type"] as? NSNumber,
            let type = PlaceSearchType(rawValue: typeNumber.uintValue),
            let sortStyleNumber = dictionary["sortStyle"] as? NSNumber else {
                return nil
        }
        self.type = type
        let sortStyle = WMFLocationSearchSortStyle(rawValue: sortStyleNumber.uintValue)
        self.sortStyle = sortStyle
        self.string = dictionary["string"] as? String
        if let lat = dictionary["lat"] as? NSNumber,
            let lon = dictionary["lon"] as? NSNumber,
            let latd = dictionary["latd"] as? NSNumber,
            let lond = dictionary["lond"] as? NSNumber {
            let coordinate = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
            let span = MKCoordinateSpan(latitudeDelta: latd.doubleValue, longitudeDelta: lond.doubleValue)
            self.region = MKCoordinateRegion(center: coordinate, span: span)
        } else {
            self.region = nil
        }
        self.articleKey = dictionary["articleKey"] as? String
        self.localizedDescription = dictionary["localizedDescription"] as? String
    }
}
