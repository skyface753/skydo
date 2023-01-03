//
//  ArchiveView.swift
//  skydo
//
//  Created by Sebastian Jörz on 30.12.22.
//

import SwiftUI

/*struct ArchiveView: View {
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
}*/

struct ArchiveView: View {
  @StateObject var vm = TodoViewModel(listArchived: true)
  @State private var showRestoreAllAlert = false
  var body: some View {
    VStack {

      Button("Restore all") {
        showRestoreAllAlert = true
      }
      TodoListComp(vm: vm).navigationTitle("Archiv")
    }.alert(isPresented: $showRestoreAllAlert) {
      Alert(
        title: Text("Restore all"), message: Text("Are you sure you want to restore all todos?"),
        primaryButton: .destructive(Text("Restore all")) {
          Task {
            await vm.restoreAllFromArchive()
            await vm.getTodos()
          }
        }, secondaryButton: .cancel())
    }
  }
}

struct ArchiveView_Previews: PreviewProvider {
  static var previews: some View {
    ArchiveView()
  }
}
