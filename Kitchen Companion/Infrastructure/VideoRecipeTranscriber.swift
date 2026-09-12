//
//  VideoRecipeTranscriber.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation
import AVFoundation
import Speech

// Errors from turning an imported video into text, written for the cook not a developer.
enum VideoTranscriptionError: LocalizedError, Equatable {
    case speechRecognitionNotAuthorized
    case audioExtractionFailed
    case transcriptionProducedNoText

    var errorDescription: String? {
        switch self {
        case .speechRecognitionNotAuthorized:
            return "Speech recognition isn't allowed for this app yet. Enable it in Settings, or paste the recipe text in below instead."
        case .audioExtractionFailed:
            return "Couldn't read the audio from this video. Try a different file, or paste the recipe text in below instead."
        case .transcriptionProducedNoText:
            return "Nothing understandable was heard in this video. Try a clearer video, or paste the recipe text in below instead."
        }
    }
}

// Extracts a video's audio track and transcribes it on-device via Apple's Speech framework.
struct VideoRecipeTranscriber: VideoTranscribing {
    func transcribe(videoURL: URL) async throws -> String {
        try await requestAuthorization()
        let audioURL = try await extractAudioTrack(from: videoURL)
        defer { try? FileManager.default.removeItem(at: audioURL) }
        let transcript = try await recognizeSpeech(in: audioURL)

        guard !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw VideoTranscriptionError.transcriptionProducedNoText
        }
        return transcript
    }

    private func requestAuthorization() async throws {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        guard status == .authorized else {
            throw VideoTranscriptionError.speechRecognitionNotAuthorized
        }
    }

    private func extractAudioTrack(from videoURL: URL) async throws -> URL {
        let asset = AVURLAsset(url: videoURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw VideoTranscriptionError.audioExtractionFailed
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("m4a")
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a

        await exportSession.export()

        guard exportSession.status == .completed else {
            throw VideoTranscriptionError.audioExtractionFailed
        }
        return outputURL
    }

    private func recognizeSpeech(in audioURL: URL) async throws -> String {
        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            throw VideoTranscriptionError.transcriptionProducedNoText
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = SFSpeechURLRecognitionRequest(url: audioURL)
            request.shouldReportPartialResults = false

            recognizer.recognitionTask(with: request) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let result, result.isFinal else { return }
                continuation.resume(returning: result.bestTranscription.formattedString)
            }
        }
    }
}
