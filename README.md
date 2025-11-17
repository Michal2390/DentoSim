# DentoSim – Interaktywna Symulacja Zabiegów Stomatologicznych

## I. Informacje ogólne

### Nazwa aplikacji
DentoSim XR

### Klient i Docelowy Odbiorca
- **Klient:** Firmy szkoleniowe dla stomatologów, uczelnie medyczne, kliniki stomatologiczne, producenci sprzętu dentystycznego.
- **Docelowy odbiorca:** Studenci stomatologii, młodzi lekarze, higieniści, asystenci stomatologiczni oraz osoby prowadzące szkolenia medyczne.

### Platforma Docelowa
Apple Vision (visionOS)

### Cel Aplikacji
Stworzenie realistycznego symulatora szkoleniowego w środowisku XR (Extended Reality) do nauki i doskonalenia podstawowych zabiegów stomatologicznych. Aplikacja ma na celu umożliwienie bezpiecznego i powtarzalnego ćwiczenia umiejętności manualnych bez ryzyka dla pacjenta, co przekłada się na zdobycie doświadczenia, precyzji i pewności siebie w wykonywaniu procedur medycznych.

### Uzasadnienie
DentoSim XR obniża koszty szkoleń w porównaniu do tradycyjnych fantomów, jednocześnie zwiększając bezpieczeństwo i efektywność nauki. Umożliwia ćwiczenie rzadkich lub skomplikowanych procedur w kontrolowanym środowisku. W przyszłości wsparcie ze strony asystenta LLM ma dodatkowo podnosić jakość szkolenia poprzez dostarczanie wskazówek w czasie rzeczywistym.

### Główne Ryzyka
- Zapewnienie wystarczającego poziomu realizmu symulacji.
- Ograniczenia sprzętowe urządzeń XR.
- Konieczność stałych konsultacji z ekspertami branżowymi w celu zachowania wierności medycznych procedur.

---

## II. Wygląd i Styl Aplikacji

### Dźwięk
- Realistyczne odgłosy narzędzi stomatologicznych (np. wiertła, ssaki).
- Sygnały dźwiękowe potwierdzające poprawne wykonanie interakcji.
- W przyszłości: Głosowy asystent LLM objaśniający procedury.

### Przewodni Motyw Wizualny
Aplikacja osadzona jest w wirtualnym, realistycznie odwzorowanym gabinecie stomatologicznym, aby maksymalnie przybliżyć warunki rzeczywistych zabiegów.

### Styl Wizualny
Fotorealistyczny, z naciskiem na:
- Dokładne odwzorowanie narzędzi dentystycznych.
- Szczegółowy i anatomicznie poprawny model jamy ustnej.
- Nowoczesne i intuicyjne panele UI unoszące się w przestrzeni 3D.

---

## III. Scenariusz i Mechanika

### Elementy Rozgrywki
Użytkownik wybiera jedną z dostępnych procedur (np. ekstrakcja zęba, przygotowanie ubytku), a następnie wykonuje ją krok po kroku w wirtualnym środowisku. Aplikacja może działać w dwóch trybach:
1.  **Tryb Nauki:** Z podpowiedziami i wskazówkami od asystenta.
2.  **Tryb Egzaminu:** Bez wsparcia, weryfikujący nabyte umiejętności.

### Mechanika Aplikacji
Symulacja bazuje na realistycznym operowaniu narzędziami i precyzyjnym śledzeniu ich ruchów. System ocenia kluczowe parametry, takie jak:
- Kąt pracy narzędzia.
- Siła nacisku.
- Prawidłowa sekwencja działań.

### Punktacja i Osiągnięcia
Na koniec każdej procedury użytkownik otrzymuje ocenę opartą na:
- **Dokładności:** Precyzja wykonania poszczególnych kroków.
- **Czasie:** Czas ukończenia zabiegu.
- **Liczbie błędów:** Rejestrowanie nieprawidłowych interakcji.
- **Płynności:** Efektywność w obsłudze narzędzi.

Wyniki są zapisywane, co pozwala śledzić postępy i rozwój umiejętności.

### Interfejs Użytkownika (UI)
- **Panele 3D:** Pływające w przestrzeni okna z informacjami o procedurze, statystykami i wyborem narzędzi.
- **Menu Kontekstowe:** Wywoływane za pomocą gestów, umożliwiające szybki dostęp do opcji.
- **Wskazówki Asystenta:** Wyświetlane w formie dymków informacyjnych lub (w przyszłości) komunikatów głosowych.