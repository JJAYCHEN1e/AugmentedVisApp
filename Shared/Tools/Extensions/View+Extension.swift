//
//  View+Extension.swift
//  AugmentedVisApp
//
//  Created by jjaychen on 2021/10/11.
//

import SwiftUI

extension View {
    func execute(closure: () -> Void) -> some View {
        closure()
        return Circle().fill().opacity(0)
    }
}
