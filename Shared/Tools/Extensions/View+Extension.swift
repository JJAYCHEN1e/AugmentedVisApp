//
//  View+Extension.swift
//  AugmentedVisApp
//
//  Created by jjaychen on 2021/10/11.
//

import SwiftUI

extension View {
    func execute(closure: () -> Void) -> EmptyView {
        closure()
        return EmptyView()
    }
}
