//
//  ContentView.swift
//  TrainMoreAccess Watch App
//
//  Created by Stanislaw Pusep on 2025-08-13.
//

import Combine
import Foundation
import SwiftUI
import UIKit

@MainActor
final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var lastUpdated: Date?

    private let API_ENDPOINT = "https://my.trainmore.nl/nox/v1/customerqrcode/"
    private let PUBLIC_FACILITY_GROUP = "BRANDEDAPPTMBTYDONOTDELETE-..."
    private let AUTH_TOKEN = "..."

    struct QRContentResponse: Decodable {
        let content: String?
    }

    func fetch() async {
        var req1 = URLRequest(url: URL(string: API_ENDPOINT)!)
        req1.httpMethod = "GET"
        req1.cachePolicy = .reloadIgnoringLocalCacheData
        req1.setValue("Dart/3.8 (dart:io) ios/Version 26.0 (Build 23A5308g)", forHTTPHeaderField: "user-agent")
        req1.setValue("3.72.1", forHTTPHeaderField: "x-nox-client-version")
        req1.setValue("APP_V5", forHTTPHeaderField: "x-nox-client-type")
        req1.setValue("en", forHTTPHeaderField: "accept-language")
        req1.setValue(PUBLIC_FACILITY_GROUP, forHTTPHeaderField: "x-public-facility-group")
        req1.setValue(AUTH_TOKEN, forHTTPHeaderField: "x-auth-token")

        do {
            let (jsonData, resp1) = try await URLSession.shared.data(for: req1)
            guard let http1 = resp1 as? HTTPURLResponse, (200..<300).contains(http1.statusCode) else {
                throw URLError(.badServerResponse)
            }
            let decoded = try JSONDecoder().decode(QRContentResponse.self, from: jsonData)
            let content = decoded.content ?? ""

            var comps = URLComponents(string: "https://api.qrserver.com/v1/create-qr-code/")!
            comps.queryItems = [
                .init(name: "data", value: content),
                .init(name: "format", value: "png"),
                .init(name: "margin", value: "20"),
                .init(name: "size", value: "500x500"),
            ]
            guard let qrURL = comps.url else { throw URLError(.badURL) }

            var req2 = URLRequest(url: qrURL)
            req2.httpMethod = "GET"
            req2.cachePolicy = .reloadIgnoringLocalCacheData

            let (pngData, resp2) = try await URLSession.shared.data(for: req2)
            guard let http2 = resp2 as? HTTPURLResponse, (200..<300).contains(http2.statusCode) else {
                throw URLError(.badServerResponse)
            }
            guard let uiImage = UIImage(data: pngData) else {
                throw URLError(.cannotDecodeContentData)
            }

            self.image = uiImage
            self.lastUpdated = Date()
        } catch {
            print("Image fetch failed:", error)
        }
    }
}


struct ContentView: View {
    @StateObject private var loader = ImageLoader()
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack() {
            Group {
                if let img = loader.image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                } else {
                    ProgressView("Loading…")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 20)

            if let ts = loader.lastUpdated {
                Text("Updated \(ts.formatted(date: .omitted, time: .standard))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .ignoresSafeArea(.all)
        .task { await loader.fetch() }
        .onReceive(timer) { _ in
            Task { await loader.fetch() }
        }
    }
}
