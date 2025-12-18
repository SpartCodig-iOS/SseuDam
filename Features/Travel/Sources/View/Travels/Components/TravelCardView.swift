//
//  TravelCardView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/20/25.
//

import SwiftUI
import DesignSystem
import Domain

struct TravelCardView: View {
    let travel: Travel

    private var ddayStatus: DDayStatus {
        let today = Calendar.current.startOfDay(for: Date())
        let startDay = Calendar.current.startOfDay(for: travel.startDate)
        let endDay = Calendar.current.startOfDay(for: travel.endDate)

        if today < startDay {
            let diff = Calendar.current.dateComponents([.day], from: today, to: startDay).day ?? 0
            return .upcoming(diff)
        } else if today <= endDay {
            return .today
        } else {
            return .finished
        }
    }

    private var dateRangeText: String {
        let startDateFormatter = DateFormatter()
        startDateFormatter.dateFormat = "yyyy.MM.dd"

        let endDateFormatter = DateFormatter()
        endDateFormatter.dateFormat = "MM.dd"

        return "\(startDateFormatter.string(from: travel.startDate)) - \(endDateFormatter.string(from: travel.endDate))"
    }

    private var memberCountText: String {
        "\(travel.members.count)명"
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(ddayStatus.color)

            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appWhite)
                .offset(x: 5)

            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text(ddayStatus.text)
                        .font(.app(.caption1, weight: .medium))
                        .foregroundColor(Color.primary500)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(Color.primary100)
                        )

                    Text(travel.title)
                        .font(.app(.title3, weight: .semibold))
                        .foregroundColor(Color.appBlack)

                    HStack(spacing: 0) {
                        Image(assetName: "calendar")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 18)
                            .padding(.trailing, 4)

                        Text(dateRangeText)
                            .font(.app(.body, weight: .medium))
                            .foregroundStyle(Color.gray8)
                            .padding(.trailing, 5)

                        Divider()
                            .frame(width: 1, height: 16)
                            .foregroundStyle(Color.gray2)
                            .padding(.trailing, 6)

                        Image(assetName: "users")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 18)
                            .padding(.trailing, 4)

                        Text(memberCountText)
                            .font(.app(.body, weight: .medium))
                            .foregroundStyle(Color.gray8)
                    }
                }
                .padding(20)

                Spacer()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

extension TravelCardView {
    private enum DDayStatus {
        case upcoming(Int)
        case today
        case finished

        var text: String {
            switch self {
            case .upcoming(let day): return "D-\(day)"
            case .today: return "D-Day"
            case .finished: return "완료"
            }
        }

        var color: Color {
            switch self {
            case .today:
                return Color.primary300
            case .finished:
                return Color.primary500
            case .upcoming:
                return Color.primary100
            }
        }
    }
}

#Preview {
    TravelCardView(travel: Travel(
        id: "1",
        title: "도쿄 여행",
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 3),
        countryCode: "JP",
        koreanCountryName: "일본",
        baseCurrency: "KRW",
        baseExchangeRate: 1300,
        destinationCurrency: "USD",
        inviteCode: "123",
        status: .active,
        role: "owner",
        createdAt: Date(),
        ownerName: "민희",
        members: [],
        currencies: ["USD"]
    ))
}
