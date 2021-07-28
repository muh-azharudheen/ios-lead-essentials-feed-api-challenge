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
			case let .failure(error):
				if let result = self?.feedLoaderResult(for: error as NSError) {
					completion(result)
				}
			case let .success((data, response)):
				if let result = self?.feedLoaderResult(for: data, response: response) {
					completion(result)
				}
			}
		}
	}

	// Helper
	func feedLoaderResult(for error: NSError) -> FeedLoader.Result? {
		guard error == NSError(domain: "Test", code: 0) else { return nil }
		return .failure(RemoteFeedLoader.Error.connectivity)
	}

	func feedLoaderResult(for data: Data, response: HTTPURLResponse) -> FeedLoader.Result? {
		guard response.statusCode == 200 else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		guard data != Data("invalid json".utf8) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return nil
	}
}
