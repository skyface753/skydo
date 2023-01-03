//
//  MainView.swift
//  skydo
//
//  Created by Sebastian Jörz on 28.12.22.
//

import SwiftUI

import Appwrite



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
    
    
    
    var body: some View {
        NavigationView {
                    VStack(spacing: 20) {
                        isLoggedIn ? nil : Text("Not logged in")
                        if isLoading{
                            ProgressView()
                        }/*else if vm.todos.isEmpty{
                            Text("Nothing To Do")
                        }*/
                        TodoListComp(vm:vm, callbackLoadingFinish: {
                          isLoading = false
                      })
                            
                      
                            
                            NavigationLink(destination: ArchiveView()) {
                                Text("Archive")
                            }
                        
                    }.navigationTitle("Todos")
                    .toolbar{
                        
                                             
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
                            NavigationLink(destination: CreateTodoScreen()) {
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
        
       
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
