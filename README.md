# Nebulae

**Your Engineering Portfolio.**

Nebulae is a SwiftUI iOS app for documenting, tracking, and showcasing personal engineering projects. Capture an idea, move it through the stages of research, design, prototyping, and testing, and keep a living portfolio of everything you've built.

## About

Engineers — whether students, hobbyists, or professionals — often work on dozens of projects across very different disciplines. Nebulae is a single home for that work: a structured way to log what you're building, where each project is in its lifecycle, and how it's evolving over time.

## Features

- **Project creation** — Name a project, assign it an engineering field, and pick its current stage.
- **Lifecycle tracking** — Move projects through six stages: Idea, Research, Design, Prototype, Testing, and Completed. Each stage has its own icon and color so progress is visible at a glance.
- **Multi-discipline support** — Choose from 11 engineering fields or define a custom one.
- **Live search** — Filter projects by name, field, or stage as you type.
- **Edit and delete** — Update or remove projects directly from the project card menu.
- **Relative timestamps** — Cards show "Updated Xm ago" and refresh automatically.
- **Project dashboard** — Each project opens to a dedicated dashboard with sections for Overview, Research, Requirements, Build Logs, Testing, Resources, and Portfolio.

## Engineering Fields

- Aerospace Engineering
- Biomedical Engineering
- Chemical Engineering
- Civil Engineering
- Computer Science / Software
- Electrical Engineering
- Environmental Engineering
- Mechanical Engineering
- Research Project
- Robotics
- Other (custom)

## Project Stages

| Stage      | Meaning                                       |
| ---------- | --------------------------------------------- |
| Idea       | Initial concept or spark                      |
| Research   | Gathering information and references          |
| Design     | Planning, sketches, schematics, architecture  |
| Prototype  | Building the first working version            |
| Testing    | Validation, iteration, and refinement         |
| Completed  | Project finished or shipped                   |

## Tech Stack

- **SwiftUI** — declarative UI, navigation, and sheets
- **SwiftData** — model container scaffolded for upcoming persistence
- **iOS** — targets recent versions of iOS

## Getting Started

### Requirements

- macOS with Xcode 16 or later
- An iOS Simulator or a physical iOS device

### Run locally

1. Clone the repository:
   ```bash
   git clone https://github.com/denisacotiga/nebulae.git
   cd nebulae
   ```
2. Open `Nebulae.xcodeproj` (or the workspace) in Xcode.
3. Select an iOS Simulator or a connected device.
4. Press **⌘R** to build and run.

## Project Status

Nebulae is in **active early development**. The core project-management flow (create, edit, delete, search) is working end-to-end. The following are scaffolded and on the near-term roadmap:

- Persisting projects with SwiftData so they survive app restarts
- Wiring up the Projects, Build Logs, Analytics, and Profile tabs
- Filling in the project dashboard sections (Overview, Research, Requirements, Build Logs, Testing, Resources, Portfolio)
- Custom project images and icons
- Filter controls on the home screen

## Author

Built by **Denisa Cotiga**.

## License

This project does not currently have a license. All rights reserved by the author.
