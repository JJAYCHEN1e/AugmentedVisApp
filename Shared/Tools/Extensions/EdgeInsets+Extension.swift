//
//  EdgeInsets+Extension.swift
//  AugmentedVisApp
//
//  Created by jjaychen on 2021/10/11.
//

import SwiftUI

extension EdgeInsets {
	var horizontal: CGFloat {
		get {
			leading + trailing
		}
	}
	
	var vertical: CGFloat {
		get {
			top + bottom
		}
	}
}
