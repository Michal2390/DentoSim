# Nazwa Projektu: DentoSim – Interaktywna Symulacja Zabiegów Stomatologicznych

## Część I: Informacje ogólne

### Nazwa aplikacji:
DentoSim XR

### Klient:
Firmy szkoleniowe dla stomatologów, uczelnie medyczne, kliniki stomatologiczne oraz producenci sprzętu dentystycznego, którzy mogą oferować aplikację jako wartość dodaną do swoich produktów.

### Docelowy odbiorca:
- Studenci stomatologii.
- Młodzi lekarze przygotowujący się do pracy z pacjentami.
- Higieniści i asystenci stomatologiczni.
- Osoby prowadzące szkolenia medyczne.

### Docelowe urządzenia:
Apple Vision (visionOS)

### Cel aplikacji/gry:
Stworzenie realistycznego środowiska szkoleniowego w XR (Extended Reality) do symulacji podstawowych zabiegów stomatologicznych.

### Cel ogólny:
Aplikacja ma na celu umożliwienie bezpiecznego i powtarzalnego ćwiczenia umiejętności stomatologicznych bez ryzyka dla pacjenta. Dzięki temu użytkownicy mogą nabywać doświadczenie, precyzję oraz pewność siebie w wykonywaniu procedur medycznych w kontrolowanym środowisku.

### Uzasadnienie:
Aplikacja obniża koszty szkoleń w porównaniu do tradycyjnych fantomów, jednocześnie zwiększając bezpieczeństwo i efektywność nauki przed rozpoczęciem realnej praktyki. Umożliwia ćwiczenie rzadkich lub skomplikowanych procedur. W przyszłości wsparcie ze strony asystenta LLM ma dodatkowo podnosić jakość szkolenia poprzez dostarczanie wskazówek w czasie rzeczywistym.

### Ryzyka wdrażania rozwiązania:
- Zapewnienie wystarczającego poziomu realizmu symulacji.
- Ograniczenia sprzętowe urządzeń XR.
- Konieczność stałych konsultacji z ekspertami branżowymi w celu zachowania wierności medycznych procedur.

---

## Część II: Aspekt wyglądu docelowego rozwiązania

### Dźwięk:
- Realistyczne odgłosy narzędzi stomatologicznych (np. wiertła, ssaki).
- Sygnały dźwiękowe potwierdzające poprawne wykonanie interakcji.
- W przyszłości: Głosowy asystent LLM objaśniający procedury krok po kroku.

### Przewodni temat wizualny:
Wirtualny, profesjonalny gabinet stomatologiczny, zaprojektowany tak, aby jak najwierniej odwzorować rzeczywiste warunki pracy.

### Styl wizualny:
Fotorealistyczny, z naciskiem na:
- Dokładne odwzorowanie narzędzi dentystycznych.
- Szczegółowy i anatomicznie poprawny model jamy ustnej.
- Nowoczesne i intuicyjne panele UI unoszące się w przestrzeni 3D.
Wizualnie aplikacja może przypominać profesjonalne symulatory chirurgiczne, takie jak „Touch Surgery VR".

---

## Część III: Scenariusz/Gameplay

### Elementy rozgrywki jeśli dotyczy:
Użytkownik wybiera jedną z dostępnych procedur stomatologicznych (np. wyrywanie zęba) i wykonuje ją w realistycznym środowisku. Aplikacja oferuje dwa główne tryby:
1.  **Tryb Nauki:** Z podpowiedziami i wsparciem asystenta LLM. Drugi użytkownik może dołączyć jako instruktor, aby obserwować i na bieżąco udzielać wskazówek.
2.  **Tryb Egzaminu:** Samodzielne wykonanie procedury bez wsparcia. W tym trybie instruktor (np. profesor) może dołączyć do sesji jako obserwator, aby ocenić pracę studenta. W obu tych przypadkach w jednej sesji może brać udział dwóch użytkowników jednocześnie.

### Mechanika gry/aplikacji:
Symulacja opiera się na realistycznym operowaniu narzędziami dentystycznymi i reagującą na działania użytkownika. System rejestruje błędy, np. zbyt mocny nacisk lub niewłaściwy kąt pracy, a aplikacja może działać zarówno w trybie nauki z podpowiedziami LLM, jak i w trybie bez wsparcia.

### Punktacje/osiągnięcia:
Ocena użytkownika obejmuje dokładność wykonania procedury, czas, liczbę błędów oraz płynność obsługi narzędzi, a wyniki przekładają się na rosnący poziom doświadczenia.

