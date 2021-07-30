//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] in
			switch $0 {
			case .failure:
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			case let .success((data, response)):
				guard let result = self?.feedLoaderResult(for: data, response: response) else { return }
				completion(result)
			}
		}
	}

	// Helper

	private func feedLoaderResult(for data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200 else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		do {
			let item = try JSONDecoder().decode(FeedImageResponse.self, from: data)
			return .success(item.feedImages)
		} catch {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}
}

private struct FeedImageResponse: Decodable {
	struct FeedImageItem: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
	}

	let items: [FeedImageItem]
}

private extension FeedImageResponse {
	var feedImages: [FeedImage] {
		items.map({ FeedImage(id: $0.image_id, description: $0.image_desc, location: $0.image_loc, url: $0.image_url) })
	}
}
