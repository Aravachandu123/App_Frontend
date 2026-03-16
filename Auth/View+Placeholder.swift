//
//  View+Placeholder.swift
//  GenCare Assist1
//
//  Created by SAIL on 12/02/26.
//

//
//  View+Placeholder.swift
//  GenCare Assist1
//
//  Created by SAIL on 13/02/26.
//

import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
