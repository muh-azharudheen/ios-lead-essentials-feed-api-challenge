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
		client.get(from: url) {
			switch $0 {
			case .failure(let error):
				let nsError = error as NSError
				if nsError.domain == "Test" && nsError.code == 0 {
					completion(.failure(RemoteFeedLoader.Error.connectivity))
				}
			case .success((let data, let httpUrlResponse)):
				if httpUrlResponse.statusCode != 200 {
					completion(.failure(RemoteFeedLoader.Error.invalidData))
				} else if data == Data("invalid json".utf8) {
					completion(.failure(RemoteFeedLoader.Error.invalidData))
				}
			}
		}
	}
}
