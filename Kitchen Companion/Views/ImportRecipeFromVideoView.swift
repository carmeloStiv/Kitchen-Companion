//
//  ImportRecipeFromVideoView.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import SwiftUI
import UniformTypeIdentifiers

// Transcribes a picked video on-device into a recipe draft for review.
struct ImportRecipeFromVideoView: View {
    @ObservedObject var kitchenViewModel: KitchenViewModel
    @StateObject private var importViewModel = VideoImportViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var isPickingVideo = false
    @State private var videoFileName: String?
    @State private var isShowingDraftReview = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Video") {
                    Button {
                        isPickingVideo = true
                    } label: {
                        Label(videoFileName ?? "Choose Video", systemImage: "video")
                    }

                    if importViewModel.isTranscribing {
                        HStack {
                            ProgressView()
                            Text("Transcribing…")
                        }
                    }
                }

                Section("Transcript") {
                    Text("Automatic transcription is best-effort. Review or edit the text below before generating a recipe.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextEditor(text: $importViewModel.transcript)
                        .frame(minHeight: 150)
                }

                Section {
                    Button {
                        importViewModel.generateDraft(suggestedTitle: videoFileName.map { ($0 as NSString).deletingPathExtension } ?? "Imported Recipe")
                        if importViewModel.draft != nil {
                            isShowingDraftReview = true
                        }
                    } label: {
                        Label("Generate Recipe Draft", systemImage: "wand.and.stars")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                }
            }
            .navigationTitle("Import from Video")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .fileImporter(isPresented: $isPickingVideo, allowedContentTypes: [.movie]) { result in
                if case .success(let url) = result {
                    videoFileName = url.lastPathComponent
                    importViewModel.transcribeVideo(at: url)
                }
            }
            .sheet(isPresented: $isShowingDraftReview, onDismiss: { dismiss() }) {
                if let draft = importViewModel.draft {
                    AddRecipeView(
                        viewModel: kitchenViewModel,
                        draft: draft,
                        source: .importedVideo(fileName: videoFileName ?? "Unknown")
                    )
                }
            }
            .alert("Import Problem", isPresented: Binding(
                get: { importViewModel.errorMessage != nil },
                set: { _ in importViewModel.errorMessage = nil }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importViewModel.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    ImportRecipeFromVideoView(kitchenViewModel: KitchenViewModel())
}
