//
//  Models.swift
//  skydo
//
//  Created by Sebastian Jörz on 03.01.23.
//

import Foundation
import SwiftUI

// MARK: - Priority

enum TodoPriority: String, CaseIterable {
  case Without = "Without"
  case Low = "Low"
  case Normal = "Normal"
  case High = "High"

}

extension TodoPriority {
  var color: Color? {
    switch self {
    case .Without:
      return nil
    case .Low:
      return Color.green
    case .Normal:
      return Color.yellow
    case .High:
      return Color.red
    }
  }
}

// MARK: - TodoItem

class TodoItem: Identifiable, ObservableObject {
  let id: String
    let createdAt: Date?
  var title: String
  var desc: String
  var remindTime: Date?
  var completed: Bool
  var isActive: Bool
  var priority: TodoPriority
    

  init(
    id: String, createdAt: Date?, title: String, desc: String, remindTime: Date?, completed: Bool, isActive: Bool,
    priority: TodoPriority
  ) {
    self.id = id
      self.createdAt = createdAt
    self.title = title
    self.desc = desc
    self.remindTime = remindTime
    self.completed = completed
    self.isActive = isActive
    self.priority = priority
  }

  func toParamsMap(withRemindTime: Bool) -> [String: Any?] {
    let parameters: [String: Any?] = [
      "title": title, "desc": desc, "completed": completed,
      "remindTime": withRemindTime ? dateToString(date: remindTime!) : nil,
      "priority": priority != .Without ? priority.rawValue : nil,
    ]
    return parameters
  }
}

// MARK: - Helpers

func stringToPriority(prioStr: String) -> TodoPriority {
  switch prioStr {
  case "Without":
    return .Without
  case "Low":
    return .Low
  case "Normal":
    return .Normal
  case "High":
    return .High
  default:
    return .Without
  }
}

let converter: ([String: Any]) -> TodoItem = { dictionary in
  print(dictionary)
  return TodoItem(
    id: dictionary["$id"] as! String,
    createdAt: convertStringToDate(dictionary["$createdAt"] as! String),
    title: dictionary["title"] as! String,
    desc: dictionary["desc"] as! String,
    // remindTime:  convertStringToDate(dictionary["remindTime"] as? String),
    remindTime: dictionary["remindTime"] as? String != nil
      ? convertStringToDate(dictionary["remindTime"] as! String) : nil,
    completed: dictionary["completed"] as! Bool,
    isActive: dictionary["isActive"] as! Bool,
    priority: dictionary["priority"] as? String != nil
      ? stringToPriority(prioStr: dictionary["priority"] as! String) : .Without
  )
}

let convertStringToDate: (String) -> Date = { dateString in
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
  return dateFormatter.date(from: dateString)!
}
