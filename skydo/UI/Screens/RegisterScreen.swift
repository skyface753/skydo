//
//  RegisterScreen.swift
//  skydo
//
//  Created by Sebastian Jörz on 30.12.22.
//

import SwiftUI
import Appwrite

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // MARK: - Propertiers
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirm: String = ""
    @State private var hasError: Bool = false
    @State private var errorMessage: String = ""
    @State private var registerSuccess: Bool = false
    
    // MARK: - View
    var body: some View{
        VStack(alignment: .leading, spacing: 15){
            Text("SkyDo - Register")
                .font(.largeTitle).foregroundColor(Color.green)
                .padding([.top, .bottom], 30)
            Image("Logo")
                .resizable()
                .frame(width: 300, height: 250)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
                .padding(.bottom, 50)
            TextField("E-Mail", text: $email).padding()
            //.background(themeTextField)
                .cornerRadius(20.0)
            SecureField("Password", text: $password).padding()
                .cornerRadius(20.0)
            SecureField("Confirm Password", text: $passwordConfirm).padding()
                .cornerRadius(20.0)
            hasError ? Text(errorMessage) : Text("")
            
            Button("Register") {
                if(password != passwordConfirm){
                    hasError = true
                    errorMessage = "Passwords do not match"
                    return
                }
                Task{
                    let account = Account(appwriteClient)
                    do {
                        let register = try await account.create(userId: ID.unique(), email: email, password: password)
                        _ = try await account.createEmailSession(email: email, password: password)
                        print(try await APIService.createVerification())
                        registerSuccess = true
                        print(String(describing: register.toMap()))
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
            
            Spacer().frame(height: 50)
            
            
            
            
        }.padding([.leading, .trailing], 27.5)
            .alert(isPresented: $hasError){
                Alert(title: Text(errorMessage))
            }.alert("Register success. Please login in now", isPresented: $registerSuccess){
                Button("OK", role: .cancel){
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
    }
        
}

#if DEBUG
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
#endif
