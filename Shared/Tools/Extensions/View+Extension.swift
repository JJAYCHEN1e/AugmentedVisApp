//
//  View+Extension.swift
//  AugmentedVisApp
//
//  Created by jjaychen on 2021/10/11.
//

import SwiftUI

extension View {
	func execute(closure: () -> ()) -> EmptyView {
		closure()
		return EmptyView()
	}
}
