//
//  Text+.swift
//  FitFlow
//
//  Created by Engin Bolat on 24.12.2025.
//

import SwiftUI

extension Text {
    init(localizable: LocalizableEnum) {
        self.init(LocalizedStringKey(localizable.rawValue))
    }
}
