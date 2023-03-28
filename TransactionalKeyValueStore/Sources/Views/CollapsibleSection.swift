//
//  CollapsibleSection.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/28/23.
//

import SwiftUI

struct CollapsibleSection<Expanded: View, Collapsed: View>: View {
    
    struct AdditionalAction {
        let title: String
        let onTap: () -> Void
    }
    
    @State private var isCollapsed: Bool = true
    let collapsedButtonTitle: String
    let expandedButtonTitle: String
    let expanded: Expanded
    let collapsed: Collapsed
    let additionalAction: AdditionalAction?
    
    init(
        collapsedButtonTitle: String,
        expandedButtonTitle: String,
        isCollapsed: Bool = true,
        additionalAction: AdditionalAction? = nil,
        @ViewBuilder collapsed: () -> Collapsed,
        @ViewBuilder expanded: () -> Expanded
    ) {
        self.expanded = expanded()
        self.collapsed = collapsed()
        self.collapsedButtonTitle = collapsedButtonTitle
        self.expandedButtonTitle = expandedButtonTitle
        self.additionalAction = additionalAction
        self.isCollapsed = isCollapsed
    }
    
    var body: some View {
        Section {
            if isCollapsed {
                collapsed
            } else {
                expanded
            }
        } header: {
            HStack {
                Button(isCollapsed ? collapsedButtonTitle : expandedButtonTitle) {
                    withAnimation {
                        isCollapsed.toggle()
                    }
                }
                .buttonStyle(SectionHeaderButton())
                
                if !isCollapsed,
                   let additionalAction {
                    Spacer()
                    Button(additionalAction.title) {
                        additionalAction.onTap()
                    }
                    .buttonStyle(SectionHeaderButton())
                }
            }
        }
    }
}

struct SectionHeaderButton: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(configuration)
            .textCase(nil)
            .font(.footnote)
    }
}

struct CollapsibleSection_Previews: PreviewProvider {
    static var previews: some View {
        CollapsibleSection(
            collapsedButtonTitle: "Show",
            expandedButtonTitle: "Hide") {
                Text("Collapsed")
            } expanded: {
                Text("Expanded")
            }
    }
}
