//
//  EditTodoScreen.swift
//  skydo
//
//  Created by Sebastian Jörz on 03.01.23.
//

import SwiftUI

struct EditTodoScreen: View {
  var todo: TodoItem

  var body: some View {
    TodoDetailView(
      callbackAfterSave: { todo, showDate in
        
          do {
            if showDate {
              print("With Date")
              if todo.remindTime == nil {
                todo.remindTime = Date()
              }
              print(dateToString(date: todo.remindTime!))
            } else {
              print("Without Date")
            }

            /*try await APIService.updateTodo(
              id: todo.id, title: todo.title, description: todo.desc, completed: todo.completed,
              remTime: showDate == true ? todo.remindTime : nil, prio: todo.priority)*/
              try await APIService.updateTodo(todo: todo, withRemTime: showDate)
          } catch {
            print(error.localizedDescription)
              throw error
          }
        
      },
      todo: todo)

  }
}

/*struct EditTodoScreen_Previews: PreviewProvider {
  static var previews: some View {
    EditTodoScreen()
  }
}*/
