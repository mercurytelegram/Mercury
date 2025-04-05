//
//  PaginatedLazyList.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 30/03/25.
//

import SwiftUI
import UIKit

@available(watchOS 11.0, *)
struct PaginatedLazyList<Item: Identifiable & Equatable & Hashable, Content: View>: View {
    
    @State private var items: [Item] = []
    @State private var scrollPosition: Item.ID? = nil
    @State private var hasScrolled = false
    @State private var hasStartedScrolled = false
    @State private var visibleItems: Set<Item> = []
    
    @State private var fetchItems: [Item]? = nil
    @State private var isScrolling: Bool = false
    @State private var isFetching: Bool = false
    
    @ViewBuilder let cell: (Item) -> Content
    
    @State var firstVisibleItemId: Item.ID?
    let fetchOffset: Int
    let onVisibleItemsChange: ((Set<Item>) -> Void)?
    let fetchBackwardItems: (Item) async -> [Item]
    let fetchForwardItems: (Item) async -> [Item]
    
    init(
        initialItems: [Item],
        firstVisibleItemId: Item.ID? = nil,
        fetchOffset: Int = 0,
        fetchBackwardItems: @escaping (Item) async -> [Item],
        fetchForwardItems: @escaping (Item) async -> [Item],
        onVisibleItemsChange: ((Set<Item>) -> Void)? = nil,
        cell: @escaping (Item) -> Content)
    {
        self.items = initialItems
        self.firstVisibleItemId = firstVisibleItemId ?? initialItems.last?.id
        self.onVisibleItemsChange = onVisibleItemsChange
        self.fetchOffset = fetchOffset
        self.fetchBackwardItems = fetchBackwardItems
        self.fetchForwardItems = fetchForwardItems
        self.cell = cell
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                
                if isFetching {
                    ProgressView()
                }
                
                ForEach(items) { item in
                    cell(item)
                        .id(item.id)
                        .visibilityDetector(
                            value: item,
                            shouldCheckDebounce: hasScrolled,
                            onAppear: { visibleItems.insert($0) },
                            onDisappear: { visibleItems.remove($0) }
                        )
                }
                
                if isFetching {
                    ProgressView()
                }
                
            }
            .onChange(of: visibleItems, onVisibleItemChange)
            .geometryGroup()
            .scrollTargetLayout()
        }
        .onScrollPhaseChange({ oldPhase, newPhase in
            isScrolling = newPhase.isScrolling
            if let fetchItems, !newPhase.isScrolling {
                items.insert(contentsOf: fetchItems, at: 0)
                self.fetchItems = nil
                self.isFetching = false
            }
        })
        .scrollPosition(id: $scrollPosition, anchor: .top)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                guard let firstVisibleItemId else { return }
                scrollPosition = firstVisibleItemId
                hasStartedScrolled = true
                onVisibleItemChange(oldValue: [], newValue: visibleItems)
            }
        }
    }
    
    func onVisibleItemChange(oldValue: Set<Item>, newValue: Set<Item>) {
        
        var delta = newValue.subtracting(oldValue)

        // First iteration after the firstVisibleItemIndex scroll
        if hasStartedScrolled, let firstVisibleItemId,
            visibleItems.contains(where: { $0.id == firstVisibleItemId })
        {
            hasScrolled = true
            self.firstVisibleItemId = nil
            delta = newValue
        }
        
        guard hasScrolled, !delta.isEmpty else { return }
        onVisibleItemsChange?(delta)
        
        let count = items.count
        
        var forwardFetchPivotIndex = count - 1 - fetchOffset
        if !items.indices.contains(forwardFetchPivotIndex) {
            forwardFetchPivotIndex = count - 1
        }
        
        if !isFetching && delta.contains(where: { $0 == items[forwardFetchPivotIndex] }) {
            Task.detached { [items] in
                await MainActor.run { self.isFetching = true }
                var newItems = await self.fetchForwardItems(items[forwardFetchPivotIndex])
                for item in items {
                    newItems.removeAll(where: { $0.id == item.id })
                }
                
                await MainActor.run { [newItems] in
                    self.items.append(contentsOf: newItems)
                    self.isFetching = false
                }
            }
        }
        
        var backwardFetchPivotIndex = fetchOffset
        if !items.indices.contains(backwardFetchPivotIndex) {
            backwardFetchPivotIndex = 0
        }
        
        if !isFetching && delta.contains(where: { $0 == items[backwardFetchPivotIndex] }) {
            Task.detached { [items] in
                await MainActor.run { self.isFetching = true }
                var newItems = await self.fetchBackwardItems(items[backwardFetchPivotIndex])
                for item in items {
                    newItems.removeAll(where: { $0.id == item.id })
                }
                
                await MainActor.run { [newItems] in
                    self.fetchItems = newItems
                    if !isScrolling {
                        self.items.insert(contentsOf: newItems, at: 0)
                        self.fetchItems = nil
                        self.isFetching = false
                    }
                }
            }
        }
        
    }
}

@available(watchOS 11.0, *)
struct PaginatedLazyList_Preview: PreviewProvider {
    
    struct PaginatedLazyListPreviewModel: Identifiable, Equatable, Hashable {
        var id: Int
        var text: String
    }

    static var initialItems: [PaginatedLazyListPreviewModel] = {
        return Range(uncheckedBounds: (0, 100))
            .map({ PaginatedLazyListPreviewModel(id: $0, text: "\($0)") })
    }()
    
    static var previews: some View {
        PaginatedLazyList(
            initialItems: initialItems,
            firstVisibleItemId: initialItems[30].id,
            fetchOffset: 2,
            fetchBackwardItems: {
                print("fetch backward for pivot: \($0.text)")
                return await getItems($0, forward: false)
            },
            fetchForwardItems: {
                print("fetch forward for pivot: \($0.text)")
                return await getItems($0, forward: true)
            },
            onVisibleItemsChange: { visibleItems in
                print("View items: \(visibleItems.map(\.text))")
            },
            cell: self.cell
        )
    }

    static func getItems(_ item: PaginatedLazyListPreviewModel, forward: Bool = true) async -> [PaginatedLazyListPreviewModel] {
        var items = [PaginatedLazyListPreviewModel]()
        let start = (Int(item.text) ?? 0) + (forward ? 2 : -2)
        let range = forward ? (start+1)..<(start + 11) : (start - 10)..<start
        
        for i in range {
            items.append(.init(id: i, text: "\(i)"))
        }
        
        try? await Task.sleep(for: .seconds(2))
        return items
    }
    
    @ViewBuilder
    static func cell(item: PaginatedLazyListPreviewModel) -> some View {
        HStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(item.text)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

