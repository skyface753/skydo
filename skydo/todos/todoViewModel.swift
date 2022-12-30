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
    
    var listArchived: Bool
    
    init(listArchived: Bool) {
        self.listArchived = listArchived
    }
    
    func getTodos() async {
        guard let data = try?  await  APIService().getTodos(listArchived: self.listArchived) else {
            self.todos = []
            self.hasError = true
            self.errorMessage  = "Server Error"
            return
        }
        self.todos = data
        
    }
}

