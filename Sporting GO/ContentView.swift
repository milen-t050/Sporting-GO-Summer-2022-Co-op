//
//  ContentView.swift
//  Sporting GO
//
//  Created by AppleSHSM on 2022-07-22.
//

import SwiftUI

let backgroundGradient = LinearGradient(
    gradient: Gradient(colors: [Color.red, Color.gray]),
    startPoint: .top, endPoint: .bottom)


struct ContentView: View {
    var body: some View {
        NavigationView{
            ZStack{
                backgroundGradient
                    .ignoresSafeArea()
                VStack {
                    Text("Sporting GO")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Text("Type in 'Park' for general areas, or type in the sport you wish to play.")
                        .font(.body)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(width: 150.0)
                        .foregroundColor(.white)
                    Spacer()
                    NavigationLink(destination: SearchView()) {
                            Text("Let's go Search")
                                .padding()
                                .foregroundColor(.white)
                                .background(.indigo)
                                .cornerRadius(20)
                                .font(.title2)
                           }
                    Spacer()
                    HStack{
                        Image("character-5")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 207, height: 319)
                        Spacer()
                        Image("people-in-the-summer-2")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 207, height: 319)
                            .padding(.horizontal, 20.0)
                        
                    }
                }
            }
        }.navigationBarHidden(true)
//            .padding(.bottom, 45.0)
    }
}

struct ConetentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
