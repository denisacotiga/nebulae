import SwiftUI

struct Project: Identifiable, Hashable {
    let id: UUID
    let name: String
    let engineeringField: String
    let currentStage: String
    let dateCreated: Date
    var lastUpdated: Date
}

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

struct HomeView: View {
    @State private var projects: [Project] = []
    @State private var isShowingCreateProject = false
    @State private var projectBeingEdited: Project?
    @State private var searchText = ""
    @State private var navigationPath: [Project] = []

    private var filteredProjects: [Project] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return projects
        }

        return projects.filter { project in
            project.name.localizedCaseInsensitiveContains(searchText)
            || project.engineeringField.localizedCaseInsensitiveContains(searchText)
            || project.currentStage.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        headerView
                            .padding(.horizontal, 24)

                        if projects.isEmpty {
                            emptyStateView
                                .padding(.horizontal, 24)
                        } else {
                            projectsView
                        }
                    }
                    .padding(.top, 35)
                    .padding(.bottom, 96)
                }

                bottomTabBar
            }
            .sheet(isPresented: $isShowingCreateProject) {
                CreateProjectSheetView { project in
                    projects.append(project)
                }
                .presentationDetents([.height(640), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.thickMaterial)
                .presentationContentInteraction(.scrolls)
            }
            .sheet(item: $projectBeingEdited) { project in
                CreateProjectSheetView(projectToEdit: project) { updatedProject in
                    if let index = projects.firstIndex(where: { $0.id == updatedProject.id }) {
                        projects[index] = updatedProject
                    }
                }
                .presentationDetents([.height(640), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.thickMaterial)
                .presentationContentInteraction(.scrolls)
            }
            .navigationDestination(for: Project.self) { project in
                ProjectDashboardView(project: project)
            }
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Nebulae")
                    .font(.custom("TimesNewRomanPS-BoldMT", size: 40))
                    .foregroundStyle(Color(red: 0.20, green: 0.20, blue: 0.20))
                    .shadow(color: Color(red: 0.20, green: 0.20, blue: 0.20), radius: 0, x: 0.5, y: 0)
                    .shadow(color: Color(red: 0.20, green: 0.20, blue: 0.20), radius: 0, x: -0.5, y: 0)

                Text("Your Engineering Portfolio")
                    .font(.custom("Helvetica Neue", size: 20))
                    .foregroundStyle(Color(red: 0.3, green: 0.3, blue: 0.3))
            }

            Spacer()

            Button(action: {
                isShowingCreateProject = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(0.25))
                        .frame(width: 58, height: 58)

                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.black)
                }
            }
        }
    }

    private var emptyStateView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.cyan.opacity(0.07))

            VStack(spacing: 14) {
                Image("Nebulae Logo 1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .offset(y: -20)
                    .offset(x: -7.35)

                Text("Welcome to Nebulae")
                    .font(.custom("ArialRoundedMTBold", size: 26))
                    .offset(y: -13)

                Text("Start documenting your engineering journey.")
                    .font(.custom("HelveticaNeue", size: 19.35))
                    .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .offset(y: -8.5)

                Button(action: {
                    isShowingCreateProject = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus")
                        Text("Create Your First Project")
                            .fontWeight(.semibold)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 22)
                    .background(Color.cyan.opacity(0.30))
                    .foregroundStyle(.black)
                    .cornerRadius(14)
                    .offset(y: 5)
                }
            }
            .offset(y: -30)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 655)
    }

    private var projectsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Your Projects")
                    .font(.system(size: 28, weight: .bold))

                Text("Track, build, and showcase your ideas.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(red: 0.35, green: 0.35, blue: 0.35))
            }

            HStack(spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.secondary)

                    TextField("Search projects...", text: $searchText)
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(Color.white.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                )

                Button(action: {}) {
                    HStack(spacing: 7) {
                        Image(systemName: "line.3.horizontal.decrease")
                        Text("Filter")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 96, height: 48)
                    .background(Color.white.opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                    )
                }
            }

            Text("\(filteredProjects.count) \(filteredProjects.count == 1 ? "Project" : "Projects")")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.blue)

            VStack(spacing: 14) {
                ForEach(filteredProjects) { project in
                    ProjectCardView(
                        project: project,
                        onOpen: {
                            navigationPath.append(project)
                        },
                        onEdit: {
                            projectBeingEdited = project
                        },
                        onDelete: {
                            projects.removeAll { $0.id == project.id }
                            navigationPath.removeAll { $0.id == project.id }
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cyan.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal, 4)
    }

    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            TabBarButton(title: "Home", icon: "house.fill", isSelected: true)
            TabBarButton(title: "Projects", icon: "folder", isSelected: false)
            TabBarButton(title: "Build Logs", icon: "book.closed", isSelected: false)
            TabBarButton(title: "Analytics", icon: "chart.line.uptrend.xyaxis", isSelected: false)
            TabBarButton(title: "Profile", icon: "person", isSelected: false)
        }
        .padding(.horizontal, 12)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
    }
}

