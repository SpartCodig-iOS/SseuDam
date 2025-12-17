//
//  BasicSettingView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/30/25.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

// MARK: - 기본 설정 섹션
struct BasicSettingView: View {
    @Bindable var store: StoreOf<BasicSettingFeature>

    public init(store: StoreOf<BasicSettingFeature>) {
        self.store = store
    }

    private var displayTitle: String {
        let trimmed = store.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? store.travel.title : trimmed
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(
                title: "기본 설정",
                isOWner: store.isOwner,
                isEditing: .constant(false),
                editAction: {
                    store.send(.editButtonTapped)
                }
            )

            VStack(alignment: .leading, spacing: 0) {
                basicInfoSection

                Divider()
                    .foregroundStyle(Color.gray1)
                    .padding(.vertical, 16)

                dateSection

                Divider()
                    .foregroundStyle(Color.gray1)
                    .padding(.vertical, 16)

                countrySection

                Divider()
                    .foregroundStyle(Color.gray1)
                    .padding(.vertical, 16)

                if store.selectedCountryCode != "KR" {
                    exchangeSection

                    Divider()
                        .foregroundStyle(Color.gray1)
                        .padding(.vertical, 16)
                }

                inviteSection
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.appWhite)))
        }
    }

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("여행 이름")
                .font(.app(.body, weight: .medium))
                .foregroundColor(.gray7)

            Text(displayTitle)
                .font(.app(.title3, weight: .medium))
                .foregroundStyle(Color.appBlack)
        }
        .padding(.horizontal, 10)
    }

    private var dateSection: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("시작일")
                    .font(.app(.body, weight: .medium))
                    .foregroundColor(.gray7)

                Text(format(store.startDate))
                    .font(.app(.title3, weight: .medium))
                    .foregroundStyle(Color.appBlack)
            }
            .padding(.horizontal, 10)

            Spacer()

            Divider()
                .frame(width: 1, height: 46)
                .foregroundStyle(Color.gray1)

            VStack(alignment: .leading, spacing: 8) {
                Text("종료일")
                    .font(.app(.body, weight: .medium))
                    .foregroundColor(.gray7)

                Text(format(store.endDate))
                    .font(.app(.title3, weight: .medium))
                    .foregroundStyle(Color.appBlack)
            }
            .padding(.horizontal, 10)

            Spacer()
        }
    }

    private var countrySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("국가")
                .font(.app(.body, weight: .medium))
                .foregroundColor(.gray7)

            Text(store.selectedCountryName ?? "-")
                .font(.app(.title3, weight: .medium))
                .foregroundStyle(Color.appBlack)
        }
        .padding(.horizontal, 10)
    }

    private var exchangeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("화폐/환율")
                .font(.app(.body, weight: .medium))
                .foregroundColor(.gray7)

            HStack(spacing: 0) {
                Text("1 \(store.selectedCurrency ?? "-")")
                    .font(.app(.title3, weight: .medium))
                    .foregroundStyle(Color.appBlack)

                Spacer()

                HStack(spacing: 4) {
                    Text(store.exchangeRate)
                        .multilineTextAlignment(.trailing)
                        .font(.app(.body, weight: .medium))
                        .foregroundColor(Color.appBlack)

                    Text("KRW")
                        .font(.app(.body, weight: .medium))
                        .foregroundColor(Color.appBlack)
                }
            }
        }
        .padding(.horizontal, 10)
    }

    private var inviteSection: some View {
        Button {
            guard let inviteCode = store.travel.inviteCode else { return }
            InviteCodeHelper.copyToClipboard(inviteCode)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text("초대 코드")
                    .font(.app(.body, weight: .medium))
                    .foregroundColor(.gray7)

                HStack(spacing: 8) {
                    Image(assetName: "files")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 18)
                        .foregroundStyle(Color.gray8)

                    Text(store.travel.inviteCode ?? "초대코드 없음")
                        .font(.app(.title3, weight: .medium))
                        .foregroundStyle(Color.appBlack)

                    Spacer()

                    Button {
                        if let deepLink = store.travel.deepLink, let url = URL(string: deepLink) {
                            InviteCodeHelper.shareDeepLink(url)
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary500)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}
