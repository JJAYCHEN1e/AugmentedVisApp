//
//  ARVisInfoView.swift
//  ARVisInfoView
//
//  Created by jjaychen on 2021/10/23.
//

import SwiftUI

struct ARVisInfoView: View {
    let viewInfoComponents: [ViewInfoComponent]
    
    @ViewBuilder
    private var resultView: some View {
        if viewInfoComponents.count > 0 {
            ViewInfoComponent.vStack(elements: viewInfoComponents).view
        } else {
            EmptyView()
        }
    }

    var body: some View {
        ScrollView {
            resultView
                .padding()
        }
        .background(.ultraThinMaterial)
        .cornerRadius(25)
    }
}

struct ARVisInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let generatedViewInfoComponent = SampleViewInfoComponentHelper.sampleViewInfoComponent
        
        return ARVisInfoView(viewInfoComponents: [generatedViewInfoComponent])
            .preferredColorScheme(.dark)
            .frame(width: 300, height: 200)
    }
}
