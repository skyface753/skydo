//
//  todoViewModel.swift
//  skydo
//
//  Created by Sebastian Jörz on 28.12.22.
//

import Foundation
import Appwrite

@MainActor
class TodoViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []
    @Published var errorMessage = ""
    @Published var hasError = false
    

    func getTodos() async {
        guard let data = try?  await  APIService().getTodos() else {
            self.todos = []
            self.hasError = true
            self.errorMessage  = "Server Error"
            return
        }
        
        self.todos = data
        
    }
}
