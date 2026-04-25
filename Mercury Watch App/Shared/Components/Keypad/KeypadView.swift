//
//  KeypadView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 25/04/24.
//

import SwiftUI

struct KeypadView: View {
    @Binding var value: String
    var maxLenght: Int? = nil
    
    var body: some View {
        Grid(verticalSpacing: 2) {
            ForEach(0...2, id: \.self) { row in
                GridRow {
                    ForEach(0...2, id: \.self) { column in
                        let number = "\(row*3 + column + 1)"
                        Button(number) {
                            add(number)
                        }
                        .buttonStyle(
                            KeyboardButtonStyle(
                                xOffset: xOffset(for: column),
                                yOffset: yOffset(for: row))
                        )
                    }
                }
            }
            GridRow {
                Spacer()
                Button("0") {
                    add("0")
                }
                .buttonStyle(KeyboardButtonStyle(yOffset: -1))
                
                Button(
                    "Delete",
                    systemImage: "delete.left.fill",
                    action: delete
                )
                .buttonStyle(KeyboardDeleteButtonStyle())
                .buttonRepeatBehavior(.enabled)
            }
        }
        .sensoryFeedback(.selection, trigger: value)
    }
    
    func add(_ newValue: String) {
        withAnimation {
            if maxLenght == nil || value.count < maxLenght! {
                value += newValue
            } else {
                WKInterfaceDevice.current().play(.failure)
            }
        }
    }
    
    func delete() {
        withAnimation {
            if !value.isEmpty {
                value.remove(at: value.index(before: value.endIndex))
            } else {
                WKInterfaceDevice.current().play(.stop)
            }
        }
    }
    
    func xOffset(for column: Int) -> CGFloat {
        switch column {
        case 0:
            return 1
        case 2:
            return -1
        default:
            return 0
        }
    }
    
    func yOffset(for row: Int) -> CGFloat {
        switch row {
        case 1:
            return 1
        default:
            return 0
        }
    }
}

struct KeyboardButtonStyle: ButtonStyle {
    ///should be set to 1, -1, or 0
    var xOffset: CGFloat = 0.0
    var yOffset: CGFloat = 0.0
    var bgColor = UIColor.gray
    
    private func getOffset(isPressed: Bool, geometry: GeometryProxy) -> CGSize {
        let w = geometry.size.width / 3
        let h = geometry.size.height / 3
        
        return isPressed ? CGSize(width: xOffset * w, height: yOffset * h) : CGSizeZero
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        GeometryReader { geometry in
            configuration.label
                .font(.title2)
                //Avoid extra padding from GeometryReader
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color(uiColor: bgColor))
                        .opacity(configuration.isPressed ? 1 : 0.4)
                )
                .scaleEffect(configuration.isPressed ? 1.5 : 1)
                .offset(
                    getOffset(
                        isPressed: configuration.isPressed,
                        geometry: geometry
                    )
                )
        }
        .zIndex(configuration.isPressed ? 1 : 0)
    }
}

struct KeyboardDeleteButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.title3)
            .labelStyle(.iconOnly)
            .scaleEffect(configuration.isPressed ? 0.5 : 1)
            //Increase tappable area
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.001))
    }
}

#Preview {
    KeypadView(value: .constant(""))
}
