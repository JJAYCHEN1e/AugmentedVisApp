//
//  ARVisSettingView.swift
//  ARVisSettingView
//
//  Created by jjaychen on 2021/10/23.
//

import SwiftUI

struct ARVisSettingView<X: Hashable & Comparable>: View {

    init(items: Binding<[ChartData<X>]>, realTimeTrackingEnabled: Binding<Bool>) {
        _items = items
        _realTimeTrackingEnabled = realTimeTrackingEnabled
    }

    @Binding var items: [ChartData<X>]

    @Binding var realTimeTrackingEnabled: Bool

    var body: some View {
        VStack {
            Label("Setting", systemImage: "gearshape")
                .font(.system(size: 22))

            List {
                Section {
                    Toggle("Real time tracking", isOn: $realTimeTrackingEnabled)
                } header: {
                    Text("Real time tracking")
                }
                .listRowBackground(Color.white.opacity(0.5))

                Section {
                    ForEach($items) { $item in
                        Toggle(item.name.prefix(5), isOn: Binding(get: { !$item.isHidden.wrappedValue }, set: { $item.isHidden.wrappedValue = !$0}))
                    }
                } header: {
                    Text("Curves📈")
                }
                .listRowBackground(Color.white.opacity(0.5))
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
        ARVisSettingView<Int>(items: .constant([]), realTimeTrackingEnabled: .constant(true))
            .frame(maxWidth: 300)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
