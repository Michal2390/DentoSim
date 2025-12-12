
# Project Name: DentoSim – Interactive Dental Procedure Simulation

## Part I: General Information

### Application Name:

DentoSim XR

### Client:

Dental training companies, medical universities, dental clinics, and dental equipment manufacturers who can offer the application as value-added content for their products.

### Target Audience:

  - Dentistry students.
  - Junior doctors preparing to work with patients.
  - Hygienists and dental assistants.
  - Medical training instructors.

### Target Devices:

Apple Vision (visionOS)

### App/Game Goal:

To create a realistic training environment in XR (Extended Reality) for simulating basic dental procedures.

### General Objective:

The application aims to enable safe and repeatable practice of dental skills without risk to patients. This allows users to gain experience, precision, and confidence in performing medical procedures in a controlled environment.

### Rationale:

The application reduces training costs compared to traditional phantoms while increasing safety and learning efficiency before starting real practice. It enables the practice of rare or complex procedures. In the future, support from an LLM assistant will further enhance training quality by providing real-time guidance.

### Implementation Risks:

  - Ensuring a sufficient level of simulation realism.
  - Hardware limitations of XR devices.
  - The need for constant consultation with industry experts to maintain the fidelity of medical procedures.

-----

## Part II: Visual & Audio Aspects

### Audio:

  - Realistic sounds of dental tools (e.g., drills, suction).
  - Audio cues confirming correct interaction execution.
  - Future: Voice LLM assistant explaining procedures step-by-step.

### Visual Theme:

A virtual, professional dental office, designed to replicate real working conditions as faithfully as possible.

### Visual Style:

Photorealistic, with an emphasis on:

  - Accurate representation of dental tools.
  - A detailed and anatomically correct model of the oral cavity.
  - Modern and intuitive UI panels floating in 3D space.
    Visually, the application may resemble professional surgical simulators like "Touch Surgery VR".

-----

## Part III: Scenario/Gameplay

### Gameplay Elements:

The user selects one of the available dental procedures (e.g., tooth extraction) and performs it in a realistic environment. The application offers two main modes:

1.  **Learning Mode:** With hints and LLM assistant support. A second user can join as an instructor to observe and provide real-time guidance.
2.  **Exam Mode:** Independent execution of the procedure without support. In this mode, an instructor (e.g., a professor) can join the session as an observer to grade the student's work. In both cases, two users can participate in a single session simultaneously.

### Game/App Mechanics:

The simulation is based on the realistic operation of dental tools that react to user actions. The system registers errors, such as excessive pressure or an incorrect working angle. The application can function both in learning mode with LLM prompts and in a support-free mode.

### Scoring/Achievements:

User assessment includes procedure accuracy, time, error count, and tool handling fluency. Results translate into increasing experience levels.

### UI Mechanics:

  - **3D Panels:** Windows floating in space containing procedure information, statistics, and tool selection.
  - **Context Menu:** Triggered by gestures, allowing quick access to options.
  - **Assistant Hints:** Displayed as information bubbles or (in the future) voice messages.

### Navigation Method:

  - Navigation relies on natural visionOS gestures: the user points a finger at a UI element and confirms the selection with a light "pinch."
  - Positioning within the virtual office is done through head and body movement.

-----

## Part IV: Technical Architecture

### Tech Stack:

#### Core Technologies:

  - **visionOS** – Apple Vision Pro operating system
  - **SwiftUI** – Framework for building the user interface
  - **RealityKit** – Framework for rendering and interacting with 3D objects
  - **Swift Concurrency** – async/await for asynchronous operations
  - **Observation Framework** (@Observable) – Modern reactive system replacing ObservableObject

#### AI Integration:

  - **OpenAI API (GPT-4)** – AI assistant for procedure support
  - **RESTful HTTP Communication** – Communication with external AI services

### Scene Creation:

Below is a description of how the 3D scene is built in visionOS and how object interaction is implemented.

1)  **RealityView as the 3D Scene Container**

<!-- end list -->

  - The scene is rendered in an `ImmersiveView` using `RealityView` with three blocks:
      - `content`: One-time scene initialization (creating Entities and adding them to content).
      - `update`: Reaction to state changes (`@Observable`) and current visual updates.
      - `attachments`: Generating and injecting SwiftUI panels as 3D objects.

<!-- end list -->

