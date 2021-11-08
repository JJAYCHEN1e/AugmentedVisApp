//
//  ARVisSettingView.swift
//  ARVisSettingView
//
//  Created by jjaychen on 2021/10/23.
//

import SwiftUI

struct ARVisSettingView: View {
    let sectionComponents: [AnyARVisSettingViewComponent]

    var body: some View {
        VStack {
            Label("Setting", systemImage: "gearshape")
                .font(.system(size: 22))

            List {
                ForEach(sectionComponents) { component in
                    Section {
                        component.view
                    } header: {
                        Text(component.sectionName)
                    }
                    .listRowBackground(Color.white.opacity(0.5))

                }
            }
        }
        .padding(.top)
        .background(.ultraThinMaterial)
        .cornerRadius(30)
        .onAppear {
            UITableView.appearance().backgroundColor = .clear
            UITableView.appearance().contentInset.top = -35
        }
        .onDisappear {
            UITableView.appearance().backgroundColor = .systemBackground
            UITableView.appearance().contentInset = .zero
        }
    }
}

struct ARVisSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ARVisSettingView(sectionComponents: [
            .trackingComponent(realTimeTrackingEnabled: .constant(true))
        ])
            .frame(maxWidth: 300)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
