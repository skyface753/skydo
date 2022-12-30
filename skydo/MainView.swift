//
//  MainView.swift
//  skydo
//
//  Created by Sebastian Jörz on 28.12.22.
//

import SwiftUI

import Appwrite

let dbId = "63ada9616e452192e3e5"
let collId = "63ada9879e426f3b85f5"

let appwriteClient = Client()
    .setEndpoint("https://appwrite.skyface.de/v1")
    .setProject("63ad9f6f86df3acb7d0a")

struct ContentView: View {
    @StateObject var vm = TodoViewModel(listArchived: false)
    @State private var isLoggedIn = false
    @State private var showingCredits = false
    @State private var hasError = false
    @State private var errorMessage = ""
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
                    VStack(spacing: 20) {
                        isLoggedIn ? nil : Text("Not logged in")
                        if isLoading{
                            ProgressView()
                        }else if vm.todos.isEmpty{
                            Text("Nothing To Do")
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
                            .navigationTitle("Todos")
                            
                      
                            
                            NavigationLink(destination: ArchiveView()) {
                                Text("Archive")
                            }
                        
                    }
                    .toolbar{
                        
                                                /*Button("Archive") {
                                                    print("Help tapped!")
                                                }
                                            }*/
                        ToolbarItem(placement: .cancellationAction){
                            isLoggedIn ? Button("Logout"){
                                Task{
                                    do{
                                        try await APIService.logout()
                                        isLoggedIn = false
                                    }catch{
                                        hasError = true
                                        errorMessage = error.localizedDescription
                                    }
                                }
                            } : nil
                            isLoggedIn ? nil :
                            NavigationLink(destination: LoginView()) {
                                Text("Login")
                            }.onAppear{
                                print("On Appear Login")
                                Task{
                                    isLoggedIn = await checkLoginStatus()
                                }
                            }
                            
                        }
                        ToolbarItem(placement: .primaryAction){
                            NavigationLink(destination: CreateTodoView()) {
                                Label("Create", systemImage: "square.and.pencil")
                            }
                        }
                    }
        }.padding()
            .onAppear{
                print("On Appear")
                Task{
                    isLoggedIn = await checkLoginStatus()
                    
                }
            }
    }
}

func checkLoginStatus() async -> Bool {
    let account = Account(appwriteClient)
    do{
        try await  account.get()
        return true
    }catch{
        return false
    }
}

struct TodoListItem: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var todo: TodoItem
    var reloadCallback: (TodoItem) -> Void
    
    var body: some View {
        NavigationLink{
            SingleTodoView(todo: todo)
        } label: { HStack{
            Image(systemName: todo.completed ? "checkmark.circle": "circle")
                .foregroundColor(todo.completed ? .green : .red)
            Text("\(todo.title)")
        }.swipeActions{
            Button(role: .destructive) {
                Task{
                    todo.isActive.toggle()
                    await APIService.toggleActiveTodo(id: todo.id,isActive: todo.isActive)
                    
                }
            } label: {
                if todo.isActive {
                    
                    
                    Label("Delete", systemImage: "trash")
                }else{
                    Label("Restore", systemImage: "arrow.clockwise")
                }
                    
            }
        }.swipeActions(edge: .leading){
            Button {
                Task{
                    todo.completed.toggle()
                    await APIService.toggleTodoCompletion(id: todo.id, completed: todo.completed)
                    
                    reloadCallback(todo)
                } } label: {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().onAppear(){
            let account = Account(appwriteClient)
            Task{
                try await account.createEmailSession(email: "test@example.de", password: "User123!")
            }
        }
    }
}
