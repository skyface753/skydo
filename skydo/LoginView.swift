//
//  LoginView.swift
//  skydo
//
//  Created by Sebastian Jörz on 30.12.22.
//

import SwiftUI
import Appwrite

struct LoginView: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // MARK: - Propertiers
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var hasError: Bool = false
    @State private var errorMessage: String = ""
    
    // MARK: - View
    var body: some View{
        VStack(alignment: .leading, spacing: 15){
            
            Text("SkyDo")
                .font(.largeTitle).foregroundColor(Color.green)
                .padding([.top, .bottom], 30)
            Image("Logo")
                .resizable()
                .frame( height: 250)
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
                .padding(.bottom, 50)
            TextField("E-Mail", text: $email).padding()
            //.background(themeTextField)
                .cornerRadius(20.0)
            SecureField("Password", text: $password).padding()
            //.background(themeTextField)
                .cornerRadius(20.0)
            hasError ? Text(errorMessage) : Text("")
            
            Button("Login") {
                
                Task{
                    let account = Account(appwriteClient)
                    
                    do {
                        let user = try await account.createEmailSession(email: email, password: password)
                        self.presentationMode.wrappedValue.dismiss()
                        print(String(describing: user.toMap()))
                    } catch {
                        hasError = true
                        errorMessage = error.localizedDescription
                    }
                }
            }.font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 300, height: 50)
                .background(Color.green)
                .cornerRadius(15.0)
            Spacer().frame(height: 20)
            NavigationLink(destination: RegisterView()) {
                Text("Register")
            }
            Spacer().frame(height: 50)
            
            
            
            
        }.padding([.leading, .trailing], 27.5)
            .alert(isPresented: $hasError){
                Alert(title: Text(errorMessage))
            }
    }
        
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
