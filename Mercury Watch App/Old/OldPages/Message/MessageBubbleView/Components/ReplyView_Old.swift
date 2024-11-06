//
//  ReplyView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 07/09/24.
//

import SwiftUI
import TDLibKit

struct ReplyView_Old: View {
    @StateObject private var vm: ReplyViewModel_Old
    
    init(message: Message) {
        self._vm = StateObject(wrappedValue: ReplyViewModel_Old(message: message))
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(vm.title)
                .fontWeight(.semibold)
                .foregroundStyle(vm.color)
            Text(vm.text)
                .lineLimit(2)
        }
        .redacted(reason: vm.isLoading ? .placeholder : [])
        .padding()
        .padding(.leading, 3)
        .background {
            HStack(spacing: 0) {
                Rectangle()
                    .foregroundStyle(vm.color)
                    .frame(width: 5)
                Rectangle()
                    .foregroundStyle(vm.color.opacity(0.3))
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    VStack {
        ReplyView_Old(message:
                .preview(isOutgoing: false)
        )
        ReplyView_Old(message:
                .preview(isOutgoing: true)
        )
    }
}
