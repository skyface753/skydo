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
    @Environment(\.scenePhase) private var scenePhase

    @StateObject var vm = TodoViewModel(listArchived: false)
    @State private var isLoggedIn = false
    @State private var showingCredits = false
    @State private var hasError = false
    @State private var errorMessage = ""
    @State private var isLoading = true
    
    @State private var showVerificationMessage = false
    @State private var verifySuccessed = false
    @State private var verificationMessage = ""
    
    @State private var searchText = ""
    
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
                                 
                                    
                                    /*ForEach(vm.todos){todo in
                                        TodoListItem(todo: todo, reloadCallback: { todo in
                                            Task{
                                                await vm.getTodos()
                                            }
                                        })
                                    }*/
                                ForEach(searchResults) {todo in TodoListItem(todo: todo, reloadCallback: { todo in
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
                            .searchable(text: $searchText)
                            
                      
                            
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
                                    isLoggedIn = await APIService.checkLoginStatus()
                                }
                            }
                            
                        }
                        ToolbarItem(placement: .primaryAction){
                            NavigationLink(destination: CreateTodoView()) {
                                Label("Create", systemImage: "square.and.pencil")
                            }
                        }
                    }
        }
            .onAppear{
                print("On Appear")
                Task{
                    isLoggedIn = await APIService.checkLoginStatus()
                    
                }
            }
            .onOpenURL { URL in
                // Process the URL
                print("Received URL: " + URL.absoluteString)
               
                
                let urlComponents = URLComponents(url: URL, resolvingAgainstBaseURL: false)
                let queryItems = urlComponents?.queryItems
                let userId = queryItems?.first(where: { $0.name == "userId" })?.value
                let secret = queryItems?.first(where: { $0.name == "secret" })?.value
                
                if(userId == nil || secret == nil){
                    verificationMessage = "Please check the Link"
                    showVerificationMessage = true
                    return
                }
                
                Task{
                    do{
                        try await APIService.verifyConfirm(userId: userId!, secret: secret!)
                        verificationMessage = "Verify success"
                        verifySuccessed = true
                        showVerificationMessage = true
                    }catch{
                        verificationMessage = error.localizedDescription
                        showVerificationMessage = true
                    }
                    
                }
            }.alert(verificationMessage, isPresented: $showVerificationMessage){
                Button("Ok", role: .cancel){
                    
                }
                if !verifySuccessed{
                    
                    
                    Button("Resend", role: .destructive){
                        Task{
                            do{
                                try await APIService.createVerification()
                            }catch{
                                verificationMessage = error.localizedDescription
                                verifySuccessed = false
                                showVerificationMessage = true
                            }
                        }
                    }}
            }
    }
        var searchResults: [TodoItem] {
            if(searchText.isEmpty){
                return vm.todos
            }else{
                return vm.todos.filter({ todo in
                    if(todo.title.lowercased().contains(searchText.lowercased()) || todo.desc.lowercased().contains(searchText.lowercased())){
                        return true
                    }
                    return false
                })
            }
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
