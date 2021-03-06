//
//  NSAttributedString.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 01/10/18.
//

import Foundation
import Contentful


#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import Cocoa
import AppKit
#endif

internal extension NSMutableAttributedString {

    /// This method uses all the state passed-in via the `context` to apply the proper paragraph styling
    /// to the characters contained in the passed-in node.
    func applyListItemStyling(node: Node, context: [CodingUserInfoKey: Any]) {
        let listContext = context[.listContext] as! ListContext

        // At level 0, we're not rendering a list.
        guard listContext.level > 0 else { return }

        let renderingConfig = context.styleConfig
        let paragraphStyle = NSMutableParagraphStyle()
        let indentation = CGFloat(listContext.indentationLevel) * renderingConfig.indentationMultiplier

        // The first tab stop defines the x-position where the bullet or index is drawn.
        // The second tab stop defines the x-position where the list content begins.
        let tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: [:]),
            NSTextTab(textAlignment: .left, location: indentation + renderingConfig.distanceFromBulletMinXToCharMinX, options: [:])
        ]

        paragraphStyle.tabStops = tabStops

        // Indent subsequent lines to line up with first tab stop after bullet.
        paragraphStyle.headIndent = indentation + renderingConfig.distanceFromBulletMinXToCharMinX

        paragraphStyle.paragraphSpacing = renderingConfig.paragraphSpacing
        paragraphStyle.lineSpacing = renderingConfig.lineSpacing

        addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: length))
    }
}
