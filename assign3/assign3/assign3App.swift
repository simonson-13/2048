//
//  assign3App.swift
//  assign3
//
//  Created by Simon Liao on 10/14/21.
//

import SwiftUI

@main
struct assign2App: App {
    @StateObject var twos = Twos()

    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(twos)
        }
    }
}



