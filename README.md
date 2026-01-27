# eye_buddy# lp

A new Flutter project.

## Getting Started

This project uses [FVM (Flutter Version Management)](https://fvm.app/) to manage Flutter SDK versions.

### Prerequisites

1. Install FVM:
   ```bash
   dart pub global activate fvm
   ```

2. Install Flutter versions:
   ```bash
   # Root project (Flutter 3.38.3)
   cd /Users/admin/Desktop/Zuraiz-workbase/flutter-projects/lp
   fvm install
   fvm use
   
   # Sub-project (Flutter 3.7.12)
   cd /Users/admin/Desktop/Zuraiz-workbase/flutter-projects/lp/bloc-code/patient
   fvm install
   fvm use
   ```

### Running the Project

Use FVM to run Flutter commands:

```bash
# Root project
cd /Users/admin/Desktop/Zuraiz-workbase/flutter-projects/lp
fvm flutter run

# Sub-project
cd /Users/admin/Desktop/Zuraiz-workbase/flutter-projects/lp/bloc-code/patient
fvm flutter run
```

### Building

```bash
# Root project
fvm flutter build apk --debug

# Sub-project
fvm flutter build apk --debug
```

## Project Structure

- **Root project**: Uses Flutter 3.38.3
- **bloc-code/patient**: Sub-project using Flutter 3.7.12

Each project has its own FVM configuration in `.fvm/fvm_config.json`.
