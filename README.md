
# Lumen Portfolio

A premium, dynamic Flutter Web portfolio.

## Feature: Dynamic Resume
The content of this portfolio can change based on the URL parameter `jobId`. This allows you to tailor your resume for specific job applications.

### How to Test
1. **Default Mode**:
   `http://localhost:port/`
   Shows the default generic profile.

2. **Senior Architect Mode**:
   `http://localhost:port/?jobId=senior-architect`
   Changes title to "Solutions Architect" and highlights Cloud/Microservices projects.

3. **UI/UX Lead Mode**:
   `http://localhost:port/?jobId=ui-ux-lead`
   Changes title to "Creative Technologist" and highlights Design projects.

## Setup Firestore (Optional for now)
Currently, `lib/services/portfolio_service.dart` is running in **Mock Mode**.
To connect to real Firestore:
1. Run `flutterfire configure` in your terminal.
2. Select your Firebase project.
3. Uncomment the Firebase initialization in `lib/main.dart`.
4. Uncomment the Firestore logic in `lib/services/portfolio_service.dart`.
