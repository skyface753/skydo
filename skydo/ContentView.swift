//
//  ContentView.swift
//  skydo
//
//  Created by Sebastian Jörz on 28.12.22.
//

import SwiftUI

import Appwrite

let dbId = "63ada9616e452192e3e5"
let collId = "63ada9879e426f3b85f5"

let client = Client()
    .setEndpoint("https://appwrite.skyface.de/v1")
    .setProject("63ad9f6f86df3acb7d0a")
    .setSelfSigned(true) // For self signed certificates, only use for development

struct ContentView: View {
    
    var body: some View {
        NavigationView {
                    VStack(spacing: 20) {
                        TodoList()
                        NavigationLink(destination: CreateTodoView()) {
                            Text("New Todo")
                        }
                        NavigationLink(destination: LoginView()) {
                            Text("Login")
                        }
                    }
                    .navigationTitle("Navigation")
        }.padding()
            
       
        
    }
}

struct LoginView: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var hasError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View{
        VStack{
            TextField("E-Mail", text: $email)
            TextField("Password", text: $password)
            // Text hasError ? errorMessage : ""
            hasError ? Text(errorMessage) : Text("")

            Button("Login") {
                Task{
                    let account = Account(client)
                    
                    do {
                        let user = try await account.createEmailSession(email: email, password: password)
                        self.presentationMode.wrappedValue.dismiss()
                        print(String(describing: user.toMap()))
                    } catch {
                        hasError = true
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}


struct CreateTodoView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var errMessage: String = ""
    var body: some View {
        VStack{
            TextField(
                    "Title",
                    text: $title
                )
            TextField("Description", text: $description)
            Button("Create") {
                Task{
                   let success = await createDoc(title: title, desc: description)
                    if(success){
                        self.presentationMode.wrappedValue.dismiss()
                    }else{
                        errMessage = "Something went wrong"
                    }
                }
            }
            errMessage != "" ? Text(errMessage) : nil
        }
    }
}

func createDoc(title: String, desc: String) async -> Bool{
    let date = Date()
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    let dateString = formatter.string(from: date)
    
    let parameters: [String: Any] = ["title": title, "desc": desc, "completed": false, "remindTime": dateString]
    let database = Databases(client)
    do{
        let result = try await database.createDocument(databaseId: "63ada9616e452192e3e5", collectionId: "63ada9879e426f3b85f5", documentId: ID.unique() , data: parameters)
        
        print(result)
        return true
    }catch {
        print("ERROR \(error)")
        return false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func deleteTodo(id: String) async{
    let database = Databases(client)
    do{
        let result = try await database.deleteDocument(databaseId: "63ada9616e452192e3e5", collectionId: "63ada9879e426f3b85f5", documentId: id)
        print(result)
    }catch {
        print("ERROR \(error)")
    }
}

func toggleTodoCompletion(id: String, completed: Bool) async{
    let database = Databases(client)
    let parameters: [String: Any] = ["completed": completed]
    do{
        let result = try await database.updateDocument(databaseId: dbId, collectionId: collId, documentId: id, data: parameters )
        print(result)
    }catch {
        print("ERROR \(error)")
    }
}

struct TodoList: View {
    @StateObject var vm = TodoViewModel()
    @State private var showingCredits = false
    
    var body: some View {
        List{
            ForEach(vm.todos){todo in
                TodoListItem(todo: todo, callback: { todo in
                    Task{
                        await vm.getTodos()
                    }
                })
                /*HStack{
                    Image(systemName: todo.completed ? "checkmark.circle": "circle")
                        .foregroundColor(todo.completed ? .green : .red)
                    Text("\(todo.title)")
                }.swipeActions{
                    Button(role: .destructive) {
                        Task{

                            await deleteTodo(id: todo.id)
                            
                        }
                         } label: {
                                Label("Delete", systemImage: "trash")
                            }
                }.swipeActions(edge: .leading){
                    Button {
                        Task{
                            
                            await toggleTodoCompletion(id: todo.id, completed: !todo.completed)
                            // Update the list
                            await vm.getTodos()
                        } } label: {
                                if todo.completed {
                                    Label("Reopen", systemImage: "envelope.open")
                                } else {
                                    Label("Complete", systemImage: "envelope.badge")
                                }
                        }.foregroundColor(!todo.completed ? .red : .green)
                }.sheet(isPresented: $showingCredits, onDismiss: {
                    Task{
                        
                        
                        await vm.getTodos()
                    } }){
                       
                    TodoView(todo: todo)
                    
                }.onTapGesture {
                    showingCredits.toggle()
                }*/
                /*swipeActions{
                    Button("hi"){
                        print(todo.title)
                    }
                }*/
            }
        }
        .task {
            await vm.getTodos()
        }.refreshable {
            await vm.getTodos()
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Todos")
        
    }
}

struct TodoListItem: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var todo: TodoItem
    var callback: (TodoItem) -> Void
    
    var body: some View {
        NavigationLink{
            TodoView(todo: todo)
        } label: { HStack{
            Image(systemName: todo.completed ? "checkmark.circle": "circle")
                .foregroundColor(todo.completed ? .green : .red)
            Text("\(todo.title)")
        }.swipeActions{
            Button(role: .destructive) {
                Task{
                    
                    await deleteTodo(id: todo.id)
                    
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }.swipeActions(edge: .leading){
            Button {
                Task{
                    await toggleTodoCompletion(id: todo.id, completed: !todo.completed)
                    callback(todo)
                    //await vm.getTodos()
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


struct TodoView: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var remindTime: Date = Date()
    @State private var completed: Bool = false
    var todo: TodoItem

    var body: some View{
        VStack{
            TextField(
                    "Title",
                    text: $title
                )
            TextField("Description", text: $description)
            Toggle("Completed", isOn: $completed)
            DatePicker("Remind Time", selection: $remindTime)
            Button("Update") {
                Task{
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let dateString = formatter.string(from: remindTime)
                    
                    let parameters: [String: Any] = ["title": title, "desc": description, "completed": completed, "remindTime": dateString]
                    let database = Databases(client)
                    do{
                        let result = try await database.updateDocument(databaseId: dbId, collectionId: collId, documentId: todo.id, data: parameters )
                        
                        
                        
                    
                        print(result)
                        self.presentationMode.wrappedValue.dismiss()
                    }catch {
                        print("ERROR \(error)")
                    }
                }
            }
        }.onAppear{
            print("Appear" + todo.title)
            title = todo.title
            description = todo.desc
            remindTime = todo.remindTime
            completed = todo.completed
        }
    }
}

func postRequest(title: String, desc: String) {
  
  // declare the parameter as a dictionary that contains string as key and value combination. considering inputs are valid
  
  //let parameters: [String: Any] = ["id": 13, "name": "jack"]
    let parameters: [String: Any] = ["title": title, "desc": desc]
    
  // create the url with URL
  let url = URL(string: "http://localhost/todo/new")! // change server url accordingly
  
  // create the session object
  let session = URLSession.shared
  
  // now create the URLRequest object using the url object
  var request = URLRequest(url: url)
  request.httpMethod = "POST" //set http method as POST
  
  // add headers for the request
  request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
  request.addValue("application/json", forHTTPHeaderField: "Accept")
  
  do {
    // convert parameters to Data and assign dictionary to httpBody of request
    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
  } catch let error {
    print(error.localizedDescription)
    return
  }
  
  // create dataTask using the session object to send data to the server
  let task = session.dataTask(with: request) { data, response, error in
    
    if let error = error {
      print("Post Request Error: \(error.localizedDescription)")
      return
    }
    
    // ensure there is valid response code returned from this HTTP response
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode)
    else {
      print("Invalid Response received from the server")
      return
    }
    
    // ensure there is data returned
    guard let responseData = data else {
      print("nil Data received from the server")
      return
    }
    
    do {
      // create json object from data or use JSONDecoder to convert to Model stuct
      if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
        print(jsonResponse)
        // handle json response
      } else {
        print("data maybe corrupted or in wrong format")
        throw URLError(.badServerResponse)
      }
    } catch let error {
      print(error.localizedDescription)
    }
  }
  // perform the task
  task.resume()
}
