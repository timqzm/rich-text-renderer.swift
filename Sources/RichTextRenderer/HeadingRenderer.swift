//
//  HeadingRenderer.swift
//  ContentfulRichTextRenderer
//
//  Created by JP Wright on 9/26/18.
//  Copyright © 2018 Contentful GmbH. All rights reserved.
//

import Foundation
import Contentful

/// A renderer for a `Contentful.Heading` node. This renderer will apply fonts to the range of characters that comprise
/// the node using the font types and sizes provided in the `RendererConfiguration` passed into the `DefaultRichTextRenderer`.
public struct HeadingRenderer: NodeRenderer {

    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString] {
        let heading = node as! Heading
        var rendered = heading.content.reduce(into: [NSMutableAttributedString]()) { (rendered, node) in
            let nodeRenderer = renderer.renderer(for: node)
            let renderedChildren = nodeRenderer.render(node: node, renderer: renderer, context: context)
            rendered.append(contentsOf: renderedChildren)
        }

        rendered.forEach { str in
            var range = NSRange(location: 0, length: str.length)
            let oldFont = str.attribute(.font, at: 0, effectiveRange: &range) as? Font
            let oldTraits = oldFont?.fontDescriptor.symbolicTraits
            
            // dirty workaround to get bold marks in headers
            var bold = oldTraits?.contains(.traitBold) == true
            var attributes = context.styleConfig.headingAttributes(level: Int(heading.level), bold: bold)
            
            if let newFont = attributes[.font] as? Font,
                let oldTraits = oldTraits,
                let descriptor = newFont.fontDescriptor.withSymbolicTraits(oldTraits) {
                attributes[.font] = Font(descriptor: descriptor, size: newFont.pointSize)
            }
            
            str.addAttributes(attributes, range: range)
        }
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.appendNewlineIfNecessary(node: node)
        return rendered
    }
}
