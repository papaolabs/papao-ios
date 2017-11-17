//
//  HttpHelper.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 12..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum ApiResult<Value> {
    case Success(value: Value)
    case Failure(error: NSError)
    
    init(_ f: () throws -> Value) {
        do {
            let value = try f()
            self = .Success(value: value)
        } catch let error as NSError {
            self = .Failure(error: error)
        }
    }
    
    func unwrap() throws -> Value {
        switch self {
        case .Success(let value):
            return value
        case .Failure(let error):
            throw error
        }
    }
}

import Alamofire

enum Router: URLRequestConvertible {
    // Post
    case readPosts()
    case createPost(parameters: Parameters)
    case deleteComment(commentId: String)
    case readPostsByPage(parameters: Parameters)
    case readPost(postId: String)
    case deletePost(postId: String)
    case registerBookmark(postId: String)
    case cancelBookmark(postId: String)
    case checkBookmark(postId: String)
    case countBookmark(postId: String)
    case readComments(postId: String)
    case createComment(postId: String)
    case setStatus(postId: String)
    
    // User
    case join(parameters: Parameters)
    case setPush(parameters: Parameters)

    static let baseURLString = "\(valueForAPIKey(keyname: "API_BASE_URL"))api/v1/"
    
    var method: HTTPMethod {
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
             .setStatus,
             .join,
             .setPush:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .readPost(let postId):
            return "posts/\(postId)"
        case .readPosts(), .createPost(_):
            return "posts"
        case .deletePost(let postId):
            return "posts/\(postId)"
        case .deleteComment(let commentId):
            return "posts/comments/\(commentId)"
        case .readPostsByPage(_):
            return "posts/pages"
        case .registerBookmark(let postId):
            return "posts/\(postId)/bookmarks"
        case .cancelBookmark(let postId):
            return "posts/\(postId)/bookmarks/cancel"
        case .checkBookmark(let postId):
            return "posts/\(postId)/bookmarks/check"
        case .countBookmark(let postId):
            return "posts/\(postId)/bookmarks/count"
        case .readComments(let postId), .createComment(let postId):
            return "posts/\(postId)/comments"
        case .setStatus(let postId):
            return "posts/\(postId)/state"
        case .join(_):
            return "users/join"
        case .setPush(_):
            return "users/push"
        }
    }
    
    // MARK: URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try Router.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .readPost(_), .readPosts(), .deletePost(_), .deleteComment(_), .registerBookmark(_), .cancelBookmark(_),
             .checkBookmark(_), .countBookmark(_), .readComments(_), .createComment(_), .setStatus(_):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        case .createPost(let parameters), .join(let parameters), .setPush(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        case .readPostsByPage(let parameters):
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)
        }
        
        return urlRequest
    }
}

final class HttpHelper {
    private let manager: SessionManager
    
    init(manager: SessionManager = SessionManager.default) {
        self.manager = manager
    }
    
    // MARK: - Public Methods
    func readPost(postId: Int, completion: @escaping (ApiResult<PostDetail>) -> Void) {
        manager.request(Router.readPost(postId: "\(postId)")).responseString { response in
            if let dict = response.value?.dictionaryFromJSON(), let postDetail = PostDetail(json: dict) {
                completion(ApiResult{ return postDetail })
            } else {
                completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
            }
        }
    }
    
    func readPosts(postType: PostType, completion: @escaping (ApiResult<[Post]>) -> Void) {
        manager.request(Router.readPostsByPage(parameters: ["postType": postType])).responseJSON { response in
            print(response)
            if let value = response.result.value {
                let postJsonList = JSON(value)
                let posts = postJsonList.arrayValue.flatMap({ (json) -> Post? in
                    // Todo: - 강제 옵셔널 캐스팅 처리
                    return Post.init(json: json.dictionaryObject!)!
                })
                completion(ApiResult{ return posts })
            } else {
                completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
            }
        }
    }
    
    func createPost(postRequest: PostRequest, completion: @escaping (ApiResult<PostDetail>) -> Void) {
        manager.request(Router.createPost(parameters: postRequest.toDict())).responseString { response in
            if let dict = response.value?.dictionaryFromJSON(), let postDetail = PostDetail(json: dict) {
                completion(ApiResult{ return postDetail })
            } else {
                completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
            }
        }
    }
    
    // User
    func join(parameters: [String:AnyObject], completion: @escaping (ApiResult<User>) -> Void) {
        let router = Router.join(parameters: parameters)
        if let url = router.urlRequest?.url {
            manager.request(url, method:router.method, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                if let value = response.result.value {
                    let userJson = JSON(value)
                    let user = User.init(json: userJson.dictionaryObject!)!
                    completion(ApiResult{ return user })
                } else {
                    completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
                }
            }
        }
    }
}

