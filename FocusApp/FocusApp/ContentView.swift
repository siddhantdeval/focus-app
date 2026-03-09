//
//  ContentView.swift
//  FocusApp
//
//  Created by Siddhant Deval on 09/03/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FocusViewModel()
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Side: Task List
            VStack(alignment: .leading) {
                Text("Tasks")
                    .font(.headline)
                    .padding()
                
                HStack {
                    TextField("Add a task...", text: $viewModel.newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                    Button("Add") {
                        viewModel.addTask()
                    }
                }
                .padding(.horizontal)
                
                List(viewModel.tasks, id: \.id) { task in
                    HStack {
                        Toggle("", isOn: Binding(
                            get: { task.isCompleted },
                            set: { _ in viewModel.toggleTaskCompletion(task: task) }
                        ))
                        .labelsHidden()
                        
                        Text(task.title)
                            .strikethrough(task.isCompleted, color: .primary)
                        
                        Spacer()
                        
                        Button("Delete") {
                            viewModel.delete(id: task.id)
                        }
                        .foregroundColor(.red)
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(minWidth: 300, maxWidth: .infinity)
            
            Divider()
            
            // Right Side: Timer
            VStack {
                Text("Focus Time")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Text(formatTime(viewModel.timerRemaining))
                    .font(.system(size: 80, weight: .bold, design: .default))
                    .padding()
                
                Text("State: \(String(describing: viewModel.timerState))")
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                HStack(spacing: 20) {
                    if viewModel.timerState == .idle || viewModel.timerState == .paused {
                        Button(viewModel.timerState == .idle ? "Start" : "Resume") {
                            viewModel.start(duration: 1500) // 25 minutes
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    if viewModel.timerState == .running {
                        Button("Pause") {
                            viewModel.pause()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if viewModel.timerState != .idle {
                        Button("Stop") {
                            viewModel.stop()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                }
                
                Spacer()
            }
            .frame(minWidth: 400, maxWidth: .infinity)
            .background(Color(NSColor.windowBackgroundColor))
        }
    }
}

#Preview {
    ContentView()
}
