//
//  MailComposeView.swift
//  DesignSystem
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import MessageUI

public struct MailComposeView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss

    public let recipients: [String]
    public let subject: String
    public let messageBody: String
    public let isHTML: Bool

    public init(
        recipients: [String],
        subject: String,
        messageBody: String,
        isHTML: Bool = false
    ) {
        self.recipients = recipients
        self.subject = subject
        self.messageBody = messageBody
        self.isHTML = isHTML
    }

    public func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = context.coordinator
        mailComposer.setToRecipients(recipients)
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(messageBody, isHTML: isHTML)
        return mailComposer
    }

    public func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // No update needed
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailComposeView

        init(_ parent: MailComposeView) {
            self.parent = parent
        }

        public func mailComposeController(_ controller: MFMailComposeViewController,
                                         didFinishWith result: MFMailComposeResult,
                                         error: Error?) {
            parent.dismiss()
        }
    }
}

// MARK: - Mail Availability Check
public extension MailComposeView {
    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
}