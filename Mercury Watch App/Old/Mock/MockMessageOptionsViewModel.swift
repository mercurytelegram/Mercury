//
//  MockMessageOptionsViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 12/09/24.
//

import Foundation

class MockMessageOptionsViewModel: MessageOptionsViewModel_Old {
    init() {
        super.init(messageId: 0, chatId: 0)
    }
    
    override func getReactions() async {
        self.emojis = ["🤣", "❤️", "🔥", "🤝", "🙈", "👌", "👀", "😱", "❤‍🔥", "😭", "🗿", "🤯", "😍", "😢", "🤬", "👎", "🍾", "🕊", "👍", "🖕", "🤔", "🤮", "🌚", "🤷‍♂", "🥰", "💯", "😁", "🥴", "👏", "🎉", "🤩", "💩", "🙏", "🤡", "🥱", "🐳", "🌭", "⚡", "🍌", "🏆", "💔", "🤨", "😐", "🍓", "💋", "😈", "😴", "🤓", "👻", "👨‍💻", "🎃", "😇", "😨", "✍", "🤗", "🫡", "🎅", "🎄", "☃", "💅", "🤪", "🆒", "💘", "🙉", "🦄", "😘", "💊", "🙊", "😎", "👾", "🤷", "🤷‍♀", "😡"]
    }
    
}
