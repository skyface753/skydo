//
//  SingleTodoView.swift
//  skydo
//
//  Created by Sebastian Jörz on 30.12.22.
//

import SwiftUI
import Appwrite

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

struct SingleTodoView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var remindTime: Date?
    @State private var showDate: Bool = false
    @State private var completed: Bool = false
    @State private var showingAlert = false
    var todo: TodoItem

    var body: some View{
        VStack{
            TextField(
                    "Title",
                    text: $title
                )
            TextField("Description", text: $description)
            Toggle("Completed", isOn: $completed)
            Toggle("Remind Date", isOn: $showDate)
            if showDate {
                DatePicker("Remind Time", selection: $remindTime.toUnwrapped(defaultValue: Date()))
            }
            Spacer()
            
            
        }.alert(isPresented: $showingAlert) {
            Alert(title: Text("Important message"), message: Text("Wear sunscreen"), dismissButton: .default(Text("Got it!")))
        }
        .onAppear{
            print("Appear" + todo.title)
            title = todo.title
            description = todo.desc
            if(todo.remindTime != nil){
                showDate = true
                remindTime = todo.remindTime!
            }
            completed = todo.completed
        }.toolbar{
            ToolbarItem(placement: .primaryAction){
                Button("Update") {
                    
                    Task{
                        do{
                            if(showDate){
                                print("With Date")
                                if(remindTime == nil){
                                    remindTime = Date()
                                }
                                print(APIService.dateToString(date: remindTime!))
                            }else{
                                print("Without Date")
                            }
                            
                            try await APIService.updateTodo(id: todo.id, title: title, description: description, completed: completed, remTime: showDate == true ? remindTime : nil)
                            presentationMode.wrappedValue.dismiss()
                        }catch{
                            
                        }
                    }
                }
            }
        }
    }
}

struct SingleTodoView_Previews: PreviewProvider {
    static var previews: some View {
        let todo: TodoItem =  TodoItem(id: "x1231", title: "Titel", desc: "Description", remindTime: Date(), completed: true, isActive: true)
        SingleTodoView(todo:todo)
    }
}