```swift
RealityView { content, attachments in
    let jawEntity = await createJawModel()
    jawEntity.position = [0, 1.5, -0.8]
    jawEntity.orientation = simd_quatf(angle: .pi/24, axis: [1,0,0])
    content.add(jawEntity)

    if let sessionPanel = attachments.entity(for: "sessionPanel") {
        sessionPanel.position = [-50, 50, -50]
        content.add(sessionPanel)
    }
} update: { content, attachments in
    updateToothHighlights()
    if let chat = attachments.entity(for: "chatPanel") {
        chat.isEnabled = appModel.showChat
    }
} attachments: {
    Attachment(id: "sessionPanel") { SessionInfoPanel() }
    Attachment(id: "chatPanel") { CompactChatPanel() }
    Attachment(id: "toolPalette") { ToolPalette() }
}
```

2)  **Building the Jaw and Teeth Model**

<!-- end list -->

  - `createJawModel` creates a parent Entity with two branches: `UpperArch` and `LowerArch`.
  - `createArchEntity` loops to create a `ToothEntity` for each tooth number.
  - `ToothFactory` loads USDZ models (or a procedural fallback), applies PBR materials, and creates the `ToothEntity` (crown + root).
  - Tooth positions and orientations are determined by a dental arch algorithm (U-shape) in `toothPosition(...)`.

<!-- end list -->

```swift
let upperJaw = await createArchEntity(isUpper: true)
let lowerJaw = await createArchEntity(isUpper: false)
arch.addChild(tooth) // for each number
let def = ToothFactory.definition(for: number, in: appModel.sessionData.currentModule)
let tooth = await ToothFactory.makeToothEntity(definition: def)
let p = toothPosition(for: number, isUpper: isUpper)
tooth.position = p.position
tooth.orientation = p.rotation
```

3)  **Interaction: Components, Gestures, and Event Flow**

<!-- end list -->

  - Each `ToothEntity` possesses:
      - `InputTargetComponent` (enables gesture targeting)
      - `CollisionComponent` (generated from crown/root mesh; fallback: box)
      - `PhysicsBodyComponent(mode: .static)` for correct collision/raycasting

<!-- end list -->

```swift
components.set(InputTargetComponent())
components.set(CollisionComponent(shapes: shapes))
physicsBody = PhysicsBodyComponent(mode: .static)
```

  - Gesture: `SpatialTapGesture.targetedToAnyEntity()` bound to the `RealityView`.
  - Upon tapping, we perform traversal from the clicked Entity up the hierarchy until the `ToothEntity` is found.

<!-- end list -->

```swift
.gesture(
    SpatialTapGesture()
        .targetedToAnyEntity()
        .onEnded { value in handleTap(on: value.entity) }
)

private func handleTap(on entity: Entity) {
    var e: Entity? = entity
    var tooth: ToothEntity?
    while e != nil {
        if let t = e as? ToothEntity { tooth = t; break }
        e = e?.parent
    }
    guard let tooth else { return }
    appModel.selectedToothID = tooth.toothNumber
    let result = InteractionSystem.handleToolInteraction(
        tooth: tooth,
        tool: appModel.selectedTool,
        currentStep: appModel.sessionData.currentStep,
        appModel: appModel
    )
    handleInteractionResult(result, tooth: tooth)
}
```

4)  **Tool Logic and States (InteractionSystem)**

<!-- end list -->

  - Validation: Correct tool, correct tooth, correct sequence.
  - Tooth state modification: `condition`, `workProgress`.
  - Return `InteractionResult`: `.success`, `.wrongTool`, `.inProgress(progress)`, `.extracted`, etc.

<!-- end list -->

```swift
switch tool {
case .elevator:
    tooth.workProgress += 0.34
    if tooth.workProgress >= 1.0 {
        tooth.condition = .loosened
        appModel.completeCurrentStep()
        tooth.workProgress = 0
        return .success
    }
    return .inProgress(tooth.workProgress)
case .forceps:
    guard tooth.condition == .loosened else { return .wrongSequence }
    tooth.workProgress += 0.5
    if tooth.workProgress >= 1.0 {
        tooth.condition = .extracted
        appModel.completeCurrentStep()
        tooth.workProgress = 0
        return .extracted
    }
    return .inProgress(tooth.workProgress)
default: break
}
```

5)  **Visual Feedback and Appearance Updates**

<!-- end list -->





  - `updateToothAppearance` applies materials/scale/position depending on `ToothCondition`.
  - Animations in `ImmersiveView`:
      - Success: Brief expansion and return (pulse).
      - Error: Rapid left/right movement (shake).
      - Progress: Material brightening.
