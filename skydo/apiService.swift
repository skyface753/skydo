//
//  apiService.swift
//  skydo
//
//  Created by Sebastian Jörz on 28.12.22.
//

import Foundation
import Appwrite

/*struct TodoItem: Identifiable, Codable {
    let id: String
    let title: String
    let desc: String
    let remindTime: Date
    // let completed: Bool 
    // Optional because of Appwrite
    let completed: Bool
}*/

class TodoItem: Identifiable, ObservableObject{
    let id: String
    let title: String
    let desc: String
    let remindTime: Date
    // let completed: Bool
    // Optional because of Appwrite
    let completed: Bool
    
    init(id: String, title: String, desc: String, remindTime: Date, completed: Bool) {
        self.id = id
        self.title = title
        self.desc = desc
        self.remindTime = remindTime
        self.completed = completed
    }
}

enum APIError: Error{
    case invalidUrl, requestError, decodingError, statusNotOk
}

let BASE_URL: String = "https://jsonplaceholder.typicode.com"

let convertStringToDate: (String) -> Date = { dateString in
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter.date(from: dateString)!
}

let converter : ([String:Any]) -> TodoItem = { dictionary in
    print(dictionary)
    return TodoItem(
        id: dictionary["$id"] as! String,
        title: dictionary["title"] as! String,
        desc: dictionary["desc"] as! String,
        remindTime: convertStringToDate(dictionary["remindTime"] as! String),
        completed: dictionary["completed"] as! Bool
    )
}

struct APIService {
    
    func getTodos() async throws -> [TodoItem] {
        let client = Client()
            .setEndpoint("https://appwrite.skyface.de/v1")
            .setProject("63ad9f6f86df3acb7d0a")
            .setSelfSigned(true) // For self signed certificates, only use for development
        let database = Databases(client)
        
        let documentList = try await database.listDocuments(
            databaseId: "63ada9616e452192e3e5",
            collectionId: "63ada9879e426f3b85f5"
        )

        var todos: [TodoItem] = []

        for document in documentList.documents {
            let decodedDocument = document.convertTo(fromJson: converter)
            todos.append(decodedDocument)
        }
        
        // Sort by remindTime: Latest -> Newest
       todos =  todos.sorted { a, b in
           return a.remindTime > b.remindTime
        }
        
        // Sort by Completed: Not completed -> Completed
        todos = todos.sorted(by: { a, b in
            return !a.completed
        })
        
        return todos
        
        /*guard let url = URL(string:  "\(BASE_URL)/todos") else{
            throw APIError.invalidUrl
        }
        
        guard let (data, response) = try? await URLSession.shared.data(from: url) else{
            throw APIError.requestError
        }
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            throw APIError.statusNotOk
        }
        
        guard let result = try? JSONDecoder().decode([TodoItem].self, from: data) else {
            throw APIError.decodingError
        }
        
        return result*/
    }
    
}
