# TutorAI MVP

TutorAI is a Flutter MVP for the locked AI Personal Tutor concept.

## Current build
- 3D-inspired TutorAI Home UI
- Bottom navigation: Home, Learn, Practice, Progress, Profile
- Snap a Question flow
- Camera/gallery image selection via `image_picker`
- Question confirmation/edit screen
- Step-by-step tutor result screen

## Run locally
```bash
flutter pub get
flutter run
```

For a physical Android/iOS device, allow camera/photo permissions when prompted.

## Important
The current question confirmation screen intentionally uses editable text before analysis. This keeps the first build safe and testable while we prepare the real OCR + AI backend.

## Next engineering stage
1. OCR question extraction
2. Secure AI backend (Supabase Edge Function)
3. Real tutor response generation
4. Practice question generation and marking
5. Save progress to Supabase
