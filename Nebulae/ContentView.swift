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
    var teamSize: String = "1"
}

let nebulaeTeamSizes: [String] = ["1", "2", "3", "4", "5+"]

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
    @State private var selectedSort: SortOption?
    @State private var teamSizeFilter: String?

    enum SortOption: String, CaseIterable, Identifiable {
        case field = "Field"
        case stage = "Stage"
        case alphabetical = "Alphabetical"
        case dateStarted = "Date Started"
        case lastUpdated = "Last Updated"

        var id: String { rawValue }
    }

    private var filteredProjects: [Project] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        var base = query.isEmpty
            ? projects
            : projects.filter { $0.name.localizedCaseInsensitiveContains(query) }
        if let size = teamSizeFilter {
            base = base.filter { $0.teamSize == size }
        }
        return sorted(base)
    }

    private func sorted(_ list: [Project]) -> [Project] {
        guard let sort = selectedSort else { return list }
        switch sort {
        case .field:
            return list.sorted { $0.engineeringField.localizedCaseInsensitiveCompare($1.engineeringField) == .orderedAscending }
        case .stage:
            let order = ["Idea", "Research", "Design", "Prototype", "Testing", "Completed"]
            return list.sorted { a, b in
                let ai = order.firstIndex(of: a.currentStage) ?? Int.max
                let bi = order.firstIndex(of: b.currentStage) ?? Int.max
                return ai < bi
            }
        case .alphabetical:
            return list.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .dateStarted:
            return list.sorted { $0.dateCreated > $1.dateCreated }
        case .lastUpdated:
            return list.sorted { $0.lastUpdated > $1.lastUpdated }
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
                .presentationDetents([.large])
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
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.thickMaterial)
                .presentationContentInteraction(.scrolls)
            }
            .navigationDestination(for: Project.self) { project in
                ProjectDashboardView(
                    projects: $projects,
                    projectID: project.id,
                    onEdit: {
                        if let latest = projects.first(where: { $0.id == project.id }) {
                            projectBeingEdited = latest
                        } else {
                            projectBeingEdited = project
                        }
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

                Menu {
                    Section("Sort") {
                        ForEach(SortOption.allCases) { option in
                            Button {
                                selectedSort = (selectedSort == option) ? nil : option
                            } label: {
                                if selectedSort == option {
                                    Label(option.rawValue, systemImage: "checkmark")
                                } else {
                                    Text(option.rawValue)
                                }
                            }
                        }
                    }
                    Section("Filter") {
                        Menu("Number of People") {
                            Button {
                                teamSizeFilter = nil
                            } label: {
                                if teamSizeFilter == nil {
                                    Label("All", systemImage: "checkmark")
                                } else {
                                    Text("All")
                                }
                            }
                            ForEach(nebulaeTeamSizes, id: \.self) { size in
                                Button {
                                    teamSizeFilter = (teamSizeFilter == size) ? nil : size
                                } label: {
                                    if teamSizeFilter == size {
                                        Label(size, systemImage: "checkmark")
                                    } else {
                                        Text(size)
                                    }
                                }
                            }
                        }
                    }
                } label: {
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
                                .offset(y: -12)
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
                        .foregroundStyle(stageTextColor(for: project.currentStage))
                        .padding(.vertical, 3)
                        .padding(.horizontal, 7)
                        .background(stageColor(for: project.currentStage).opacity(0.14))
                        .clipShape(Capsule())

                        HStack(spacing: 3) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 10, weight: .semibold))
                            Text(project.teamSize)
                                .font(.system(size: 10, weight: .medium))
                                .tracking(0.3)
                        }
                        .foregroundStyle(Color(red: 0.18, green: 0.18, blue: 0.42))
                        .padding(.vertical, 3)
                        .padding(.horizontal, 7)
                        .background(Color.indigo.opacity(0.14))
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

    private func stageTextColor(for stage: String) -> Color {
        switch stage {
        case "Idea":
            return Color(red: 0.05, green: 0.30, blue: 0.38)
        case "Research":
            return Color(red: 0.48, green: 0.24, blue: 0.04)
        case "Design":
            return Color(red: 0.28, green: 0.08, blue: 0.42)
        case "Prototype":
            return Color(red: 0.52, green: 0.08, blue: 0.28)
        case "Testing":
            return Color(red: 0.42, green: 0.28, blue: 0.04)
        case "Completed":
            return Color(red: 0.22, green: 0.22, blue: 0.22)
        default:
            return Color(red: 0.05, green: 0.30, blue: 0.38)
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
    @State private var teamSize = "1"
    @State private var isShowingFieldOptions = false
    @State private var isShowingTeamSizeOptions = false
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
        _teamSize = State(initialValue: projectToEdit?.teamSize ?? "1")
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

            VStack(alignment: .leading, spacing: 10) {
                Text("Number of People")
                    .font(.system(size: 17, weight: .bold))

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isShowingTeamSizeOptions.toggle()
                    }
                }) {
                    HStack(spacing: 14) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.blue)

                        Text(teamSize)
                            .font(.system(size: 16))
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .rotationEffect(.degrees(isShowingTeamSizeOptions ? 180 : 0))
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1.5)
                    )
                }

                if isShowingTeamSizeOptions {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(nebulaeTeamSizes, id: \.self) { size in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.18)) {
                                    teamSize = size
                                    isShowingTeamSizeOptions = false
                                }
                            }) {
                                HStack {
                                    Text(size)
                                        .font(.system(size: 15))
                                        .foregroundStyle(.primary)

                                    Spacer()

                                    if teamSize == size {
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
            iconSystemName: projectToEdit?.iconSystemName,
            teamSize: teamSize
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
    @Binding var projects: [Project]
    let projectID: UUID
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onImageSelected: (Data) -> Void
    let onIconSelected: (String) -> Void

    @State private var selectedStage: String

    @State private var isShowingAddImageSheet = false
    @State private var isShowingPhotosPicker = false
    @State private var isShowingCamera = false
    @State private var isShowingFilePicker = false
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var pendingPickerAction: ThumbnailPickerAction?

    enum ThumbnailPickerAction {
        case photoLibrary, camera, file
    }

    private var project: Project {
        projects.first(where: { $0.id == projectID }) ?? Project(
            id: projectID,
            name: "",
            engineeringField: "",
            currentStage: "Idea",
            dateCreated: Date(),
            lastUpdated: Date()
        )
    }

    init(
        projects: Binding<[Project]>,
        projectID: UUID,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        onImageSelected: @escaping (Data) -> Void,
        onIconSelected: @escaping (String) -> Void
    ) {
        self._projects = projects
        self.projectID = projectID
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onImageSelected = onImageSelected
        self.onIconSelected = onIconSelected
        let initialStage = projects.wrappedValue.first(where: { $0.id == projectID })?.currentStage ?? "Idea"
        self._selectedStage = State(initialValue: initialStage)
    }

    private struct StageStep {
        let name: String
        let displayName: String
        let icon: String
    }

    private let stageSteps: [StageStep] = [
        StageStep(name: "Idea", displayName: "Idea", icon: "lightbulb"),
        StageStep(name: "Research", displayName: "Research", icon: "magnifyingglass"),
        StageStep(name: "Design", displayName: "Design", icon: "pencil"),
        StageStep(name: "Prototype", displayName: "Prototype", icon: "wrench.and.screwdriver"),
        StageStep(name: "Testing", displayName: "Testing", icon: "flask"),
        StageStep(name: "Completed", displayName: "Complete", icon: "trophy.fill")
    ]

    private enum TaskStatus {
        case completed, inProgress, notStarted

        var label: String {
            switch self {
            case .completed: return "Completed"
            case .inProgress: return "In Progress"
            case .notStarted: return "Not Started"
            }
        }

        var textColor: Color {
            switch self {
            case .completed: return Color(red: 0.05, green: 0.45, blue: 0.20)
            case .inProgress: return Color(red: 0.55, green: 0.30, blue: 0.04)
            case .notStarted: return Color(red: 0.35, green: 0.35, blue: 0.35)
            }
        }

        var backgroundColor: Color {
            switch self {
            case .completed: return Color.green.opacity(0.16)
            case .inProgress: return Color.orange.opacity(0.16)
            case .notStarted: return Color.gray.opacity(0.16)
            }
        }
    }

    private struct TaskItem {
        let title: String
        let description: String
        let icon: String
        let iconColor: Color
        let status: TaskStatus
    }

    private var ideaTasks: [TaskItem] {
        let teamOrResponsibility: TaskItem
        if project.teamSize == "1" {
            teamOrResponsibility = TaskItem(
                title: "My Contributions",
                description: "Document your responsibilities, decisions, and work.",
                icon: "person.fill",
                iconColor: .orange,
                status: .notStarted
            )
        } else {
            teamOrResponsibility = TaskItem(
                title: "Team & Roles",
                description: "Assign team members and define roles and responsibilities.",
                icon: "person.2.fill",
                iconColor: .orange,
                status: .notStarted
            )
        }

        return [
            TaskItem(title: "Brainstorming", description: "List and explore different ideas and approaches.", icon: "lightbulb.fill", iconColor: .cyan, status: .completed),
            TaskItem(title: "Problem Statement", description: "Define the problem your project aims to solve.", icon: "doc.text.fill", iconColor: .blue, status: .inProgress),
            TaskItem(title: "Goals & Objectives", description: "Outline the goals and outcomes of your project.", icon: "target", iconColor: .purple, status: .notStarted),
            teamOrResponsibility,
            TaskItem(title: "Project Plan (Overview)", description: "Create a high-level plan and timeline.", icon: "list.bullet.clipboard.fill", iconColor: .green, status: .notStarted)
        ]
    }

    private var currentStageIndex: Int {
        stageSteps.firstIndex(where: { $0.name == project.currentStage }) ?? 0
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                heroCard
                projectProgressCard
                stageContent
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .background(Color(red: 0.97, green: 0.98, blue: 0.99))
        .navigationTitle("Project")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Edit", action: onEdit)
                    Button("Delete Project", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.black)
                }
            }
        }
    }

    private var heroCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 14) {
                Button(action: {
                    isShowingAddImageSheet = true
                }) {
                    projectThumbnail
                        .frame(width: 90, height: 90)
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

                VStack(alignment: .leading, spacing: 6) {
                    Text(project.name)
                        .font(.custom("TimesNewRomanPS-BoldMT", size: 22))
                        .foregroundStyle(.black)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    HStack(spacing: 5) {
                        Image(systemName: "square.stack.3d.up")
                            .font(.system(size: 13, weight: .semibold))
                        Text(project.engineeringField)
                            .font(.system(size: 14, weight: .semibold))
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                    }
                    .foregroundStyle(.blue)
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                miniInfoCard(title: "Current Stage", icon: "location.fill", value: project.currentStage)
                TimelineView(.periodic(from: .now, by: 60)) { timeline in
                    miniInfoCard(
                        title: "Last Updated",
                        icon: "calendar",
                        value: relativeTime(from: project.lastUpdated, to: timeline.date)
                    )
                }
            }
        }
        .padding(14)
        .background(Color.cyan.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder
    private var projectThumbnail: some View {
        if let symbolName = project.iconSystemName {
            Image(systemName: symbolName)
                .font(.system(size: 38, weight: .medium))
                .foregroundStyle(Color(red: 0.06, green: 0.27, blue: 0.40))
                .frame(width: 90, height: 90)
                .background(Color.cyan.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        } else if let imageData = project.imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        } else {
            Image(systemName: stepIcon(for: project.currentStage))
                .font(.system(size: 38, weight: .medium))
                .foregroundStyle(Color(red: 0.06, green: 0.27, blue: 0.40))
                .frame(width: 90, height: 90)
                .background(Color.cyan.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func miniInfoCard(title: String, icon: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var projectProgressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Project Progress")
                .font(.system(size: 17, weight: .bold))

            HStack(alignment: .top, spacing: 0) {
                ForEach(stageSteps.indices, id: \.self) { index in
                    progressStep(index: index)
                    if index < stageSteps.count - 1 {
                        Rectangle()
                            .fill(Color.gray.opacity(0.25))
                            .frame(height: 1.5)
                            .padding(.top, 16)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
        )
    }

    private func progressStep(index: Int) -> some View {
        let step = stageSteps[index]
        let isSelected = step.name == selectedStage
        let activeTint = Color(red: 0.06, green: 0.45, blue: 0.70)

        return Button(action: {
            selectedStage = step.name
        }) {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.cyan.opacity(0.20) : Color.clear)
                        .frame(width: 34, height: 34)
                    Circle()
                        .stroke(
                            isSelected ? activeTint : Color.gray.opacity(0.30),
                            lineWidth: 1.5
                        )
                        .frame(width: 34, height: 34)
                    Image(systemName: step.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(
                            isSelected ? activeTint : Color.gray.opacity(0.55)
                        )
                }
                Text(step.displayName)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(isSelected ? .black : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(width: 44)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var stageContent: some View {
        switch selectedStage {
        case "Idea":
            ideaStageView
        case "Research":
            researchStageView
        case "Design":
            designStageView
        case "Prototype":
            prototypeStageView
        case "Testing":
            testingStageView
        case "Completed":
            completeStageView
        default:
            EmptyView()
        }
    }

    private let completeTasks: [TaskItem] = [
        TaskItem(title: "Final Summary", description: "Write a summary of your completed project.", icon: "doc.text.fill", iconColor: .green, status: .completed),
        TaskItem(title: "Requirements Review", description: "Compare final results with original goals.", icon: "target", iconColor: .orange, status: .completed),
        TaskItem(title: "Final Results", description: "Document outcomes and performance.", icon: "chart.bar.fill", iconColor: .blue, status: .inProgress),
        TaskItem(title: "Demo / Presentation", description: "Showcase your finished project with videos and slides.", icon: "play.rectangle.fill", iconColor: .purple, status: .notStarted),
        TaskItem(title: "Technical Documentation", description: "Create final guides, instructions, and explanations.", icon: "doc.richtext.fill", iconColor: .cyan, status: .notStarted),
        TaskItem(title: "Reflection", description: "Record lessons learned and key takeaways.", icon: "lightbulb.fill", iconColor: .orange, status: .inProgress),
        TaskItem(title: "Future Improvements", description: "Plan upgrades and next steps.", icon: "arrow.up.right.circle.fill", iconColor: .cyan, status: .notStarted),
        TaskItem(title: "Portfolio Showcase", description: "Create your final project presentation.", icon: "star.fill", iconColor: .pink, status: .notStarted),
        TaskItem(title: "Final Files", description: "Organize final documents, CAD files, code, and resources.", icon: "folder.fill", iconColor: .red, status: .notStarted),
        TaskItem(title: "Links & Sharing", description: "Add external links and resources.", icon: "link.circle.fill", iconColor: .purple, status: .notStarted),
        TaskItem(title: "Achievements", description: "Record awards, recognitions, and milestones.", icon: "trophy.fill", iconColor: .teal, status: .notStarted)
    ]

    private var completeStageView: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Complete")
                    .font(.system(size: 22, weight: .bold))
                Text("Finalize your project, reflect on results, and prepare your portfolio.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 10) {
                ForEach(completeTasks.indices, id: \.self) { i in
                    taskCard(task: completeTasks[i])
                }
            }

            generatePortfolioButton
            addCustomTaskButton
        }
    }

    private var generatePortfolioButton: some View {
        Button(action: {}) {
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Generate Portfolio")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundStyle(.white)

                Text("Create a beautiful portfolio from your project")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.88))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.20, green: 0.65, blue: 0.45),
                        Color(red: 0.50, green: 0.85, blue: 0.60)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private let testingTasks: [TaskItem] = [
        TaskItem(title: "Testing Plans", description: "Define methods, procedures, and success criteria.", icon: "list.clipboard.fill", iconColor: .cyan, status: .completed),
        TaskItem(title: "Performance Metrics", description: "Track key measurements and project goals.", icon: "gauge.medium", iconColor: .orange, status: .inProgress),
        TaskItem(title: "Conditions & Variables", description: "Record testing factors and environmental conditions.", icon: "slider.horizontal.3", iconColor: .green, status: .notStarted),
        TaskItem(title: "Test Results & Data", description: "Track measurements, results, and observations.", icon: "chart.bar.fill", iconColor: .blue, status: .inProgress),
        TaskItem(title: "Data Analysis", description: "Analyze results and identify patterns or trends.", icon: "chart.line.uptrend.xyaxis", iconColor: .green, status: .notStarted),
        TaskItem(title: "Failures & Issues", description: "Document problems found during testing.", icon: "exclamationmark.triangle.fill", iconColor: .red, status: .inProgress),
        TaskItem(title: "Improvements", description: "Track changes made based on test results.", icon: "lightbulb.fill", iconColor: .cyan, status: .notStarted),
        TaskItem(title: "Test Iterations", description: "Compare test rounds and track improvements.", icon: "arrow.triangle.2.circlepath", iconColor: .purple, status: .notStarted),
        TaskItem(title: "User Feedback", description: "Collect feedback and observations from users.", icon: "person.bubble.fill", iconColor: .orange, status: .notStarted),
        TaskItem(title: "Validation", description: "Confirm requirements and goals were achieved.", icon: "checkmark.shield.fill", iconColor: .green, status: .notStarted),
        TaskItem(title: "Testing Report", description: "Summarize the testing process, results, and conclusions.", icon: "doc.text.fill", iconColor: .yellow, status: .notStarted)
    ]

    private var testingStageView: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Testing")
                    .font(.system(size: 22, weight: .bold))
                Text("Evaluate performance, analyze results, and improve your solution.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 10) {
                ForEach(testingTasks.indices, id: \.self) { i in
                    taskCard(task: testingTasks[i])
                }
            }

            addCustomTaskButton
        }
    }

    private let prototypeTasks: [TaskItem] = [
        TaskItem(title: "Prototype Builds", description: "Track different versions and physical or digital builds.", icon: "wrench.and.screwdriver.fill", iconColor: .teal, status: .completed),
        TaskItem(title: "Build Logs", description: "Record progress updates, notes, and milestones.", icon: "note.text", iconColor: .orange, status: .inProgress),
        TaskItem(title: "Tools & Equipment", description: "Document tools, software, and equipment used.", icon: "hammer.fill", iconColor: .green, status: .notStarted),
        TaskItem(title: "Parts & Assembly", description: "Track components, inventory, and assembly steps.", icon: "puzzlepiece.fill", iconColor: .purple, status: .notStarted),
        TaskItem(title: "Fabrication / Manufacturing", description: "Document how parts were made or manufactured.", icon: "gearshape.2.fill", iconColor: .pink, status: .notStarted),
        TaskItem(title: "Code & Software", description: "Track programs, algorithms, and software changes.", icon: "chevron.left.forwardslash.chevron.right", iconColor: .blue, status: .notStarted),
        TaskItem(title: "Media Documentation", description: "Add photos, videos, and visual progress updates.", icon: "camera.fill", iconColor: .red, status: .notStarted),
        TaskItem(title: "Problems & Fixes", description: "Record challenges encountered and how you solved them.", icon: "exclamationmark.triangle.fill", iconColor: .orange, status: .notStarted),
        TaskItem(title: "Prototype Iterations", description: "Compare versions and track changes and improvements.", icon: "arrow.triangle.2.circlepath", iconColor: .cyan, status: .notStarted),
        TaskItem(title: "Measurements & Observations", description: "Record performance data and observations.", icon: "chart.bar.fill", iconColor: .green, status: .notStarted),
        TaskItem(title: "Prototype Review", description: "Evaluate the prototype and prepare for testing.", icon: "checkmark.seal.fill", iconColor: .cyan, status: .notStarted)
    ]

    private var prototypeStageView: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Prototype")
                    .font(.system(size: 22, weight: .bold))
                Text("Build, test early versions, and document your development process.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 10) {
                ForEach(prototypeTasks.indices, id: \.self) { i in
                    taskCard(task: prototypeTasks[i])
                }
            }

            addCustomTaskButton
        }
    }

    private let designTasks: [TaskItem] = [
        TaskItem(title: "Concept Sketches", description: "Sketch and visualize your initial ideas and concepts.", icon: "pencil.and.scribble", iconColor: .orange, status: .completed),
        TaskItem(title: "CAD Models & Drawings", description: "Create 3D models and technical drawings.", icon: "cube.fill", iconColor: .purple, status: .inProgress),
        TaskItem(title: "System Architecture", description: "Map out the components and how they work together.", icon: "rectangle.3.group.fill", iconColor: .green, status: .notStarted),
        TaskItem(title: "Materials & Components", description: "Choose materials and list necessary components.", icon: "square.grid.3x3.fill", iconColor: .cyan, status: .notStarted),
        TaskItem(title: "Design Requirements / Specifications", description: "Define measurements, features, and performance targets.", icon: "target", iconColor: .pink, status: .notStarted),
        TaskItem(title: "Calculations & Analysis", description: "Perform calculations, simulations, and analysis.", icon: "function", iconColor: .blue, status: .notStarted),
        TaskItem(title: "Iterations", description: "Track design changes and improvements over time.", icon: "arrow.triangle.2.circlepath", iconColor: .purple, status: .notStarted),
        TaskItem(title: "Design Decisions / Trade-offs", description: "Explain choices made and compare options considered.", icon: "arrow.triangle.branch", iconColor: .orange, status: .notStarted),
        TaskItem(title: "Design Review", description: "Get feedback from peers before prototyping.", icon: "checkmark.bubble.fill", iconColor: .teal, status: .notStarted)
    ]

    private var designStageView: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Design")
                    .font(.system(size: 22, weight: .bold))
                Text("Plan, create, and refine your solution before prototyping.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 10) {
                ForEach(designTasks.indices, id: \.self) { i in
                    taskCard(task: designTasks[i])
                }
            }

            addCustomTaskButton
        }
    }

    private let researchTasks: [TaskItem] = [
        TaskItem(title: "Background Research", description: "Learn concepts, principles, and relevant information.", icon: "book.fill", iconColor: .purple, status: .completed),
        TaskItem(title: "Existing Solutions", description: "Analyze current designs and identify improvements.", icon: "magnifyingglass", iconColor: .orange, status: .inProgress),
        TaskItem(title: "Key Questions", description: "Track important questions and discoveries.", icon: "questionmark.circle.fill", iconColor: .yellow, status: .notStarted),
        TaskItem(title: "Sources & References", description: "Save articles, papers, videos, and other resources.", icon: "bookmark.fill", iconColor: .pink, status: .notStarted),
        TaskItem(title: "Constraints & Requirements", description: "Identify limits, needs, and design criteria.", icon: "exclamationmark.triangle.fill", iconColor: .green, status: .notStarted),
        TaskItem(title: "Research Notes", description: "Document findings, comparisons, and observations.", icon: "note.text", iconColor: .cyan, status: .notStarted)
    ]

    private var researchStageView: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Research")
                    .font(.system(size: 22, weight: .bold))
                Text("Explore existing solutions, gather information, and prepare for design.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 10) {
                ForEach(researchTasks.indices, id: \.self) { i in
                    taskCard(task: researchTasks[i])
                }
            }

            addCustomTaskButton
        }
    }

    private var ideaStageView: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Idea")
                    .font(.system(size: 22, weight: .bold))
                Text("Define the problem, brainstorm solutions, and set the foundation for your project.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 10) {
                ForEach(ideaTasks.indices, id: \.self) { i in
                    taskCard(task: ideaTasks[i])
                }
            }

            addCustomTaskButton
        }
    }

    private func taskCard(task: TaskItem) -> some View {
        Button(action: {}) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: task.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(task.iconColor)
                    .frame(width: 40, height: 40)
                    .background(task.iconColor.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                    Text(task.description)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 4)

                statusBadge(task.status)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.gray.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func statusBadge(_ status: TaskStatus) -> some View {
        HStack(spacing: 4) {
            if status == .completed {
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .bold))
            }
            Text(status.label)
                .font(.system(size: 10, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(status.textColor)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(status.backgroundColor)
        .clipShape(Capsule())
    }

    private var addCustomTaskButton: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                Text("Add Custom Task")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(Color(red: 0.06, green: 0.45, blue: 0.70))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.cyan.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        Color(red: 0.06, green: 0.45, blue: 0.70).opacity(0.30),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func stepIcon(for stage: String) -> String {
        stageSteps.first(where: { $0.name == stage })?.icon ?? "folder"
    }

    private func friendlyDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let days = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
        if days < 7 { return "\(days)d ago" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func relativeTime(from date: Date, to currentDate: Date) -> String {
        let seconds = max(0, Int(currentDate.timeIntervalSince(date)))
        if seconds < 60 { return "Just now" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        return "\(days)d ago"
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
                        .offset(y: +32)
                    Text("Pick a symbol for your project")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .offset(y: +35)
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
                .padding(.top, 67)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Preview")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 118, alignment: .center)
                        .padding(.top, 44)
                        .offset(x: -3)

                    VStack(alignment: .leading, spacing: 0) {
                        Image(systemName: selectedIconSymbol ?? "sparkles")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundStyle(Color(red: 0.06, green: 0.27, blue: 0.40))
                            .frame(maxWidth: .infinity)
                            .frame(height: 66)
                            .background(Color.cyan.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Spacer(minLength: 4)

                        Text(projectName.isEmpty ? "Project" : projectName)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.black)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.82)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Spacer(minLength: 4)
                    }
                    .padding(10)
                    .frame(width: 118, height: 121.5)
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