### Mechanika interfejsu użytkownika:
- **Panele 3D:** Pływające w przestrzeni okna z informacjami o procedurze, statystykami i wyborem narzędzi.
- **Menu Kontekstowe:** Wywoływane za pomocą gestów, umożliwiające szybki dostęp do opcji.
- **Wskazówki Asystenta:** Wyświetlane w formie dymków informacyjnych lub (w przyszłości) komunikatów głosowych.

### Sposób nawigacji,
- Nawigacja opiera się na naturalnych gestach visionOS: użytkownik wskazuje palcem element interfejsu i zatwierdza wybór lekkim „szczypnięciem".
- Pozycjonowanie wirtualnego gabinetu odbywa się poprzez ruch głowy i ciała.

---

## Część IV: Architektura Techniczna

### Stack Technologiczny:

#### Główne Technologie:
- **visionOS** – system operacyjny Apple Vision Pro
- **SwiftUI** – framework do budowy interfejsu użytkownika
- **RealityKit** – framework do renderowania i interakcji z obiektami 3D
- **Swift Concurrency** – async/await dla asynchronicznych operacji
- **Observation Framework** (@Observable) – nowoczesny system reaktywny zastępujący ObservableObject

#### Integracja AI:
- **OpenAI API (GPT-4)** – asystent AI do wsparcia podczas procedur
- **RESTful HTTP Communication** – komunikacja z zewnętrznymi serwisami AI

### Tworzenie sceny:

Poniżej opis jak scena 3D jest budowana w visionOS oraz jak zrealizowano interakcję z obiektami.

1) RealityView jako kontener sceny 3D
- Scena jest renderowana w ImmersiveView przy pomocy RealityView z trzema blokami:
  - content: jednorazowa inicjalizacja sceny (tworzenie Entity i dodanie do content)
  - update: reakcja na zmiany stanu (@Observable) i bieżące aktualizacje wyglądu
  - attachments: generowanie i wstrzykiwanie paneli SwiftUI jako obiekty 3D

\`\`\`
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
\`\`\`

2) Budowa modelu szczęki i zębów
- createJawModel tworzy nadrzędny Entity z dwiema gałęziami: UpperArch i LowerArch.
- createArchEntity w pętli tworzy ToothEntity dla każdego numeru zęba.
- ToothFactory ładuje modele USDZ (lub fallback proceduralny), nakłada materiały PBR i tworzy ToothEntity (crown + root).
- Pozycje i orientacje zębów wyznacza algorytm łuku zębowego (U-shape) w toothPosition(...).

\`\`\`
let upperJaw = await createArchEntity(isUpper: true)
let lowerJaw = await createArchEntity(isUpper: false)
arch.addChild(tooth) // dla każdego numeru
let def = ToothFactory.definition(for: number, in: appModel.sessionData.currentModule)
let tooth = await ToothFactory.makeToothEntity(definition: def)
let p = toothPosition(for: number, isUpper: isUpper)
tooth.position = p.position
tooth.orientation = p.rotation
\`\`\`

3) Interakcja: komponenty, gesty i przebieg zdarzeń
- Każdy ToothEntity posiada:
  - InputTargetComponent (możliwość targetowania gestami)
  - CollisionComponent (generowany z mesha korony/korzeni; fallback: box)
  - PhysicsBodyComponent(mode: .static) do poprawnej kolizji/raycastu

\`\`\`
components.set(InputTargetComponent())
components.set(CollisionComponent(shapes: shapes))
physicsBody = PhysicsBodyComponent(mode: .static)
\`\`\`

- Gest: SpatialTapGesture.targetedToAnyEntity() wiązany do RealityView.
- Po tapnięciu wykonujemy traversal od klikniętego Entity w górę hierarchii, aż znajdziemy ToothEntity.

\`\`\`
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
\`\`\`

4) Logika narzędzi i stanów (InteractionSystem)
- Walidacja: właściwe narzędzie, właściwy ząb, właściwa sekwencja.
- Modyfikacja stanu zęba: condition, workProgress.
- Zwrot wyniku InteractionResult: .success, .wrongTool, .inProgress(progress), .extracted, itp.

\`\`\`
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
\`\`\`

5) Wizualny feedback i aktualizacje wyglądu
- updateToothAppearance nadaje materiały/skalę/pozycję w zależności od ToothCondition.
- Animacje w ImmersiveView:
  - Sukces: krótkie powiększenie i powrót (pulse)
  - Błąd: szybkie przesunięcia lewo/prawo (shake)
  - Postęp: rozjaśnianie materia