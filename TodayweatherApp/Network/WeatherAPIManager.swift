//
//  WeatherAPIManager.swift
//  TodayweatherApp
//
//  Created by Seokjune Hong on 2023/02/04.
//

import Foundation

final class WeatherAPIManager: NSObject {
    static let shared = WeatherAPIManager()
    
    var tagType: TagType = .none
    var isLock = true
    var tempModel: Item?
    var weathers: [Item] = []
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd HHmm"
        return f
    }()
    
    private override init() { }
    
    func requestSomething(date: Date) {
        let dateArray = dateFormatter.string(from: date).split(separator: " ")
        let url = EndPoint.veryShortLiveCheckingURL + "getUltraSrtNcst" + "?serviceKey=\(APIKey.encodingKey)&numOfRows=10&pageNo=1&base_date=\(dateArray[0])&base_time=\(dateArray[1])&nx=61&ny=128"
        
        DispatchQueue.global().async {
            let xmlParser = XMLParser(contentsOf: URL(string: url)!)
            xmlParser!.delegate = self
            xmlParser!.parse()
            
            completionHandler("\(self.weathers)")
        }
    }
}

extension WeatherAPIManager: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        if elementName == "item" {
            isLock = true
            tempModel = Item.init()
        } else if elementName == "numberOfRows" {
            tagType = .numberOfRows
        } else if elementName == "pageNo" {
            tagType = .pageNo
        } else if elementName == "totalCount" {
            tagType = .totalCount
        } else if elementName == "resultCode" {
            tagType = .resultCode
        } else if elementName == "resultMsg" {
            tagType = .resultMsg
        } else if elementName == "dataType" {
            tagType = .dataType
        } else if elementName == "baseDate" {
            tagType = .baseDate
        } else if elementName == "baseTime" {
            tagType = .baseTime
        } else if elementName == "nx" {
            tagType = .nx
        } else if elementName == "ny" {
            tagType = .ny
        } else if elementName == "category" {
            tagType = .category
        } else if elementName == "obsrValue" {
            tagType = .obsrValue
        } else {
            tagType = .none
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            guard let tempModel = tempModel else { return }
            
            weathers.append(tempModel)
            isLock = false
            print(tempModel)
            print("⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯ did end ⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯")
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let parseString = string.trimmingCharacters(in: .whitespacesAndNewlines)

        if isLock {
            switch tagType {
            case .numberOfRows:
                tempModel?.numberOfRows = parseString
            case .pageNo:
                tempModel?.pageNo = parseString
            case .totalCount:
                tempModel?.totalCount = parseString
            case .resultCode:
                tempModel?.resultCode = parseString
            case .resultMsg:
                tempModel?.resultMsg = parseString
            case .dataType:
                tempModel?.dataType = parseString
            case .baseDate:
                tempModel?.baseDate = parseString
            case .baseTime:
                tempModel?.baseTime = parseString
            case .nx:
                tempModel?.nx = parseString
            case .ny:
                tempModel?.ny = parseString
            case .category:
                tempModel?.category = parseString
            case .obsrValue:
                tempModel?.obsrValue = parseString
            case .none:
                break
            }
        }
    }
}

enum TagType {
    case numberOfRows
    case pageNo
    case totalCount
    case resultCode
    case resultMsg
    case dataType
    case baseDate
    case baseTime
    case nx
    case ny
    case category
    case obsrValue
    case none
}

struct Item {
    var numberOfRows: String
    var pageNo: String
    var totalCount: String
    var resultCode: String
    var resultMsg: String
    var dataType: String
    var baseDate: String
    var baseTime: String
    var nx: String
    var ny: String
    var category: String
    var obsrValue: String
    
    init() {
        self.numberOfRows = ""
        self.pageNo = ""
        self.totalCount = ""
        self.resultCode = ""
        self.resultMsg = ""
        self.dataType = ""
        self.baseDate = ""
        self.baseTime = ""
        self.nx = ""
        self.ny = ""
        self.category = ""
        self.obsrValue = ""
    }
}

/*
 http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst ?serviceKey=인증키&numOfRows=10&pageNo=1 &base_date=20210628&base_time=0600&nx=55&ny=127
 
 */
