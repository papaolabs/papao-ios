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

enum CUDResult: Int {
    case success = 100
    case fail = -100
    case duplicated = -101
    case notFound = -102
    case unknown = 0

    var keyName: String {
        get { return String(describing: self).uppercased() }
    }
    
    init?(json: [String: Any]?) {
        guard let json = json,
            let code = json["code"] as? Int else {
            return nil
        }
        self.init(rawValue: code)
    }
}

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
    case createPost(parameters: Parameters)
    case deleteComment(commentId: String)
    case readPostsByPage(parameters: Parameters)
    case readPost(postId: String)
    case deletePost(postId: String)
    
    // Bookmark
    case readBookmarkByUserId(userId: String, parameters: Parameters)
    case registerBookmark(postId: String, userId: String)
    case cancelBookmark(postId: String, userId: String)
    case checkBookmark(postId: String, parameters: Parameters)
    case countBookmark(postId: String)
    
    // Comment
    case readComments(postId: String)
    case createComment(postId: String, parameters: Parameters)
    case setStatus(postId: String)
    
    // User
    case join(parameters: Parameters)
    case profile(userId: String)
    case setPush(parameters: Parameters)
    case getPushHistory(parameters: Parameters)
    
    // Stat
    case stats(parameters: Parameters)
    case postRanking(parameters: Parameters)

    static let baseURLString = "\(valueForAPIKey(keyname: "API_BASE_URL"))api/v1/"
    
    var method: HTTPMethod {
        switch self {
        case .readPostsByPage,
             .readPost,
             .readBookmarkByUserId,
             .checkBookmark,
             .countBookmark,
             .readComments,
             .stats,
             .postRanking:
            return .get
        case .createPost,
             .deleteComment,
             .deletePost,
             .registerBookmark,
             .cancelBookmark,
             .createComment,
             .setStatus,
             .join,
             .profile,
             .setPush,
             .getPushHistory:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .readPost(let postId):
            return "posts/\(postId)"
        case .createPost(_):
            return "posts"
        case .deletePost(let postId):
            return "posts/\(postId)"
        case .deleteComment(let commentId):
            return "posts/comments/\(commentId)"
        case .readPostsByPage(_):
            return "posts/pages"
        case .readBookmarkByUserId(let userId, _):
            return "posts/users/\(userId)/bookmarks"
        case .registerBookmark(let postId, _):
            return "posts/\(postId)/bookmarks"
        case .cancelBookmark(let postId, _):
            return "posts/\(postId)/bookmarks/cancel"
        case .checkBookmark(let postId, _):
            return "posts/\(postId)/bookmarks/check"
        case .countBookmark(let postId):
            return "posts/\(postId)/bookmarks/count"
        case .readComments(let postId), .createComment(let postId, _):
            return "posts/\(postId)/comments"
        case .setStatus(let postId):
            return "posts/\(postId)/state"
        case .join(_):
            return "users/join"
        case .profile(_):
            return "users/profile"
        case .setPush(_):
            return "users/push"
        case .getPushHistory(_):
            return "users/push/history"
        case .stats(_):
            return "stats"
        case .postRanking(_):
            return "stats/posts"
        }
    }
    
    // MARK: URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try Router.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .readPost(_), .deletePost(_), .deleteComment(_), .registerBookmark(_, _), .cancelBookmark(_, _), .countBookmark(_),
             .readComments(_), .createComment(_, _), .setStatus(_), .profile(_):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        case .createPost(let parameters), .join(let parameters), .setPush(let parameters), .getPushHistory(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        case .readPostsByPage(let parameters), .readBookmarkByUserId(_, let parameters), .checkBookmark(_, let parameters), .stats(let parameters), .postRanking(let parameters):
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)
        }
        
        return urlRequest
    }
}

enum ImageRouter: URLRequestConvertible {
    case upload(parameters: Parameters)
    
    static let baseURLString = "\(valueForAPIKey(keyname: "IMG_API_BASE_URL"))v1/"
    
