//
//  HomeViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 14..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import AccountKit
import ASHorizontalScrollView
import MagicPie

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var updateCountLabel: UILabel!
    @IBOutlet var horizontalScrollView: ASHorizontalScrollView!

    let api = HttpHelper.init()

    var statistics: Statistics?
    var postSeries: [String: [Post]?] = [:]

    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize scrollView
        horizontalScrollView.defaultMarginSettings = MarginSettings(leftMargin: 15, miniMarginBetweenItems: 8, miniAppearWidthOfLastItem: 24)
        horizontalScrollView.uniformItemSize = CGSize(width: 328, height: 184)
        // this must be called after changing any size or margin property of this class to get acurrate margin
        horizontalScrollView.setItemsMarginOnce()
        
        loadStat()
        loadPosts(postType: .SYSTEM)
        loadPosts(postType: .MISSING)
        loadPosts(postType: .ROADREPORT)
        loadPosts(postType: .PROTECTING)
    }
    
    func loadStat() {
        // get date of 3 month ago
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let beginDate = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        let endDate = Date()
        let parameters = ["beginDate": formatter.string(from: beginDate), "endDate": formatter.string(from: endDate)]
        
        api.stats(parameters: parameters) { (result) in
            do {
                let statistics = try result.unwrap()
                self.createStatView(statistics: statistics)
            } catch {
                print(error)
            }
        }
    }
    
    func loadPosts(postType: PostType) {
        let filter = Filter.init(postTypes: [postType])
        api.readPosts(filter: filter, completion: { (result) in
            do {
                let postResponse = try result.unwrap()
                let sortedPosts = postResponse.elements.sorted(by: { (post1, post2) -> Bool in
                    if let post1 = post1?.hitCount, let post2 = post2?.hitCount {
                        return post1 >= post2
                    } else {
                        return true
                    }
                }).flatMap { $0 }
                // assign posts to dictionary
                self.postSeries[postType.rawValue] = sortedPosts  // 3개 이하인 경우처리?
                // reload table
                self.tableView.reloadData()
            } catch {
                print(error)
            }
        })
    }
    
    func createStatView(statistics: Statistics) {
        updateCountLabel.text = String(describing: statistics.saveCount)
        
        let adoptionRate = statistics.getRate(statisticsType: .adoption)
        let euthanasiaRate = statistics.getRate(statisticsType: .euthanasia)
        let naturalDeathRate = statistics.getRate(statisticsType: .naturalDeath)
        let returnRate = statistics.getRate(statisticsType: .returnPet)
        
        let adoptionInfoView = infoView(statisticsType: .adoption, rate: adoptionRate, updateDate: statistics.endDate)
        horizontalScrollView.addItem(adoptionInfoView)
        let euthanasiaInfoView = infoView(statisticsType: .euthanasia, rate: euthanasiaRate, updateDate: statistics.endDate)
        horizontalScrollView.addItem(euthanasiaInfoView)
        let naturalDeathInfoView = infoView(statisticsType: .naturalDeath, rate: naturalDeathRate, updateDate: statistics.endDate)
        horizontalScrollView.addItem(naturalDeathInfoView)
        let returnPetInfoView = infoView(statisticsType: .returnPet, rate: returnRate, updateDate: statistics.endDate)
        horizontalScrollView.addItem(returnPetInfoView)
    }
    
    func infoView(statisticsType: StatisticsType, rate: Int, updateDate: Date) -> UIView {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.init(named: statisticsType.backgroundColorString) ?? .purple
        view.setRadius(radius: 8)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let title = "\(formatter.string(from: Date())) 업데이트 기준"
        let titleLabel = UILabel.init(frame: CGRect.init(x: 18, y: 8, width: 150, height: 16))
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.text = title
        view.addSubview(titleLabel)
        
        let pieLayer = PieLayer()
        pieLayer.cornerRadius = 107/2
        pieLayer.masksToBounds = true
        pieLayer.frame = CGRect.init(x: 33, y: 46, width: 107, height: 107)
        pieLayer.addValues([PieElement(value: Float(100-rate), color: UIColor.init(named: statisticsType.chartColorString.0) ?? UIColor.purple),
                            PieElement(value: Float(rate), color: UIColor.init(named: statisticsType.chartColorString.1) ?? UIColor.magenta)], animated: true)
        view.layer.addSublayer(pieLayer)
        
        let dateString = "최근 3개월 간"
        let dateLabel = UILabel.init(frame: CGRect.init(x: 178, y: 106, width: 150, height: 22))
        dateLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        dateLabel.textColor = .white
        dateLabel.text = dateString
        view.addSubview(dateLabel)
        
        let rateInfoString = "\(statisticsType.description) \(String(describing: rate))%"
        let rateInfoLabel = UILabel.init(frame: CGRect.init(x: 178, y: 128, width: 150, height: 30))
        rateInfoLabel.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        rateInfoLabel.textColor = .white
        rateInfoLabel.text = rateInfoString
        view.addSubview(rateInfoLabel)
        
        return view
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostType.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 234
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "homeCell",
                                                                    for: indexPath) as! HomeTableViewCell
        let row = indexPath.row;
        switch row {
        case PostType.SYSTEM.index:
            cell.postTypeLabel.text = PostType.SYSTEM.description
            cell.setPosts(posts: postSeries[PostType.SYSTEM.rawValue] ?? nil)
        case PostType.PROTECTING.index:
            cell.postTypeLabel.text = PostType.PROTECTING.description
            cell.setPosts(posts: postSeries[PostType.PROTECTING.rawValue] ?? nil)
        case PostType.ROADREPORT.index:
            cell.postTypeLabel.text = PostType.ROADREPORT.description
            cell.setPosts(posts: postSeries[PostType.ROADREPORT.rawValue] ?? nil)
        case PostType.MISSING.index:
            cell.postTypeLabel.text = PostType.MISSING.description
            cell.setPosts(posts: postSeries[PostType.MISSING.rawValue] ?? nil)
        default:
            cell.postTypeLabel.text = PostType.SYSTEM.description
            cell.setPosts(posts: postSeries[PostType.SYSTEM.rawValue] ?? nil)
        }
        
//        cell.setPost(post: post)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row;
        switch row {
        case PostType.SYSTEM.index:
            self.tabBarController?.selectedIndex = PostType.SYSTEM.index+1
        case PostType.PROTECTING.index, PostType.ROADREPORT.index:
            self.tabBarController?.selectedIndex = PostType.ROADREPORT.index+1
        case PostType.MISSING.index:
            self.tabBarController?.selectedIndex = PostType.MISSING.index+1
        default:
            self.tabBarController?.selectedIndex = PostType.SYSTEM.index+1
        }
    }
}
