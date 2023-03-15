//
//  ContentView.swift
//  ScribbleAI
//
//  Created by Ben Buchanan on 3/14/23.
//

import SwiftUI
import CoreData
import Foundation
import Replicate
import AnyCodable

struct ContentView: View {
    
    @State var prompt: String
    @State var imageURL: String = ""

    var body: some View {
        VStack {
            Spacer()
            
            TextField("Enter prompt", text: $prompt, axis: .vertical)
                .padding()
                .padding(.horizontal, 20)
                .font(.headline)
                .textFieldStyle(.roundedBorder)
            Button {
                Task {
                    do {
                        try await runModel(prompt: self.prompt)
                    } catch {
                        print("Error running model")
                    }
                }
            } label: {
                Text("Run model")
                  .padding()
                  .foregroundColor(.white)
                  .background(Color.blue)
                  .cornerRadius(10)
              }
            
            Spacer()
            
            AsyncImage(url: URL(string: self.imageURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.purple.opacity(0.1)
            }
            .frame(width: 300, height: 500)
            
            Spacer()
        }
    }
    
    @MainActor func updateImageURL(newImageURL: String) {
        print("new URL is: \(newImageURL)")
        self.imageURL = newImageURL
    }
    
    //TODO: pull token from secrets store (GitHub)
    let client = Client(token: "")

    func runModel(prompt: String) async throws {
        print("Running model")
        let model = try await client.getModel("stability-ai/stable-diffusion")
        if let latestVersion = model.latestVersion {
            let prediction = try await client.createPrediction(version: latestVersion.id, input: ["prompt": "\(prompt)"], wait: true)
            
            let decoder = JSONDecoder()
            let outputString = try? decoder.decode([String].self, from: String(describing: prediction.output!).data(using: .utf8)!)
            
            print(outputString?[0] ?? "Error getting output string")
            
            await updateImageURL(newImageURL: outputString?[0] ?? "")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(prompt: "").environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