struct ProjectCardView: View {
    let project: Project
    let onOpen: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: 10) {
                Button(action: {}) {
                    VStack(spacing: 5) {
                        Image(systemName: stageIcon(for: project.currentStage))
                            .font(.system(size: 25, weight: .medium))
                        Text("Add\nImage/Icon")
                            .font(.system(size: 10, weight: .semibold))
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(Color.cyan.opacity(0.95))
                    .frame(width: 86, height: 86)
                    .background(Color.cyan.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(project.name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)

                            HStack(spacing: 7) {
                                Image(systemName: "square.stack.3d.up")
                                    .font(.system(size: 14, weight: .semibold))
                                Text(project.engineeringField)
                                    .font(.system(size: 12, weight: .medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.82)
                            }
                            .foregroundStyle(.blue)
                        }

                        Spacer()

                        Menu {
                            Button("Edit", action: onEdit)
                            Button("Delete Project", role: .destructive, action: onDelete)
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.secondary)
                                .frame(width: 22, height: 24)
                        }
                    }

                    Spacer()

                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: stageIcon(for: project.currentStage))
                                .font(.system(size: 12, weight: .semibold))
                            Text(project.currentStage)
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .foregroundStyle(stageColor(for: project.currentStage))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                        .background(stageColor(for: project.currentStage).opacity(0.14))
                        .clipShape(Capsule())

                        Spacer()

                        TimelineView(.periodic(from: .now, by: 60)) { timeline in
                            Text("Updated \(relativeTime(from: project.lastUpdated, to: timeline.date))")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }

                        Button(action: onOpen) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.black)
                                .frame(width: 20, height: 24)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(13)
            .frame(maxWidth: .infinity)
            .frame(height: 132)
            .background(Color.white.opacity(0.94))
            .clipShape(RoundedRectangle(cornerRadius: 17))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private func relativeTime(from date: Date, to currentDate: Date) -> String {
        let seconds = max(0, Int(currentDate.timeIntervalSince(date)))

        if seconds < 60 {
            return "Just now"
        }

        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes)m ago"
        }

        let hours = minutes / 60
        if hours < 24 {
            return "\(hours)h ago"
        }

        let days = hours / 24
        return "\(days)d ago"
    }

    private func stageIcon(for stage: String) -> String {
        switch stage {
        case "Idea":
            return "lightbulb"
        case "Research":
            return "magnifyingglass"
        case "Design":
            return "pencil"
        case "Prototype":
            return "wrench.and.screwdriver"
        case "Testing":
            return "flask"
        case "Completed":
            return "flag.checkered"
        default:
            return "folder"
        }
    }

    private func stageColor(for stage: String) -> Color {
        switch stage {
        case "Idea":
            return .cyan
        case "Research":
            return .orange
        case "Design":
            return .purple
        case "Prototype":
            return .green
        case "Testing":
            return .blue
        case "Completed":
            return .gray
        default:
            return .cyan
        }
    }
}

struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool

    var body: some View {
        Button(action: {}) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 23, weight: .semibold))
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(isSelected ? Color.cyan : Color(red: 0.35, green: 0.35, blue: 0.35))
            .frame(maxWidth: .infinity)
        }
    }
}

struct CreateProjectSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var projectName = ""
    @State private var engineeringField = ""
    @State private var selectedStage = "Idea"
    @State private var isShowingFieldOptions = false
    @State private var isShowingOtherFieldPrompt = false
    @State private var customEngineeringField = ""
    @State private var validationMessage = ""

    private let projectToEdit: Project?
    private let onSaveProject: (Project) -> Void

    init(projectToEdit: Project? = nil, onSaveProject: @escaping (Project) -> Void) {
        self.projectToEdit = projectToEdit
        self.onSaveProject = onSaveProject
        _projectName = State(initialValue: projectToEdit?.name ?? "")
        _engineeringField = State(initialValue: projectToEdit?.engineeringField ?? "")
        _selectedStage = State(initialValue: projectToEdit?.currentStage ?? "Idea")
    }

    private let engineeringFields = [
        "Aerospace Engineering",
        "Biomedical Engineering",
        "Chemical Engineering",
        "Civil Engineering",
        "Computer Science / Software",
        "Electrical Engineering",
        "Environmental Engineering",
        "Mechanical Engineering",
        "Research Project",
        "Robotics",
        "Other"
    ]
    private let stages = [
        ProjectStage(name: "Idea", icon: "lightbulb"),
        ProjectStage(name: "Research", icon: "magnifyingglass"),
        ProjectStage(name: "Design", icon: "pencil"),
        ProjectStage(name: "Prototype", icon: "wrench.and.screwdriver"),
        ProjectStage(name: "Testing", icon: "flask"),
        ProjectStage(name: "Completed", icon: "flag.checkered")
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(projectToEdit == nil ? "Create Project" : "Edit Project")
                        .font(.system(size: 26, weight: .bold))

                    Text(projectToEdit == nil ? "Let's set up your new project." : "Update your project details.")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(red: 0.35, green: 0.35, blue: 0.35))
                }
                .offset(y: 9)

                Spacer()

                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Project Name")
                    .font(.system(size: 17, weight: .bold))
                    .offset(y: 4.75)

                HStack(spacing: 14) {
                    Image(systemName: "folder")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.blue)

                    TextField("Enter project name", text: $projectName)
                        .font(.system(size: 18))
                        .onChange(of: projectName) { _, _ in
                            validationMessage = ""
                        }
                }
                .padding(.horizontal, 18)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1.5)
                )
                .offset(y: 5)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Engineering Field")
                    .font(.system(size: 17, weight: .bold))

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isShowingFieldOptions.toggle()
                    }
                }) {
                    HStack(spacing: 14) {
                        Image(systemName: "square.stack.3d.up")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.blue)

                        Text(engineeringField.isEmpty ? "Select field" : engineeringField)
                            .font(.system(size: 16))
                            .foregroundStyle(engineeringField.isEmpty ? .secondary : .primary)
                            .lineLimit(1)

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .rotationEffect(.degrees(isShowingFieldOptions ? 180 : 0))
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1.5)
                    )
                }

                if isShowingFieldOptions {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(engineeringFields, id: \.self) { field in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.18)) {
                                        isShowingFieldOptions = false
                                        if field == "Other" {
                                            customEngineeringField = ""
                                            isShowingOtherFieldPrompt = true
                                        } else {
                                            engineeringField = field
                                            validationMessage = ""
                                            isShowingOtherFieldPrompt = false
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text(field)
                                            .font(.system(size: 15))
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)

                                        Spacer()

                                        if engineeringField == field {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(height: 42)
                                }
                            }
                        }
                    }
                    .frame(height: 210)
                    .scrollIndicators(.visible)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.92))
                            .stroke(Color.gray.opacity(0.20), lineWidth: 1)
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Current Stage")
                    .font(.system(size: 17, weight: .bold))

                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(stages) { stage in
                        Button(action: {
                            selectedStage = stage.name
                        }) {
                            VStack(spacing: 10) {
                                Image(systemName: stage.icon)
                                    .font(.system(size: 30, weight: .medium))

                                Text(stage.name)
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .foregroundStyle(selectedStage == stage.name ? .blue : .black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(selectedStage == stage.name ? Color.cyan.opacity(0.12) : Color.white)
                                    .stroke(selectedStage == stage.name ? Color.cyan.opacity(0.55) : Color.gray.opacity(0.20), lineWidth: 1.5)
                            )
                        }
                    }
                }
            }

            if !validationMessage.isEmpty {
                Text(validationMessage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.red)
            }

            Button(action: saveProject) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                    Text(projectToEdit == nil ? "Create Project" : "Save Changes")
                        .fontWeight(.bold)
                }
                .font(.system(size: 20))
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Color.cyan.opacity(0.40))
                .foregroundStyle(.black)
                .cornerRadius(18)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 30)
        .padding(.top, 28)
        .sheet(isPresented: $isShowingOtherFieldPrompt) {
            CustomFieldSheetView(
                engineeringField: $engineeringField,
                customEngineeringField: $customEngineeringField
            )
            .presentationDetents([.height(360)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
            .presentationBackground(.thickMaterial)
        }
    }

    private func saveProject() {
        let trimmedName = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedField = engineeringField.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            validationMessage = "Enter a project name."
            return
        }

        guard !trimmedField.isEmpty else {
            validationMessage = "Select an engineering field."
            return
        }

        let project = Project(
            id: projectToEdit?.id ?? UUID(),
            name: trimmedName,
            engineeringField: trimmedField,
            currentStage: selectedStage,
            dateCreated: projectToEdit?.dateCreated ?? Date(),
            lastUpdated: Date()
        )

        onSaveProject(project)
        dismiss()
    }
}

