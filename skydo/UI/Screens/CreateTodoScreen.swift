//
//  CreateTodoScreen.swift
//  skydo
//
//  Created by Sebastian Jörz on 03.01.23.
//

import SwiftUI
import Appwrite



struct CreateTodoScreen: View {
    var todo: TodoItem = TodoItem(id: ID.unique(), createdAt: nil, title: "", desc: "", remindTime: nil, completed: false, isActive: true, priority: .Without)
    var body: some View {
        TodoDetailView(
            callbackAfterSave:  { todo, showDate in
                do{
                    
                    
                    let success = try await APIService.createTodo(todo: todo, withRemTime: showDate)
                    if(!success){
                       throw "Something went wrong"
                    }
                }catch{
                        throw error
                    }
                  }, todo: todo)
    }
    
}


extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
