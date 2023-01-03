//
//  TodoListView.swift
//  skydo
//
//  Created by Sebastian Jörz on 03.01.23.
//

import SwiftUI

struct TodoListComp: View {
    @State private var selectedTodos: [TodoItem]?
  @StateObject var vm: TodoViewModel
  @State private var searchText = ""
  // Callback after loading
  var callbackLoadingFinish: (() -> Void)?
  var body: some View {
    if vm.todos.isEmpty {
      Text("Nothing to do")
    }
      List {
      ForEach(searchResults) { todo in
        TodoListItem(
          todo: todo,
          reloadCallback: { todo in
            Task {
              await vm.getTodos()
            }
          })
      }
    }
    .task {
      await vm.getTodos()
      callbackLoadingFinish?()
    }.refreshable {
      await vm.getTodos()
    }
    .listStyle(PlainListStyle())

    .searchable(text: $searchText)
  }

  var searchResults: [TodoItem] {
    if searchText.isEmpty {
      return vm.todos
    } else {
      return vm.todos.filter({ todo in
        if todo.title.lowercased().contains(searchText.lowercased())
          || todo.desc.lowercased().contains(searchText.lowercased())
        {
          return true
        }
        return false
      })
    }
  }
}

#if DEBUG
  struct TodoListView_Previews: PreviewProvider {
    @StateObject static var vm = TodoViewModel(listArchived: false)

    static var previews: some View {
      TodoListComp(vm: vm)
    }

  }
#endif
