//
//  ApiService.swift
//  skydo
//
//  Created by Sebastian Jörz on 28.12.22.
//

import Foundation
import Appwrite

class TodoItem: Identifiable, ObservableObject{
    let id: String
    let title: String
    let desc: String
    let remindTime: Date?
    var completed: Bool
    var isActive: Bool
    
    init(id: String, title: String, desc: String, remindTime: Date?, completed: Bool, isActive: Bool) {
        self.id = id
        self.title = title
        self.desc = desc
        self.remindTime = remindTime
        self.completed = completed
        self.isActive = isActive
    }
}

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
        // remindTime:  convertStringToDate(dictionary["remindTime"] as? String),
        remindTime: dictionary["remindTime"] as? String != nil ? convertStringToDate(dictionary["remindTime"] as! String) : nil,
        completed: dictionary["completed"] as! Bool,
        isActive: dictionary["isActive"] as! Bool
    )
}

struct APIService {
    func getTodos(listArchived: Bool) async throws -> [TodoItem] {
        do{
            let client = Client()
                .setEndpoint("https://appwrite.skyface.de/v1")
                .setProject("63ad9f6f86df3acb7d0a")
                .setSelfSigned(true) // For self signed certificates, only use for development
            let database = Databases(client)
            
            let documentList = try await database.listDocuments(
                databaseId: "63ada9616e452192e3e5",
                collectionId: "63ada9879e426f3b85f5",
                queries: [
                    Query.equal("isActive", value: !listArchived)
                ]
            )
            
            var todos: [TodoItem] = []
            
            for document in documentList.documents {
                let decodedDocument = document.convertTo(fromJson: converter)
                todos.append(decodedDocument)
            }
            
            // Sort by remindTime: Latest -> Newest
            todos =  todos.sorted { a, b in
                if(a.remindTime == nil || b.remindTime == nil){
                    return !a.completed
                }
                return a.remindTime! > b.remindTime!
            }
            
            // Sort by Completed: Not completed -> Completed
            todos = todos.sorted(by: { a, b in
                return !a.completed
            })
            return todos
        }catch{
            throw error
        }
    }
    
    
    static func createTodo(title: String, desc: String, remTime: Date?) async -> Bool{
        
        
        
        var parameters: [String: Any] = ["title": title, "desc": desc, "completed": false]
        if(remTime != nil){
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let dateString = formatter.string(from: remTime!)
            parameters["remindTime"] = dateString
        }
        let database = Databases(appwriteClient)
        do{
            let result = try await database.createDocument(databaseId: dbId, collectionId: collId, documentId: ID.unique() , data: parameters)
            
            print(result)
            return true
        }catch {
            print("ERROR \(error)")
            return false
        }
    }
    
    static func toggleActiveTodo(id: String, isActive: Bool) async{
        let database = Databases(appwriteClient)
        let parameters: [String: Any] = ["isActive": isActive]
        do{
            let result = try await database.updateDocument(databaseId: dbId, collectionId: collId, documentId: id, data: parameters )
            print(result)
        }catch {
            print("ERROR \(error)")
        }
    }
    

    static func toggleTodoCompletion(id: String, completed: Bool) async{
        let database = Databases(appwriteClient)
        let parameters: [String: Any] = ["completed": completed]
        do{
            let result = try await database.updateDocument(databaseId: dbId, collectionId: collId, documentId: id, data: parameters )
            print(result)
        }catch {
            print("ERROR \(error)")
        }
    }
    
    static func logout() async throws{
        let account = Account(appwriteClient)
        do{
            _ = try await account.deleteSessions()
        }catch{
            throw error
        }
    }
    
    static func dateToString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    static func updateTodo(id: String, title: String, description: String, completed: Bool, remTime: Date?) async throws{
        var parameters: [String: Any?] = ["title": title, "desc": description, "completed": completed, "remindTime": remTime != nil ? dateToString(date: remTime!) : nil]
        
        print("Update PARAMS")
        print(parameters)
        let database = Databases(appwriteClient)
        do{
            let result = try await database.updateDocument(databaseId: dbId, collectionId: collId, documentId: id, data: parameters )
            
        }catch {
            throw error
        }
    }
}
