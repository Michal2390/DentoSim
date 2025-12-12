//
//  ContentView.swift
//  DentoSim XR
//
//  Created by Michal Fereniec on 17/11/2025.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @State private var selectedModule: ProcedureModule?
    
    var body: some View {
        NavigationSplitView {
            moduleList
        } detail: {
            if let module = selectedModule {
                ModuleDetailView(module: module)
            } else {
                welcomeView
            }
        }
        .navigationTitle("DentoSim XR")
    }
    
    private var moduleList: some View {
        List(ProcedureData.allModules, selection: $selectedModule) { module in
            ModuleRowView(module: module)
                .tag(module as ProcedureModule?)
        }
        .listStyle(.sidebar)
        .navigationTitle("Training Modules")
    }
    
    private var welcomeView: some View {
        VStack(spacing: 30) {
            Image(systemName: "cross.case.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
            
            Text("Welcome to DentoSim XR")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Select a training module from the sidebar to begin your dental simulation.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
            
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(icon: "hand.tap", title: "Interactive Learning", description: "Practice procedures in immersive 3D")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Track Progress", description: "Monitor your performance metrics")
                FeatureRow(icon: "graduationcap", title: "Expert Guidance", description: "Step-by-step instructions")
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            
            Divider()
                .padding(.vertical)
            
            VStack(spacing: 15) {
                Text("Quick Actions")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                ToggleImmersiveSpaceButton(module: nil)
                    .frame(maxWidth: 400)
            }
        }
        .padding(40)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ModuleRowView: View {
    let module: ProcedureModule
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(module.title)
                        .font(.headline)
                    Spacer()
                    DifficultyBadge(difficulty: module.difficulty)
                }
                
                Text(module.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Label("\(module.steps.count) steps", systemImage: "list.bullet")
                    Spacer()
                    Label("\(module.estimatedTime) min", systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            QuickStartButton(module: module)
        }
        .padding(.vertical, 4)
    }
}

struct DifficultyBadge: View {
    let difficulty: ProcedureModule.Difficulty
    
    var color: Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

struct ModuleDetailView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(AIManager.self) private var aiManager
    let module: ProcedureModule
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                headerSection
                
                Divider()
                
                stepsSection
                
                Divider()
                
                HStack(spacing: 20) {
                    Button {
                        aiManager.initializeSystemMessage(for: module)
                        appModel.showChat.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.title3)
                            Text("Ask AI Assistant")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple.gradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .buttonStyle(.plain)
                    
                    ToggleImmersiveSpaceButton(module: module)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(40)
        }
        .overlay(alignment: .trailing) {
            if appModel.showChat {
                ChatAssistantView()
                    .padding(.trailing, 40)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appModel.showChat)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(module.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                DifficultyBadge(difficulty: module.difficulty)
            }
            
            Text(module.description)
                .font(.title3)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 30) {
                InfoItem(icon: "list.bullet", label: "Steps", value: "\(module.steps.count)")
                InfoItem(icon: "clock", label: "Duration", value: "\(module.estimatedTime) min")
                if let tooth = module.targetTooth {
                    InfoItem(icon: "tooth", label: "Target", value: "Tooth #\(tooth)")
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
        }
    }
    
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Procedure Steps")
                .font(.title2)
                .fontWeight(.semibold)
            
            ForEach(Array(module.steps.enumerated()), id: \.element.id) { index, step in
                StepCard(step: step, number: index + 1)
            }
        }
    }
}

struct InfoItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
}

struct StepCard: View {
    let step: ProcedureStep
    let number: Int
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ZStack {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 40, height: 40)
                
                Text("\(number)")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(step.instruction)
                        .font(.headline)
                    Spacer()
                    Label(step.tool.rawValue, systemImage: step.tool.iconName)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
                
                if let tip = step.tip {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                        Text(tip)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.yellow.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
    }
}

struct QuickStartButton: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    let module: ProcedureModule
    
    var body: some View {
        Button {
            Task { @MainActor in
                appModel.startProcedure(module)
                appModel.immersiveSpaceState = .inTransition
                switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
                case .opened:
                    break
                case .userCancelled, .error:
                    fallthrough
                @unknown default:
                    appModel.immersiveSpaceState = .closed
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "play.circle.fill")
                Text("Start")
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue.gradient)
            .foregroundStyle(.white)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(appModel.immersiveSpaceState != .closed)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}