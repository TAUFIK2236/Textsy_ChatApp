//
//  ReportBlockViewModel.swift
//  Textsy
//
//  Created by Anika Tabasum on 9/14/25.
//



// Combines all report + block logic in one clean ViewModel

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ReportBlockViewModel: ObservableObject {
    @Published var isBlocked: Bool = false
    @Published var errorMessage = ""
    @Published var submitted = false

    // MARK: Block
    func blockUser(targetId: String) async {
        guard let myId = Auth.auth().currentUser?.uid else { return }
        let ref = Firestore.firestore().collection("users").document(myId)

        do {
            try await ref.updateData([
                "blocked": FieldValue.arrayUnion([targetId])
            ])
            isBlocked = true
        } catch {
            errorMessage = "❌ Failed to block: \(error.localizedDescription)"
        }
    }

    func unblockUser(targetId: String) async {
        guard let myId = Auth.auth().currentUser?.uid else { return }
        let ref = Firestore.firestore().collection("users").document(myId)

        do {
            try await ref.updateData([
                "blocked": FieldValue.arrayRemove([targetId])
            ])
            isBlocked = false
        } catch {
            errorMessage = "❌ Failed to unblock: \(error.localizedDescription)"
        }
    }

    func isBlockedBetween(currentId: String, targetId: String) async -> Bool {
        let db = Firestore.firestore()
        do {
            let meDoc = try await db.collection("users").document(currentId).getDocument()
            let themDoc = try await db.collection("users").document(targetId).getDocument()

            let myBlocked = meDoc["blocked"] as? [String] ?? []
            let theirBlocked = themDoc["blocked"] as? [String] ?? []

            return myBlocked.contains(targetId) || theirBlocked.contains(currentId)
        } catch {
            return true // Safe fallback: assume blocked
        }
    }

    // MARK: Report
    func reportUser(reportedId: String, reason: String, otherReason: String?) async {
        guard let reporterId = Auth.auth().currentUser?.uid else { return }

        let report: [String: Any] = [
            "reporterId": reporterId,
            "reportedId": reportedId,
            "reason": reason,
            "otherReason": otherReason ?? "",
            "action": false,
            "feedback": "",
            "timestamp": Timestamp()
        ]

        do {
            try await Firestore.firestore().collection("reports").addDocument(data: report)
            submitted = true
            await checkReportThreshold(for: reportedId)
        } catch {
            errorMessage = "❌ Report failed: \(error.localizedDescription)"
        }
    }

    // 🚨 Suspend user if needed
    func checkReportThreshold(for userId: String) async {
        let db = Firestore.firestore()

        do {
            let query = try await db.collection("reports")
                .whereField("reportedId", isEqualTo: userId)
                .whereField("action", isEqualTo: false)
                .getDocuments()

            let reportCount = query.documents.count
            let shouldSuspend = reportCount >= 20

            try await db.collection("users")
                .document(userId)
                .updateData(["isSuspended": shouldSuspend])
        } catch {
            print("❌ Failed to check report threshold: \(error.localizedDescription)")
        }
    }
}
