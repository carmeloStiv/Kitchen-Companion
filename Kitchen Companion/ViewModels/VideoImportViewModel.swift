//
//  VideoImportViewModel.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation
import Combine

// Drives the "import a recipe from a video" screen.
@MainActor
final class VideoImportViewModel: ObservableObject {
    @Published var isTranscribing = false
    @Published var transcript = ""
    @Published var errorMessage: String?
    @Published var draft: RecipeDraft?

    private let transcriber: VideoTranscribing

    init(transcriber: VideoTranscribing = VideoRecipeTranscriber()) {
        self.transcriber = transcriber
    }

    func transcribeVideo(at url: URL) {
        isTranscribing = true
        errorMessage = nil

        Task {
            defer { isTranscribing = false }
            do {
                let text = try await transcriber.transcribe(videoURL: url)
                transcript = text
            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription
                    ?? "Couldn't transcribe this video. Paste the recipe text in below instead."
            }
        }
    }

    // Parses whatever is currently in the transcript field.
    func generateDraft(suggestedTitle: String) {
        guard !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "There's no transcript to work from yet. Transcribe a video or paste some text in first."
            return
        }
        draft = RecipeDraftParser.parse(transcript: transcript, suggestedTitle: suggestedTitle)
        errorMessage = nil
    }
}
