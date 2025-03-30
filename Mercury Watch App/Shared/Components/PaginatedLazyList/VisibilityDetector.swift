//
//  VisibilityDetector.swift
//  Mercury
//
//  Created by Marco Tammaro on 30/03/25.
//

import SwiftUI

extension View {
    
    func visibilityDetector<T: Identifiable>(
        value: T,
        shouldCheckDebounce: Bool,
        lowerBound: CGFloat = 0,
        upperBound: CGFloat = WKInterfaceDevice.current().screenBounds.height,
        onAppear: @escaping (T) -> Void = { _ in },
        onDisappear: @escaping (T) -> Void = { _ in }
    ) -> some View {
        modifier(VisibilityDetectorModifier<T>(
            value: value,
            shouldCheckDebounce: shouldCheckDebounce,
            lowerBound: lowerBound,
            upperBound: upperBound,
            onAppear: onAppear,
            onDisappear: onDisappear
        ))
    }
}

struct VisibilityDetectorModifier<T: Identifiable>: ViewModifier {
    let value: T
    
    let shouldCheckDebounce: Bool
    
    let lowerBound: CGFloat
    let upperBound: CGFloat
    
    let onAppear: (T) -> Void
    let onDisappear: (T) -> Void
    
    func body(content: Content) -> some View {
        content
            .background {
                VisibilityDetector<T>(
                    value: value,
                    shouldCheckDebounce: shouldCheckDebounce,
                    lowerBound: lowerBound,
                    upperBound: upperBound,
                    onAppear: onAppear,
                    onDisappear: onDisappear
                )
            }
    }
}


struct VisibilityDetector<T: Identifiable>: View {
    let value: T
    
    let shouldCheckDebounce: Bool
    
    let lowerBound: CGFloat
    let upperBound: CGFloat
    
    let onAppear: (T) -> Void
    let onDisappear: (T) -> Void
    
    @State private var lastCheckTime: Date = Date()
    private let debounceInterval: TimeInterval = 0.1
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .onAppear {
                    checkVisibility(geometry: geometry)
                }
                .onDisappear {
                    checkVisibility(geometry: geometry)
                }
                .onChange(of: geometry.frame(in: .global).minY) { _, _ in
                    debounceCheck(geometry: geometry)
                }
        }
    }
    
    private func debounceCheck(geometry: GeometryProxy) {
        
        if shouldCheckDebounce {
            let now = Date()
            if now.timeIntervalSince(lastCheckTime) > debounceInterval {
                lastCheckTime = now
                checkVisibility(geometry: geometry)
            }
            
        } else {
            checkVisibility(geometry: geometry)
        }
        
    }
    
    private func checkVisibility(geometry: GeometryProxy) {
        let frame = geometry.frame(in: .global)
        
        /*
         xxxxx
         ______________
         xxxxx        |
         |            |
         |            |
         |____________|
         */
        let isBottomVisible = frame.minY < lowerBound && (frame.maxY > lowerBound && frame.maxY < upperBound)
        
        /*
         ______________
         |            |
         |            |
         xxxxx        |
         |____________|
         xxxxx
         */
        let isTopVisible = (frame.minY > lowerBound && frame.minY < upperBound) && (frame.maxY > upperBound)
        
        /*
         xxxxx
         ______________
         |            |
         |            |
         |            |
         |____________|
         xxxxx
         */
        let isContentVisible = frame.minY < lowerBound && frame.maxY > upperBound
        
        /*
         ______________
         |            |
         xxxxx        |
         xxxxx        |
         |____________|
         */
        let isContentInside = frame.minY > lowerBound && frame.maxY < upperBound
        
        let isVisible = isBottomVisible || isTopVisible || isContentVisible || isContentInside
        if isVisible { onAppear(value) }
        if !isVisible { onDisappear(value) }
    }
}
