//
//  ArchiveView.swift
//  skydo
//
//  Created by Sebastian Jörz on 30.12.22.
//

import SwiftUI

struct ArchiveView: View {
    @StateObject var vm = TodoViewModel(listArchived: true)
    @State private var isLoading = true
    
    var body: some View {
        if isLoading{
            ProgressView()
        }else if vm.todos.isEmpty{
            Text("Nothing Archived")
        }
        List{
            ForEach(vm.todos){todo in
                TodoListItem(todo: todo, reloadCallback: { todo in
                    Task{
                        await vm.getTodos()
                    }
                })
            }
        }
        .task {
            await vm.getTodos()
            isLoading = false
        }.refreshable {
            await vm.getTodos()
        }
        .listStyle(PlainListStyle())
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView()
    }
}
