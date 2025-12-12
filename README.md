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

### Struktura Projektu: