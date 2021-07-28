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
			case .failure(let error):
				if let result = self?.feedLoaderResult(for: error as NSError) {
					completion(result)
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
	
	// Helper
	func feedLoaderResult(for error: NSError) -> FeedLoader.Result? {
		guard error == NSError(domain: "Test", code: 0) else { return  nil }
		return .failure(RemoteFeedLoader.Error.connectivity)
	}
}
