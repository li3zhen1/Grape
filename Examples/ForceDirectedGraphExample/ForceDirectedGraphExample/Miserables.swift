//
//  Miserables.swift
//  ForceDirectedGraphExample
//
//  Created by li3zhen1 on 11/5/23.
//

import Foundation
import Grape
import SwiftUI
import Charts


struct MiserableGraph: View {
    
    private let graphData = getData(miserables)
    
    @State private var inspectorPresented = false
    
    
    @State private var stateMixin = ForceDirectedGraphState(
        initialIsRunning: true,
        initialModelTransform: .identity.scale(by: 1.4)
    )
    
    //    @State private var opacity = 0.0
    
    @ViewBuilder
    func getLabel(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(.background)
            .font(.caption2)
            .padding(.vertical, 2.0)
            .padding(.horizontal, 6.0)
            .background(alignment: .center) {
                RoundedRectangle(cornerSize: .init(width: 12, height: 12))
                    .fill(.foreground)
                    .shadow(radius: 1.5, y: 1.0)
            }
            .padding()
    }
    
    var body: some View {
        
        ForceDirectedGraph(
            states: stateMixin
        ) {
            
            Series(graphData.nodes) { node in
                NodeMark(id: node.id)
                    .symbol(.circle)
                    .symbolSize(radius: 8.0)
                    .foregroundStyle(colors[node.group % colors.count])
                    .stroke()
                    .annotation(node.id, offset: .zero) {
                        let connections = graphData.links.count { $0.source == node.id || $0.target == node.id }
                        
                        if connections > 12 {
                            self.getLabel(node.id)
                        }
                    }
            }
            
            Series(graphData.links) { l in
                LinkMark(from: l.source, to: l.target)
            }
            
        } force: {
            .manyBody(strength: -20)
            .center()
            .link(
                originalLength: 35.0,
                stiffness: .weightedByDegree { _, _ in 1.0}
            )
        }
        .graphOverlay(content: { proxy in
            Rectangle().fill(.clear).contentShape(Rectangle())
                .withGraphDragGesture(proxy, of: String.self)
        })
        .ignoresSafeArea()
        .toolbar {
            GraphStateToggle(graphStates: stateMixin)
        }
    }
}

struct MiserableToolbarContent: View {
    @Bindable var stateMixin: ForceDirectedGraphState
    @Binding var opacity: Double
    
    var body: some View {
        Group {
            Button {
                stateMixin.modelTransform.scaling(by: 0.9)
            } label: {
                Image(systemName: "minus")
            }
            Button {
                stateMixin.modelTransform.scaling(by: 1.1)
            } label: {
                Text(String(format:"Scale: %.2f", stateMixin.modelTransform.scale))
                    .fontDesign(.monospaced)
            }
            Button {
                stateMixin.modelTransform.scaling(by: 1.1)
            } label: {
                Image(systemName: "plus")
            }
        }
        
        
        Button {
            stateMixin.isRunning.toggle()
            if opacity < 1 {
                opacity = 1
            }
        } label: {
            Image(systemName: stateMixin.isRunning ? "pause.fill" : "play.fill")
            Text(stateMixin.isRunning ? "Pause" : "Start")
        }
    }
}
