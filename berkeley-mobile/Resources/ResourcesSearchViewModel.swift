import Foundation
import FoundationModels
import Observation

@available(iOS 26.0, *)
@MainActor
@Observable
class ResourcesSearchViewModel {

    var query = ""
    var results: [BMResource] = []
    var isSearching = false
    var searchError: String?

    @ObservationIgnored
    private var session: LanguageModelSession?

    func search(query: String, in categories: [BMResourceCategory]) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }

        guard SystemLanguageModel.default.availability == .available else {
            searchError = "On-device AI is not available on this device."
            return
        }

        isSearching = true
        searchError = nil
        defer { isSearching = false }

        let allResources = categories.flatMap { $0.sections }.flatMap { $0.resources }
        let resourceList = allResources
            .map { "- \($0.name)" }
            .joined(separator: "\n")

        let prompt = """
        You are a helpful campus resource assistant for UC Berkeley students.
        Given the following list of campus resources, return only the names of the resources \
        that best match the user's search query. Return each matching resource name on its own line. \
        Only include resources from the list below — do not add any new ones. \
        If nothing matches, return an empty response.

        Resources:
        \(resourceList)

        User query: \(query)
        """

        if session == nil {
            session = LanguageModelSession()
        }

        do {
            let response = try await session!.respond(to: prompt)
            let matchedNames = Set(
                response.content
                    .components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "- ")) }
                    .filter { !$0.isEmpty }
            )
            results = allResources.filter { matchedNames.contains($0.name) }
        } catch {
            searchError = "Search failed: \(error.localizedDescription)"
            results = []
        }
    }

    func clear() {
        query = ""
        results = []
        searchError = nil
        session = nil
    }
}
