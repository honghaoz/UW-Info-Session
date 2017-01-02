//
//  UIViewController+PresentationStyle.swift
//  Sexify
//
//  Created by Honghao Zhang on 2016-06-27.
//  Copyright © 2016 Sexify. All rights reserved.
//

import UIKit

/**
 Presentation style when being presented (shown)
 
 - Embedded:   Like pushed onto navigation controller view stack
 - Standalone: Present normally
 */
enum PresentationStyle {
    case embedded
    case standalone
}

protocol PresentationStyleable  {
    func preferredPresentationStyle() -> PresentationStyle? // return nil for default behavior
}