struct CustomFieldSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var engineeringField: String
    @Binding var customEngineeringField: String
    @State private var shouldKeepOther = true

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Custom Field")
                    .font(.system(size: 24, weight: .bold))

                Text("How should we categorize this project?")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 0.35, green: 0.35, blue: 0.35))
            }

            Button(action: {
                shouldKeepOther = true
                customEngineeringField = ""
            }) {
                HStack(spacing: 14) {
                    Image(systemName: shouldKeepOther ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(shouldKeepOther ? .blue : .gray)

                    Text("Keep as Other")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.black)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.45), lineWidth: 1.5)
                )
            }

            TextField("Enter custom field", text: $customEngineeringField)
                .font(.system(size: 17, weight: .bold))
                .padding(.horizontal, 16)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.45), lineWidth: 1.5)
                )
                .onChange(of: customEngineeringField) { _, newValue in
                    shouldKeepOther = newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }

            Button(action: {
                let trimmedField = customEngineeringField.trimmingCharacters(in: .whitespacesAndNewlines)
                engineeringField = shouldKeepOther || trimmedField.isEmpty ? "Other" : trimmedField
                dismiss()
            }) {
                Text("Save")
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .background(Color.cyan.opacity(0.45))
                    .foregroundStyle(.black)
                    .cornerRadius(18)
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 28)
    }
}

struct ProjectDashboardView: View {
    let project: Project

    private let sections = [
        "Overview",
        "Research",
        "Requirements",
        "Build Logs",
        "Testing",
        "Resources",
        "Portfolio"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(project.name)
                    .font(.system(size: 32, weight: .bold))

                Text(project.engineeringField)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.blue)

                Text("Current Stage: \(project.currentStage)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(sections, id: \.self) { section in
                    Button(action: {}) {
                        Text(section)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 72)
                            .background(Color.cyan.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }

            Spacer()
        }
        .padding(24)
        .navigationTitle("Project")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProjectStage: Identifiable {
    let name: String
    let icon: String

    var id: String { name }
}

#Preview {
    ContentView()
}
