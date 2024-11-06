//
//  StateIconView.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 05/11/24.
//

import SwiftUI

struct StateIconView: View {
    let style: MessageModel.StateStyle
    
    var body: some View {
        switch style {
        case .sending:
            sending()
        case .delivered:
            delivered()
        case .seen:
            seen()
        case .failed:
            failed()
        }
    }
    
    @ViewBuilder
    func sending() -> some View {
        TimelineView(.animation) { timeline in
            let date = timeline.date
            let rotationAngle = Angle.degrees(
                date
                    .timeIntervalSinceReferenceDate
                    .truncatingRemainder(dividingBy: 1.8) * 360 / 1.8
            )
            
            Image(systemName: "arrow.triangle.2.circlepath")
                .rotationEffect(rotationAngle)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    func delivered() -> some View {
        Image(systemName: "checkmark")
            .font(.footnote)
    }
    
    @ViewBuilder
    func seen() -> some View {
        ZStack {
            Image(systemName: "checkmark")
                .font(.footnote)
                
            Image(systemName: "checkmark")
                .font(.footnote)
                .offset(x: 5)
                .mask(alignment: .leading) {
                    Rectangle()
                        .offset(x: 10, y: -4)
                        .rotationEffect(Angle(degrees: 33))
                        
                }
        }
        .offset(x: -3)
    }
    
    @ViewBuilder
    func failed() -> some View {
        Image(systemName: "exclamationmark.circle.fill")
            .font(.footnote)
    }
    
}

#Preview {
    VStack(spacing: 20) {
        StateIconView(style: .sending)
        StateIconView(style: .delivered)
        StateIconView(style: .seen)
        StateIconView(style: .failed)
    }
}
