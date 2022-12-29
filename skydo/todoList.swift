//
//  todoList.swift
//  skydo
//
//  Created by Sebastian Jörz on 28.12.22.
//

import SwiftUI

struct TodoList: View {
    @StateObject var vm = TodoViewModel()
    
    var body: some View {
        List{
            ForEach(vm.todos){todo in
                HStack{
                    // Image(systemName: todo.completed ? "checkmark.circle": "circle")
                    Image(systemName: todo.completed! ? "checkmark.circle": "circle")
                        .foregroundColor(todo.completed ? .green : .red)
                    Text("\(todo.title)")
                }
            }
        }
        .task {
            await vm.getTodos()
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Todos")
        
    }
}