    var method: HTTPMethod {
        switch self {
        case .upload(_):
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .upload(_):
            return "upload"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try ImageRouter.baseURLString.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .upload(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
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
    
    func readPosts(filter: Filter, completion: @escaping (ApiResult<PostResponse>) -> Void) {
        manager.request(Router.readPostsByPage(parameters: filter.toDict())).responseString { response in
            if let dict = response.value?.dictionaryFromJSON() {
                let postResponse = PostResponse(json: dict)
                completion(ApiResult{ return postResponse })
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
    
    // Bookmark
    func readBookmarkByUserId(userId: String, parameters: Parameters, completion: @escaping (ApiResult<PostResponse>) -> Void) {
        manager.request(Router.readBookmarkByUserId(userId: userId, parameters: parameters)).responseString { response in
            if let dict = response.value?.dictionaryFromJSON() {
                let postResponse = PostResponse(json: dict)
                completion(ApiResult{ return postResponse })
            } else {
                completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
            }
        }
    }
    
    func registerBookmark(postId: String, userId: String, completion: @escaping (ApiResult<Bool>) -> Void) {
        let router = Router.registerBookmark(postId: postId, userId: userId)
        if let url = router.urlRequest?.url {
            manager.request(url, method:router.method, parameters: [:], encoding: userId).responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    completion(ApiResult{ return json.boolValue })
                } else {
                    completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
                }
            }
        }
    }
    
    func cancelBookmark(postId: String, userId: String, completion: @escaping (ApiResult<Bool>) -> Void) {
        let router = Router.cancelBookmark(postId: postId, userId: userId)
        if let url = router.urlRequest?.url {
            manager.request(url, method:router.method, parameters: [:], encoding: userId).responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    completion(ApiResult{ return json.boolValue })
                } else {
                    completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
                }
            }
        }
    }
    
    func checkBookmark(postId: String, parameter: Parameters, completion: @escaping (ApiResult<Bool>) -> Void) {
        manager.request(Router.checkBookmark(postId: postId, parameters: parameter)).responseJSON { response in
            if let value = response.result.value {
                let json = JSON(value)
                completion(ApiResult{ return json.boolValue })
            } else {
                completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
            }
        }
    }
    
    func countBookmark(postId: String, completion: @escaping (ApiResult<Int>) -> Void) {
        manager.request(Router.countBookmark(postId: postId)).responseJSON { response in
            if let value = response.result.value {
                let json = JSON(value)
                completion(ApiResult{ return json.intValue })
            } else {
                completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
            }
        }
    }

    // Comment
    func readComments(postId: String, completion: @escaping (ApiResult<Comment>) -> Void) {
        manager.request(Router.readComments(postId: postId)).responseString { response in
            if let dict = response.value?.dictionaryFromJSON(), let comment = Comment(json: dict) {
                completion(ApiResult{ return comment })
            } else {
                completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
            }
        }
    }
    
    func postComment(postId: String, parameters: [String: AnyObject], completion: @escaping (ApiResult<[String: Any]>) -> Void) {
        let router = Router.createComment(postId: postId, parameters: parameters)
        if let url = router.urlRequest?.url {
            manager.request(url, method:router.method, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                if let value = response.result.value {
                    let userJson = JSON(value)
                    completion(ApiResult{ return userJson.dictionaryObject! })
                } else {
                    completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
                }
            }
        }
    }
    
    // User
    func join(parameters: [String:AnyObject], completion: @escaping (ApiResult<CUDResult>) -> Void) {
        let router = Router.join(parameters: parameters)
        if let url = router.urlRequest?.url {
            manager.request(url, method:router.method, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    if let result = CUDResult.init(json: json.dictionaryObject) {
                        completion(ApiResult{ return result })
                    } else {
                        completion(ApiResult{ return .unknown })
                    }
                } else {
                    completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
                }
            }
        }
    }
    
    func profile(userId: String, completion: @escaping (ApiResult<User?>) -> Void) {
        let router = Router.profile(userId: userId)
        if let url = router.urlRequest?.url {
            manager.request(url, method:router.method, parameters: [:], encoding: userId).responseJSON { response in
                if let value = response.result.value {
                    let userJson = JSON(value)
                    completion(ApiResult{ return User.init(json: userJson.dictionaryObject) })
                } else {
                    completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
                }
            }
        }
    }
    
    func setPush(parameters: [String:AnyObject], completion: @escaping (ApiResult<[String: Any]>) -> Void) {
        let router = Router.setPush(parameters: parameters)
        if let url = router.urlRequest?.url {
            manager.request(url, method:router.method, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                if let value = response.result.value {
                    let userJson = JSON(value)
                    completion(ApiResult{ return userJson.dictionaryObject! })
                } else {
                    completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
                }
            }
        }
    }
    
    func getPushHistory(userId: String, completion: @escaping (ApiResult<NotificationHistory>) -> Void) {
        let router = Router.getPushHistory(parameters: [:])
        if let url = router.urlRequest?.url {
            manager.request(url, method:router.method, parameters: [:], encoding: userId, headers: [:]).responseString { response in
                if let dict = response.value?.dictionaryFromJSON() {
                    let notificationHistory = NotificationHistory(json: dict)
                    completion(ApiResult{ return notificationHistory })
                } else {
                    completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
                }
            }
        }
    }
    
    // Stat
    func stats(parameters: Parameters, completion: @escaping (ApiResult<Statistics>) -> Void) {
        manager.request(Router.stats(parameters: parameters)).responseString { response in
            if let dict = response.value?.dictionaryFromJSON() {
                let statistics = Statistics(json: dict)
                completion(ApiResult{ return statistics })
            } else {
                completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
            }
        }
    }
    
    // Image
    func uploadImages(imageRequest: ImageRequest, completion: @escaping (ApiResult<ImageResponse>) -> Void) {
        let router = ImageRouter.upload(parameters: [:])
        let parameters = ["post_type" : imageRequest.postType.rawValue]
        if let url = router.urlRequest?.url {
            manager.upload(multipartFormData: { (multipartFormData) in
                for (key,value) in parameters {
                    if let value = value as? String {
                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                    }
                }
                
                for (index, element) in imageRequest.file.enumerated() {
                    if  let imageData = UIImageJPEGRepresentation(element, 0.6) {
                        multipartFormData.append(imageData, withName: "file", fileName: "image\(index).jpeg", mimeType: "image/jpeg")
                    }
                }
            }, to: url,
               method: .post,
               encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):

                    upload.uploadProgress(closure: { (progress) in
//                        print(progress)
                        // Todo: - 진행률 표시
                    })
                    
                    upload.responseJSON { response in
                        // If the request to get activities is succesfull, store them
                        if response.result.isSuccess{
//                            print(response.debugDescription)
                            if let value = response.result.value {
                                let imageResponseJson = JSON(value)
                                completion(ApiResult{ return ImageResponse(json: imageResponseJson.dictionaryObject!) })
                            }
                        } else {
//                            print(response.debugDescription)
                            completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])))
                        }
                    }
                case .failure(let encodingError):
//                    print(encodingError)
                    completion(ApiResult.Failure(error: NSError(domain: "com.papaolabs.papao-ios", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Encoding Error"])))
                }
            })
        }
    }
}

extension String: ParameterEncoding {
    // 단일 스트링 json 파라미터를 위한 extension
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: true)

        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    
        
        return request
    }
}
