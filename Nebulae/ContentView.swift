import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct Project: Identifiable, Hashable {
    let id: UUID
    let name: String
    let engineeringField: String
    let currentStage: String
    let dateCreated: Date
    var lastUpdated: Date
    var imageData: Data? = nil
    var iconSystemName: String? = nil
}

struct IconCategory: Identifiable {
    let id = UUID()
    let name: String
    let symbols: [String]
}

let nebulaeIconCatalog: [IconCategory] = [
    IconCategory(name: "Suggested", symbols: [
        "antenna.radiowaves.left.and.right", "bolt.fill", "cpu", "wifi"
    ]),
    IconCategory(name: "Aerospace", symbols: [
        "airplane", "paperplane.fill", "antenna.radiowaves.left.and.right",
        "globe.americas.fill", "sparkles", "moon.stars.fill"
    ]),
    IconCategory(name: "Electrical", symbols: [
        "bolt.fill", "battery.100", "cpu", "powerplug.fill", "memorychip", "lightbulb.fill"
    ]),
    IconCategory(name: "Mechanical", symbols: [
        "gearshape.fill", "wrench.and.screwdriver.fill", "gauge.medium",
        "car.fill", "hammer.fill", "wrench.fill"
    ]),
    IconCategory(name: "Biomedical", symbols: [
        "heart.fill", "cross.case.fill", "stethoscope",
        "pill.fill", "cross.fill", "waveform.path.ecg"
    ]),
    IconCategory(name: "Chemical", symbols: [
        "flask.fill", "drop.fill", "atom", "leaf.fill", "thermometer", "testtube.2"
    ]),
    IconCategory(name: "Civil", symbols: [
        "building.2.fill", "road.lanes", "hammer.fill",
        "house.fill", "ruler.fill", "building.columns.fill"
    ]),
    IconCategory(name: "Computer Science", symbols: [
        "laptopcomputer", "keyboard", "terminal.fill",
        "network", "chevron.left.forwardslash.chevron.right", "desktopcomputer"
    ]),
    IconCategory(name: "Environmental", symbols: [
        "leaf.fill", "drop.fill", "wind", "sun.max.fill", "tornado", "tree.fill"
    ]),
    IconCategory(name: "Robotics", symbols: [
        "gearshape.2.fill", "cpu", "antenna.radiowaves.left.and.right",
        "sensor.fill", "wave.3.forward", "fan.fill"
    ]),
    IconCategory(name: "Research", symbols: [
        "magnifyingglass", "doc.text.fill", "chart.bar.fill",
        "book.fill", "lightbulb.fill", "graduationcap.fill"
    ])
]

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
                    .tracking(1.2)
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
                .font(.system(size: 15, weight: .medium))
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
                        },
                        onImageSelected: { data in
                            if let index = projects.firstIndex(where: { $0.id == project.id }) {
                                projects[index].imageData = data
                                projects[index].iconSystemName = nil
                            }
                        },
                        onIconSelected: { symbol in
                            if let index = projects.firstIndex(where: { $0.id == project.id }) {
                                projects[index].iconSystemName = symbol
                                projects[index].imageData = nil
                            }
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
    let onImageSelected: (Data) -> Void
    let onIconSelected: (String) -> Void

    @State private var isShowingAddImageSheet = false
    @State private var isShowingPhotosPicker = false
    @State private var isShowingCamera = false
    @State private var isShowingFilePicker = false
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var pendingPickerAction: PickerAction?

    enum PickerAction {
        case photoLibrary, camera, file
    }

    var body: some View {
        Button(action: onOpen) {
            HStack(alignment: .center, spacing: 12) {
                Button(action: {
                    isShowingAddImageSheet = true
                }) {
                    Group {
                        if let symbolName = project.iconSystemName {
                            Image(systemName: symbolName)
                                .font(.system(size: 36, weight: .medium))
                                .foregroundStyle(Color(red: 0.06, green: 0.27, blue: 0.40))
                                .frame(width: 86, height: 86)
                                .background(Color.cyan.opacity(0.10))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        } else if let imageData = project.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 86, height: 86)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        } else {
                            VStack(spacing: 4) {
                                Image(systemName: stageIcon(for: project.currentStage))
                                    .font(.system(size: 30, weight: .medium))
                                Text("Add\nImage/Icon")
                                    .font(.system(size: 10, weight: .semibold))
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundStyle(Color.cyan.opacity(0.95))
                            .frame(width: 86, height: 86)
                            .background(Color.cyan.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $isShowingAddImageSheet) {
                    AddImageSheetView(
                        projectName: project.name,
                        projectEngineeringField: project.engineeringField,
                        onPhotoLibrary: {
                            pendingPickerAction = .photoLibrary
                            isShowingAddImageSheet = false
                        },
                        onTakePhoto: {
                            pendingPickerAction = .camera
                            isShowingAddImageSheet = false
                        },
                        onChooseFile: {
                            pendingPickerAction = .file
                            isShowingAddImageSheet = false
                        },
                        onIconSelected: { symbol in
                            onIconSelected(symbol)
                            isShowingAddImageSheet = false
                        }
                    )
                    .presentationDetents([.height(640), .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(28)
                    .presentationBackground(.thickMaterial)
                }
                .onChange(of: isShowingAddImageSheet) { _, isShown in
                    guard !isShown, let action = pendingPickerAction else { return }
                    pendingPickerAction = nil
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        switch action {
                        case .photoLibrary: isShowingPhotosPicker = true
                        case .camera: isShowingCamera = true
                        case .file: isShowingFilePicker = true
                        }
                    }
                }
                .photosPicker(isPresented: $isShowingPhotosPicker, selection: $photosPickerItem, matching: .images)
                .onChange(of: photosPickerItem) { _, newItem in
                    guard let newItem else { return }
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            await MainActor.run { onImageSelected(data) }
                        }
                        await MainActor.run { photosPickerItem = nil }
                    }
                }
                .fullScreenCover(isPresented: $isShowingCamera) {
                    CameraPicker { data in
                        if let data { onImageSelected(data) }
                    }
                    .ignoresSafeArea()
                }
                .fileImporter(isPresented: $isShowingFilePicker, allowedContentTypes: [.image]) { result in
                    if case .success(let url) = result {
                        let accessing = url.startAccessingSecurityScopedResource()
                        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                        if let data = try? Data(contentsOf: url) {
                            onImageSelected(data)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .top) {
                        Text(project.name)
                            .font(.system(size: 16, weight: .bold))
                            .tracking(0.3)
                            .foregroundStyle(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        Spacer()

                        Menu {
                            Button("Edit", action: onEdit)
                            Button("Delete Project", role: .destructive, action: onDelete)
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.secondary)
                                .frame(width: 20, height: 18)
                                .offset(y: -3)
                        }
                    }

                    HStack(spacing: 5) {
                        Image(systemName: "square.stack.3d.up")
                            .font(.system(size: 11, weight: .semibold))
                        Text(project.engineeringField)
                            .font(.system(size: 10, weight: .medium))
                            .tracking(0.3)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }
                    .foregroundStyle(.blue)

                    HStack(spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: stageIcon(for: project.currentStage))
                                .font(.system(size: 10, weight: .semibold))
                            Text(project.currentStage)
                                .font(.system(size: 10, weight: .medium))
                                .tracking(0.3)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .foregroundStyle(stageColor(for: project.currentStage))
                        .padding(.vertical, 3)
                        .padding(.horizontal, 7)
                        .background(stageColor(for: project.currentStage).opacity(0.14))
                        .clipShape(Capsule())

                        Spacer()

                        TimelineView(.periodic(from: .now, by: 60)) { timeline in
                            Text("Updated \(relativeTime(from: project.lastUpdated, to: timeline.date))")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .offset(y: 4)

                        Button(action: onOpen) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.black)
                                .frame(width: 16, height: 18)
                                .offset(y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
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
            return .pink
        case "Testing":
            return Color(red: 0.92, green: 0.70, blue: 0.10)
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
            lastUpdated: Date(),
            imageData: projectToEdit?.imageData,
            iconSystemName: projectToEdit?.iconSystemName
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

struct AddImageSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step: Step = .options
    @State private var iconSearchText = ""
    @State private var selectedIconSymbol: String?

    let projectName: String
    let projectEngineeringField: String
    let onPhotoLibrary: () -> Void
    let onTakePhoto: () -> Void
    let onChooseFile: () -> Void
    let onIconSelected: (String) -> Void

    enum Step {
        case options, upload, icons
    }

    private let suggestedColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    private let standardColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)

    private var filteredCategories: [IconCategory] {
        let query = iconSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return nebulaeIconCatalog }
        return nebulaeIconCatalog.compactMap { category in
            let symbols = category.symbols.filter { $0.localizedCaseInsensitiveContains(query) }
            return symbols.isEmpty ? nil : IconCategory(name: category.name, symbols: symbols)
        }
    }

    private var suggestedSymbols: [String] {
        filteredCategories.first(where: { $0.name == "Suggested" })?.symbols ?? []
    }

    private var otherCategories: [IconCategory] {
        filteredCategories.filter { $0.name != "Suggested" }
    }

    var body: some View {
        ZStack {
            switch step {
            case .options:
                optionsView
                    .transition(.move(edge: .leading).combined(with: .opacity))
            case .upload:
                uploadView
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .icons:
                iconsView
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: step)
    }

    private var optionsView: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Add Image or Icon")
                        .font(.system(size: 26, weight: .bold))

                    Text("Choose how your project appears.")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(red: 0.35, green: 0.35, blue: 0.35))
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }

            VStack(spacing: 14) {
                optionRow(
                    iconSystemName: "photo.badge.plus",
                    iconColor: .blue,
                    iconBackground: Color.blue.opacity(0.12),
                    title: "Upload Image",
                    subtitle: "Use your own photo or screenshot",
                    action: {
                        withAnimation { step = .upload }
                    }
                )

                optionRow(
                    iconSystemName: "square.grid.2x2.fill",
                    iconColor: .pink,
                    iconBackground: Color.pink.opacity(0.12),
                    title: "Choose Icon",
                    subtitle: "Pick from Nebulae's icon collection",
                    action: {
                        withAnimation { step = .icons }
                    }
                )
            }

            Spacer()

            Button(action: { dismiss() }) {
                Text("Cancel")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .padding(.bottom, 22)
    }

    private func optionRow(
        iconSystemName: String,
        iconColor: Color,
        iconBackground: Color,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: iconSystemName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(iconColor)
                    .frame(width: 48, height: 48)
                    .background(iconBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.black)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .frame(height: 80)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.gray.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var uploadView: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Button(action: {
                    withAnimation { step = .options }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 36, height: 36)
                        .background(Color.gray.opacity(0.10))
                        .clipShape(Circle())
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }

            VStack(spacing: 10) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(.blue)
                    .frame(width: 52, height: 52)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                Text("Upload Image")
                    .font(.system(size: 22, weight: .bold))

                Text("Choose a photo for your project.")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Button(action: onPhotoLibrary) {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.blue)
                        .frame(width: 48, height: 48)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(Circle())

                    Text("Tap to Upload")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.black)

                    VStack(spacing: 2) {
                        Text("PNG, JPG, or WEBP")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        Text("Max size: 5MB")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.blue.opacity(0.04))
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                            .foregroundStyle(Color.blue.opacity(0.45))
                    }
                )
            }
            .buttonStyle(.plain)

            Text("Or choose from")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            HStack(spacing: 10) {
                smallActionButton(systemName: "photo.on.rectangle", label: "Photo Library", action: onPhotoLibrary)
                smallActionButton(systemName: "camera", label: "Take Photo", action: onTakePhoto)
                smallActionButton(systemName: "folder", label: "Choose File", action: onChooseFile)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
        .padding(.bottom, 22)
    }

    private func smallActionButton(systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.blue)
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.gray.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var iconsView: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: {
                    withAnimation { step = .options }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 36, height: 36)
                        .background(Color.gray.opacity(0.10))
                        .clipShape(Circle())
                }

                Spacer()

                VStack(spacing: 3) {
                    Text("Choose Icon")
                        .font(.system(size: 20, weight: .bold))
                    Text("Pick a symbol for your project")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(width: 36, height: 36)
                }
            }

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                        TextField("Search icons...", text: $iconSearchText)
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 42)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                    )

                    if !suggestedSymbols.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Suggested")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.secondary)

                            LazyVGrid(columns: suggestedColumns, spacing: 8) {
                                ForEach(suggestedSymbols, id: \.self) { symbol in
                                    iconCell(symbol: symbol, isSuggested: true)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Preview")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 118, alignment: .center)

                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: selectedIconSymbol ?? "sparkles")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(Color(red: 0.06, green: 0.27, blue: 0.40))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.cyan.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        Text(projectName.isEmpty ? "Project" : projectName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.black)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.82)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(alignment: .top, spacing: 4) {
                            Image(systemName: "square.stack.3d.up")
                                .font(.system(size: 10, weight: .semibold))
                            Text(projectEngineeringField.isEmpty ? "Field" : projectEngineeringField)
                                .font(.system(size: 10, weight: .medium))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .minimumScaleFactor(0.82)
                        }
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(10)
                    .frame(width: 118)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                    )
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(otherCategories) { category in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(category.name)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.secondary)

                            LazyVGrid(columns: standardColumns, spacing: 8) {
                                ForEach(category.symbols, id: \.self) { symbol in
                                    iconCell(symbol: symbol, isSuggested: false)
                                }
                            }
                        }
                    }

                    if filteredCategories.isEmpty {
                        Text("No icons found.")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)
                    }
                }
                .padding(.vertical, 4)
            }

            Button(action: {
                if let symbol = selectedIconSymbol {
                    onIconSelected(symbol)
                }
            }) {
                Text("Save Icon")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        selectedIconSymbol != nil
                            ? Color.cyan.opacity(0.60)
                            : Color.gray.opacity(0.15)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(selectedIconSymbol == nil)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 18)
    }

    private func iconCell(symbol: String, isSuggested: Bool) -> some View {
        let isSelected = selectedIconSymbol == symbol
        let iconColor = Color(red: 0.06, green: 0.27, blue: 0.40)
        let cellHeight: CGFloat = isSuggested ? 44 : 40
        let glyphSize: CGFloat = isSuggested ? 19 : 17
        let cornerRadius: CGFloat = isSuggested ? 11 : 10
        return Button(action: {
            selectedIconSymbol = symbol
        }) {
            Image(systemName: symbol)
                .font(.system(size: glyphSize, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(maxWidth: .infinity)
                .frame(height: cellHeight)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(isSelected ? Color.cyan.opacity(0.14) : Color.white)
                        .stroke(
                            isSelected ? iconColor.opacity(0.55) : Color.gray.opacity(0.18),
                            lineWidth: isSelected ? 1.5 : 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    let onImage: (Data?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImage: onImage)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImage: (Data?) -> Void

        init(onImage: @escaping (Data?) -> Void) {
            self.onImage = onImage
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.85) {
                onImage(data)
            } else {
                onImage(nil)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            onImage(nil)
        }
    }
}

#Preview {
    ContentView()
}
