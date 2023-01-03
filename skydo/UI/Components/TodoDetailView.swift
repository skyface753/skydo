//
//  TodoDetailView.swift
//  skydo
//
//  Created by Sebastian Jörz on 03.01.23.
//

import SwiftUI

struct EnumPicker<T: Hashable & CaseIterable, V: View>: View {

  @Binding var selected: T
  var title: String? = nil

  let mapping: (T) -> V

  var body: some View {
    Picker(selection: $selected, label: Text(title ?? "")) {
      ForEach(Array(T.allCases), id: \.self) {
        mapping($0).tag($0)
      }
    }
  }
}

extension EnumPicker where T: RawRepresentable, T.RawValue == String, V == Text {
  init(selected: Binding<T>, title: String? = nil) {
    self.init(selected: selected, title: title) {
      Text($0.rawValue)
    }
  }
}

struct TodoDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var callbackAfterSave: ((TodoItem, Bool) async throws -> Void)?
 
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showDate: Bool = false
    @State private var prio: TodoPriority = .Without
    @State var todo: TodoItem

 

  var body: some View {

    Form {

      TextField(
        "Title",
        text: $todo.title
      )
      TextField("Description", text: $todo.desc)
      Toggle("Completed", isOn: $todo.completed)
      Toggle("Remind Date", isOn: $showDate)
      if showDate {
        DatePicker("Remind Time", selection: $todo.remindTime.toUnwrapped(defaultValue: Date()))
      }
      //Spacer().frame(height: 20)
      Picker("Priority", selection: $prio) {
        ForEach(TodoPriority.allCases, id: \.self) { value in
          Text(value.rawValue)
            .tag(value)
        }
      }
     

    }
    .alert(isPresented: $showingAlert) {
      Alert(
        title: Text("Important message"), message: Text("Wear sunscreen"),
        dismissButton: .default(Text("Got it!")))
    }
    .onAppear {
      prio = todo.priority
      if todo.remindTime != nil {
        showDate = true
      }
    }.toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button("Save") {
          Task {
            do {
              todo.priority = prio // Update the Todo - PRIO
              try await callbackAfterSave?(todo, showDate)
              presentationMode.wrappedValue.dismiss()
            } catch {
              alertMessage = error.localizedDescription
              showingAlert = true
            }
          }
        }
      }
    }
  }
}

struct TodoDetailView_Previews: PreviewProvider {
  static var previews: some View {
    TodoDetailView(
      todo: MockTodoItem)
  }
}

// MARK: - Helper
extension Binding {
  func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == T? {
    Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
  }
}
