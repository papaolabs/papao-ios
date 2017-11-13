//
//  HttpHelper.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 12..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation
import Alamofire

enum Endpoint {
    case readPosts()
    case createPost()
    case deleteComment(commentId: String)
    case readPostsByPage()
    case readPost(postId: String)
    case deletePost(postId: String)
    case registerBookmark(postId: String)
    case cancelBookmark(postId: String)
    case checkBookmark(postId: String)
    case countBookmark(postId: String)
    case readComments(postId: String)
    case createComment(postId: String)
    case setStatus(postId: String)
    
    // MARK: - Public Properties
    var method: Alamofire.HTTPMethod {
        switch self {
        case .readPosts,
             .readPostsByPage,
             .readPost,
             .checkBookmark,
             .countBookmark,
             .readComments:
            return .get
        case .createPost,
             .deleteComment,
             .deletePost,
             .registerBookmark,
             .cancelBookmark,
             .createComment,
             .setStatus:
            return .post
        }
    }
    
    var url: URL {
        let baseUrl = URL.init(string: valueForAPIKey(keyname: "API_BASE_URL"))!
        let baseUrlWithPrefix = baseUrl.appendingPathComponent("api/v1/")
        switch self {
        case .readPost(let postId):
            return baseUrlWithPrefix.appendingPathComponent("posts/\(postId)")
        case .readPosts(), .createPost():
            return baseUrlWithPrefix.appendingPathComponent("posts")
        case .deletePost(let postId):
            return baseUrlWithPrefix.appendingPathComponent("posts/\(postId)")
        case .deleteComment(let commentId):
            return baseUrlWithPrefix.appendingPathComponent("posts/comments/\(commentId)")
        case .readPostsByPage():
            return baseUrlWithPrefix.appendingPathComponent("posts/pages")
        case .registerBookmark(let postId):
            return baseUrlWithPrefix.appendingPathComponent("posts/\(postId)/bookmarks")
        case .cancelBookmark(let postId):
            return baseUrlWithPrefix.appendingPathComponent("posts/\(postId)/bookmarks/cancel")
        case .checkBookmark(let postId):
            return baseUrlWithPrefix.appendingPathComponent("posts/\(postId)/bookmarks/check")
        case .countBookmark(let postId):
            return baseUrlWithPrefix.appendingPathComponent("posts/\(postId)/bookmarks/count")
        case .readComments(let postId), .createComment(let postId):
            return baseUrlWithPrefix.appendingPathComponent("posts/\(postId)/comments")
        case .setStatus(let postId):
            return baseUrlWithPrefix.appendingPathComponent("posts/\(postId)/state")
        }
    }
}

class HttpHelper {
    
}
