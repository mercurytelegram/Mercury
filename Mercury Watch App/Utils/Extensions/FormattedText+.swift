//
//  FormattedText+.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 31/05/24.
//

import TDLibKit
import SwiftUI

extension FormattedText {
    var attributedString: AttributedString {
        
        var resultString = AttributedString(text)
        
        for entity in entities {
            
            let nsRange = range(for: text, offset: entity.offset, length: entity.length)
            guard let range = Range(nsRange, in: resultString) else {
                return resultString
            }
            
            switch entity.type {
            case .textEntityTypeBold:
                resultString[range].font = .system(.body).bold()
            case .textEntityTypeItalic:
                resultString[range].font = .system(.body).italic()
            case .textEntityTypeCode:
                resultString[range].font = .system(.body).monospaced()
            case .textEntityTypeUnderline:
                resultString[range].underlineStyle = .single
            case .textEntityTypeStrikethrough:
                resultString[range].strikethroughStyle = .single
            case .textEntityTypeUrl:
                guard let textRange = Range(nsRange, in: text),
                      let url = URL.fromTelegramEntity(String(text[textRange])) else {
                    break
                }
                resultString[range].link = url
                resultString[range].foregroundColor = .blue
                resultString[range].underlineStyle = .single
            case .textEntityTypeEmailAddress:
                guard let textRange = Range(nsRange, in: text),
                      let url = URL(string: "mailto:\(text[textRange])") else {
                    break
                }
                resultString[range].link = url
                resultString[range].foregroundColor = .blue
                resultString[range].underlineStyle = .single
            case .textEntityTypePhoneNumber:
                guard let textRange = Range(nsRange, in: text),
                      let url = URL(string: "tel:\(text[textRange])") else {
                    break
                }
                resultString[range].link = url
                resultString[range].foregroundColor = .blue
                resultString[range].underlineStyle = .single
            case .textEntityTypeTextUrl(let data):
                guard let url = URL.fromTelegramEntity(data.url) else {
                    break
                }
                resultString[range].link = url
                resultString[range].foregroundColor = .blue
                resultString[range].underlineStyle = .single
            case .textEntityTypeMention:
                resultString[range].foregroundColor = .blue
                guard let textRange = Range(nsRange, in: text) else {
                    break
                }
                let username = text[textRange].dropFirst()
                if !username.isEmpty {
                    resultString[range].link = URL(string: "https://t.me/\(username)")
                    resultString[range].underlineStyle = .single
                }
            case .textEntityTypeSpoiler:
                resultString.characters.replaceSubrange(range, with: getRandomBraille(length: entity.length))
            case .textEntityTypeBlockQuote:
                let quote = String(resultString[range].characters)
                resultString.characters.replaceSubrange(range, with: "❝\(quote)❞")
            default:
                break
            }
        }
        return resultString
    }
    
    func getRandomBraille(length: Int) -> String {
        let braille = "⠁⠂⠃⠄⠅⠆⠇⠈⠉⠊⠋⠌⠍⠎⠏⠐⠑⠒⠓⠔⠕⠖⠗⠘⠙⠚⠛⠜⠝⠞⠟⠠⠡⠢⠣⠤⠥⠦⠧⠨⠩⠪⠫⠬⠭⠮⠯⠰⠱⠲⠳⠴⠵⠶⠷⠸⠹⠺⠻⠼⠽⠾⠿"
        var string = ""
        
        for _ in 0...length - 1{
            let randomIndex = Int.random(in: 0...braille.count - 1)
            let index = braille.index(braille.startIndex, offsetBy: randomIndex)
            string.append(braille[index])
        }
        return string
    }
    
    private func range(for string: String, offset: Int, length: Int) -> NSRange {
        let start = text.utf16.index(text.startIndex, offsetBy: offset)
        let end = text.utf16.index(start, offsetBy: length)
        return NSRange(start..<end, in: text)
    }
    
}

extension AttributedString {
    var removingLinks: AttributedString {
        var result = self
        for run in result.runs where run.link != nil {
            result[run.range].link = nil
            result[run.range].underlineStyle = nil
            result[run.range].foregroundColor = nil
        }
        return result
    }
}

private extension URL {
    static func fromTelegramEntity(_ value: String) -> URL? {
        guard !value.isEmpty else { return nil }
        if let url = URL(string: value), url.scheme != nil {
            return url
        }
        return URL(string: "https://\(value)")
    }
}
