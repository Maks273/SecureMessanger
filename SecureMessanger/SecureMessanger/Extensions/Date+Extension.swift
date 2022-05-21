//
//  Date+Extension.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 19.05.2022.
//

import UIKit

enum DateFormats: String {
    case notificationDate = "dd/MM HH:mm"
    case MMMd = "MMM d"
    case MMMMdyyyy = "MMM d yyyy"
    case yyyyMMDD = "yyyy-MM-dd"
    case serverFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
    case timeZoneDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    case hhmm = "HH:mm"
    case ddMMYYYY = "dd/MM/yyyy"
    case yyyyMMddhhmmss = "yyyy-MM-dd'T'HH:mm:ss"
    case yyyyMMddhhmmssSlashed = "yyyy/MM/dd HH:mm"
    case hhmmss = "HH:mm:ss"
    case ddMMyyyyhhmmssSlashed = "dd/MM/yyyy HH:mm"
    case MMMddCommayyyy = "MMM dd,yyyy"
}

extension Int {
    func dateStringFromTimestamp(with format: DateFormats) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: date)
    }
    
    func dateFromTimestamp() -> Date {
       return Date(timeIntervalSince1970: TimeInterval(self))
    }
}
