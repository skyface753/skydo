//
//  createTodo.swift
//  skydo
//
//  Created by Sebastian Jörz on 30.12.22.
//

import Appwrite
import SwiftUI


struct CreateTodoView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var remindTime: Date = Date()
    @State private var errMessage: String = ""

    var body: some View {
        VStack{
            TextField(
                    "Title",
                    text: $title
            ).padding()
                .cornerRadius(20)
            TextField("Description", text: $description).padding()
                .cornerRadius(20)
            DatePicker("Remind Time", selection: $remindTime)
            Button("Create") {
                Task{
                    let success = await APIService.createTodo(title: title, desc: description, remTime: remindTime)
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


struct CreateTodoView_Previews: PreviewProvider {
    static var previews: some View {
        CreateTodoView()
    }
}
