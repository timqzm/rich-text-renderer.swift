//
//  TextRenderer.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 9/26/18.
//  Copyright © 2018 Contentful GmbH. All rights reserved.
//

import Foundation
import Contentful

/// A renderer for a `Contentful.Text` node. This renderer will introspect the `Text` node's marks to apply
/// the proper fonts to the range of characters that comprise the node.
/// Font types and sizes are provided in the `RendererConfiguration` passed into the `DefaultRichTextRenderer`.
public struct TextRenderer: NodeRenderer {

    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString] {
        let text = node as! Text
        let renderingConfig = context.styleConfig

        let font = DefaultRichTextRenderer.font(for: text, config: renderingConfig)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = renderingConfig.lineSpacing
        paragraphStyle.paragraphSpacing = renderingConfig.paragraphSpacing

        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        if text.marks.first(where: { $0.type == .underline }) != nil {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }

        let attributedString = NSMutableAttributedString(string: text.value, attributes: attributes)
        return [attributedString]
    }
}
