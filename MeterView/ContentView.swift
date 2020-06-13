//
//  ContentView.swift
//  MeterView
//
//  Created by Tanin on 13/06/2020.
//

import SwiftUI

struct ContentView: View {
    @State var progress: CGFloat = 0
    var body: some View {
        VStack {
            MeterView(progress: progress) {
                Text("Hi")
            }
            HStack {
                Spacer()
                Button(action: {
                    if self.progress >= 10 { self.progress -= 10 }
                }, label: {
                    Text("-10")
                })
                Spacer()
                Button(action: {
                    if self.progress <= 90 { self.progress += 10 }
                }, label: {
                    Text("+10")
                })
                Spacer()
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
