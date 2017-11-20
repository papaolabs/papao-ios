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
    @IBOutlet weak var updateCountLabel: UILabel!
    @IBOutlet var horizontalScrollView: ASHorizontalScrollView!

    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        horizontalScrollView.defaultMarginSettings = MarginSettings(leftMargin: 15, miniMarginBetweenItems: 8, miniAppearWidthOfLastItem: 24)
        horizontalScrollView.uniformItemSize = CGSize(width: 328, height: 184)
        //this must be called after changing any size or margin property of this class to get acurrate margin
        horizontalScrollView.setItemsMarginOnce()
        for _ in 0...3{
            let view = UIView(frame: CGRect.zero)
            view.backgroundColor = UIColor.purple
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
            pieLayer.addValues([PieElement(value: 8.0, color: UIColor.init(named: "darkishPink") ?? UIColor.purple),
                                PieElement(value: 2.0, color: UIColor.init(named: "lightPink") ?? UIColor.magenta)], animated: true)
            view.layer.addSublayer(pieLayer)
            
            formatter.dateFormat = "yyyy년 MM월 dd일"
            // Todo: 날짜 변경
            let dateString = "\(formatter.string(from: Date()))"
            let dateLabel = UILabel.init(frame: CGRect.init(x: 178, y: 106, width: 150, height: 22))
            dateLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            dateLabel.textColor = .white
            dateLabel.text = dateString
            view.addSubview(dateLabel)
            
            let adoptionString = "입양률 14%"
            let adoptionLabel = UILabel.init(frame: CGRect.init(x: 178, y: 128, width: 125, height: 30))
            adoptionLabel.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
            adoptionLabel.textColor = .white
            adoptionLabel.text = adoptionString
            view.addSubview(adoptionLabel)
            
            horizontalScrollView.addItem(view)
        }
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
            cell.postTypeLabel.text = PostType.SYSTEM.detailDescription
        case PostType.PROTECTING.index:
            cell.postTypeLabel.text = PostType.PROTECTING.detailDescription
        case PostType.ROADREPORT.index:
            cell.postTypeLabel.text = PostType.ROADREPORT.detailDescription
        case PostType.MISSING.index:
            cell.postTypeLabel.text = PostType.MISSING.detailDescription
        default:
            cell.postTypeLabel.text = PostType.SYSTEM.detailDescription
        }
        
//        cell.setPost(post: post)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
