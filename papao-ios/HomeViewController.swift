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
    @IBOutlet weak var notificationBarButtonItem: UIBarButtonItem!
    
    var adoptionInfoView: UIView?
    var euthanasiaInfoView: UIView?
    var naturalDeathInfoView: UIView?
    var returnPetInfoView: UIView?

    let api = HttpHelper.init()

    var statistics: Statistics?
    var postSeries: [String: [Post]?] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        setPullToRefresh()
        
        // initialize scrollView
        horizontalScrollView.defaultMarginSettings = MarginSettings(leftMargin: 15, miniMarginBetweenItems: 8, miniAppearWidthOfLastItem: 24)
        horizontalScrollView.uniformItemSize = CGSize(width: 328, height: 184)
        // this must be called after changing any size or margin property of this class to get acurrate margin
        horizontalScrollView.setItemsMarginOnce()
        
        loadStat()
        loadTodayStat()
        loadPosts(postType: .SYSTEM)
        loadPosts(postType: .MISSING)
        loadPosts(postType: .ROADREPORT)
        loadPosts(postType: .PROTECTING)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationSetting()
        
        // 뱃지 카운트 한개 이상일 때 버튼이미지 변경
        if UIApplication.shared.applicationIconBadgeNumber > 0 {
            notificationBarButtonItem.image = UIImage.init(named: "iconNoticePush")
            notificationBarButtonItem.tintColor = .ppWarmPink
        } else {
            notificationBarButtonItem.image = UIImage.init(named: "iconNoticeDefault")
            notificationBarButtonItem.tintColor = .ppTextBlack
        }
    }
    
    func setNavigationSetting() {
        self.navigationController?.navigationBar.barTintColor = UIColor.ppBackgroundGray
        self.navigationController?.navigationBar.tintColor = UIColor.ppTextBlack
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.ppTextBlack]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = .default
    }
    
    func setPullToRefresh() {
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            let title = "당겨서 새로고침"
            refreshControl.attributedTitle = NSAttributedString(string: title)
            refreshControl.addTarget(self,
                                     action: #selector(refreshOptions(sender:)),
                                     for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
    }
    
    @objc private func refreshOptions(sender: UIRefreshControl) {
        let _ = horizontalScrollView.removeAllItems()
        loadStat()
        loadTodayStat()
        loadPosts(postType: .SYSTEM)
        loadPosts(postType: .MISSING)
        loadPosts(postType: .ROADREPORT)
        loadPosts(postType: .PROTECTING)
        sender.endRefreshing()
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
    
    func loadTodayStat() {
        // get statistics for today
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let today = Date()
        let parameters = ["beginDate": formatter.string(from: today), "endDate": formatter.string(from: today)]
        api.stats(parameters: parameters) { (result) in
            do {
                let statistics = try result.unwrap()
                self.updateCountLabel.text = String(describing: statistics.saveCount)
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
                let sortedPosts = postResponse.elements.flatMap{ $0 }
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
        view.layer.addSublayer(statisticsType.background(frame: CGRect(x: 0, y: 0, width: 328, height: 184)))
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
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
        pieLayer.addValues([PieElement(value: Float(100-rate), color: statisticsType.chartColors.0),
                            PieElement(value: Float(rate), color: statisticsType.chartColors.1)], animated: true)
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
            cell.postTypeImageView.image = UIImage.init(named: "iconShelter20")
            cell.postTypeLabel.text = PostType.SYSTEM.description
            cell.setPosts(posts: postSeries[PostType.SYSTEM.rawValue] ?? nil)
        case PostType.PROTECTING.index:
            cell.postTypeImageView.image = UIImage.init(named: "iconLost20")
            cell.postTypeLabel.text = PostType.PROTECTING.description
            cell.setPosts(posts: postSeries[PostType.PROTECTING.rawValue] ?? nil)
        case PostType.ROADREPORT.index:
            cell.postTypeImageView.image = UIImage.init(named: "iconReport20")
            cell.postTypeLabel.text = PostType.ROADREPORT.description
            cell.setPosts(posts: postSeries[PostType.ROADREPORT.rawValue] ?? nil)
        case PostType.MISSING.index:
            cell.postTypeImageView.image = UIImage.init(named: "iconReport20")
            cell.postTypeLabel.text = PostType.MISSING.description
            cell.setPosts(posts: postSeries[PostType.MISSING.rawValue] ?? nil)
        default:
            cell.postTypeImageView.image = UIImage.init(named: "iconShelter20")
            cell.postTypeLabel.text = PostType.SYSTEM.description
            cell.setPosts(posts: postSeries[PostType.SYSTEM.rawValue] ?? nil)
        }
        
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
