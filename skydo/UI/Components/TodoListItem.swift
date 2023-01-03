//
//  TodoListItem.swift
//  skydo
//
//  Created by Sebastian Jörz on 03.01.23.
//

import SwiftUI

struct TodoListItem: View {
  @Environment(\.managedObjectContext) private var viewContext
  @ObservedObject var todo: TodoItem
  var reloadCallback: (TodoItem) -> Void

  var body: some View {
    NavigationLink {
      EditTodoScreen(todo: todo)
      //            SingleTodoView(todo: todo)
    } label: {
      HStack {
        Image(systemName: todo.completed ? "checkmark.circle" : "circle")
          .foregroundColor(todo.completed ? .green : .red)
        Text("\(todo.title)")
        // Text Color
        // Prio - Circle Color from enum
        todo.priority.color != nil
          ? Circle()
            .fill(todo.priority.color!)
            .frame(width: 10, height: 10)
            .padding(.leading, 5) : nil
      }.swipeActions {
        Button(role: .destructive) {
          Task {
            todo.isActive.toggle()
            await APIService.toggleActiveTodo(id: todo.id, isActive: todo.isActive)

          }
        } label: {
          if todo.isActive {

            Label("Delete", systemImage: "trash")
          } else {
            Label("Restore", systemImage: "arrow.clockwise")
          }

        }
      }.swipeActions(edge: .leading) {
        Button {
          Task {
            todo.completed.toggle()
            await APIService.toggleTodoCompletion(id: todo.id, completed: todo.completed)

            reloadCallback(todo)
          }
        } label: {
          if todo.completed {
            Label("Reopen", systemImage: "envelope.open")
          } else {
            Label("Complete", systemImage: "envelope.badge")
          }
        }.foregroundColor(!todo.completed ? .red : .green)
      }
    }
  }
}

struct TodoListItem_Previews: PreviewProvider {
  static var previews: some View {
    TodoListItem(
      todo: MockTodoItem,
      reloadCallback: { todo in

      })
  }
}
