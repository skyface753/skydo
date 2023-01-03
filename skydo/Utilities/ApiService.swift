//
//  ApiService.swift
//  skydo
//
//  Created by Sebastian Jörz on 28.12.22.
//

import Appwrite
import Foundation

// MARK: - Constants

let dbId = "63ada9616e452192e3e5"
let collId = "63ada9879e426f3b85f5"
let universalLinkVerify = "https://skydo.skyface.de/verify"

let appwriteClient = Client()
  .setEndpoint("https://appwrite.skyface.de/v1")
  .setProject("63ad9f6f86df3acb7d0a")

let database = Databases(appwriteClient)
let account = Account(appwriteClient)

// MARK: - API

struct APIService {
  func getTodos(listArchived: Bool) async throws -> [TodoItem] {
    do {

      let documentList = try await database.listDocuments(
        databaseId: dbId,
        collectionId: collId,
        queries: [
          Query.equal("isActive", value: !listArchived)
        ]
      )

      var todos: [TodoItem] = []

      for document in documentList.documents {
        let decodedDocument = document.convertTo(fromJson: converter)
        todos.append(decodedDocument)
      }

      // Sort by $createdAt: Newest -> Latest
      todos = todos.sorted { a, b in
        return a.createdAt! > b.createdAt!
      }

      // Sort by Completed: Not completed -> Completed
      todos = todos.sorted(by: { a, b in
        return !a.completed
      })

      // Sort by remindTime: Latest -> Newest
      // todos = todos.sorted { a, b in
      //   if a.remindTime == nil || b.remindTime == nil {
      //     return !a.completed
      //   }
      //   return a.remindTime! > b.remindTime!
      // }

      // // Sort by Completed: Not completed -> Completed
      // todos = todos.sorted(by: { a, b in
      //   return !a.completed
      // })
      return todos
    } catch {
      throw error
    }
  }

  static func createTodo(todo: TodoItem, withRemTime: Bool) async throws -> Bool {

    let paramsMap: [String: Any?] = todo.toParamsMap(withRemindTime: withRemTime)

    /* var parameters: [String: Any] = ["title": title, "desc": desc, "completed": false]
    if remTime != nil {
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      let dateString = formatter.string(from: remTime!)
      parameters["remindTime"] = dateString
    }*/

    do {
      let result = try await database.createDocument(
        databaseId: dbId, collectionId: collId, documentId: ID.unique(), data: paramsMap)

      print(result)
      return true
    } catch {
      print("ERROR \(error)")
      throw error
    }
  }

  static func toggleActiveTodo(id: String, isActive: Bool) async {

    let parameters: [String: Any] = ["isActive": isActive]
    do {
      let result = try await database.updateDocument(
        databaseId: dbId, collectionId: collId, documentId: id, data: parameters)
      print(result)
    } catch {
      print("ERROR \(error)")
    }
  }

  static func toggleTodoCompletion(id: String, completed: Bool) async {

    let parameters: [String: Any] = ["completed": completed]
    do {
      let result = try await database.updateDocument(
        databaseId: dbId, collectionId: collId, documentId: id, data: parameters)
      print(result)
    } catch {
      print("ERROR \(error)")
    }
  }

  static func logout() async throws {

    do {
      _ = try await account.deleteSessions()
    } catch {
      throw error
    }
  }

  static func updateTodo(
    todo: TodoItem, withRemTime: Bool
  ) async throws {
    let paramsMap: [String: Any?] = todo.toParamsMap(withRemindTime: withRemTime)

    print("Update PARAMS")
    print(paramsMap)
    do {
      _ = try await database.updateDocument(
        databaseId: dbId, collectionId: collId, documentId: todo.id, data: paramsMap)

    } catch {
      throw error
    }
  }

  static func checkLoginStatus() async -> Bool {
    do {
      _ = try await account.get()
      return true
    } catch {
      return false
    }
  }

  static func createVerification() async throws {
    _ = try await account.createVerification(url: universalLinkVerify)
  }

  static func verifyConfirm(userId: String, secret: String) async throws {
    let account = Account(appwriteClient)
    _ = try await account.updateVerification(userId: userId, secret: secret)
  }
}

// MARK: - Helpers
func dateToString(date: Date) -> String {
  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
  let dateString = formatter.string(from: date)
  return dateString
}
