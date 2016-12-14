//
//  AHClassModel.swift
//  Gank
//
//  Created by AHuaner on 2016/12/13.
//  Copyright © 2016年 CoderAhuan. All rights reserved.
//

let _idKey = "_id"
let descKey = "desc"
let createdAtKey = "createdAt"
let imagesKey = "images"
let urlKey = "url"
let typeKey = "type"
let userKey = "who"

enum AHImageType {
    case noImage, oneImage, moreImage
}

let timeLableH: CGFloat = 20

import UIKit
import SwiftyJSON

class AHClassModel: NSObject {
    var id: String?
    
    var createdAt: String?
    
    var desc: String?
    
    var url: String?
    
    var user: String?
    
    var images: [String]?
    
    var type: String?
    
    var imageFrame: CGRect = CGRect.zero
    var imageH: CGFloat = 0
    var imageW: CGFloat = 0
    
    var cellMargin: CGFloat = 10
    
    // 默认是没有图片
    var imageType: AHImageType = AHImageType.noImage
    
    fileprivate var _cellH: CGFloat?
    // cell的整体高度
    var cellH: CGFloat {
        if _cellH == nil {
            let maxSize = CGSize(width: kScreen_W - 2 * cellMargin, height: CGFloat(MAXFLOAT))
            
            // 文字的高度
            let descTextH = desc?.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 13)], context: nil).size.height
            
            _cellH = cellMargin + descTextH! + cellMargin
            
            // 一张图片的高度
            if self.imageType == AHImageType.oneImage {
                if self.imageW >= self.imageH {
                    let showImageW: CGFloat = maxSize.width * 0.62
                    let showImageH: CGFloat = self.imageH * showImageW / self.imageW
                    let showImageY = descTextH! + 2 * cellMargin
                    let showImageX = cellMargin
                    self.imageFrame = CGRect(x: showImageX, y: showImageY, width: showImageW, height: showImageH)
                    
                    _cellH = _cellH! + showImageH + cellMargin
                } else {
                    let showImageH: CGFloat = maxSize.width * 0.62
                    let showImageW: CGFloat = self.imageW * showImageH / self.imageH
                    let showImageY = descTextH! + 2 * cellMargin
                    let showImageX = cellMargin
                    self.imageFrame = CGRect(x: showImageX, y: showImageY, width: showImageW, height: showImageH)
                    
                    _cellH = _cellH! + showImageH + cellMargin
                }
            }
            
            // 有多张图片, colectionView的高度
            if self.imageType == AHImageType.moreImage {
                
            }
            
            // 底部时间的高度
            _cellH = _cellH! + timeLableH
        }
        return _cellH!
    }
    
    init(dict: JSON) {
        super.init()
        for (index, subJson) : (String, JSON) in dict {
            switch index {
            case _idKey:
                self.id = subJson.string
            case descKey:
                self.desc = subJson.string
            case createdAtKey:
                self.createdAt = subJson.string
            case urlKey:
                self.url = subJson.string
            case typeKey:
                self.type = subJson.string
            case userKey:
                self.user = subJson.string
            case imagesKey:
                self.images = (subJson.object as AnyObject) as? [String]
            default: break
            }
        }
        
        if let images = self.images {
            if images.count == 1 {
                self.imageType = AHImageType.oneImage
            } else {
                self.imageType = AHImageType.moreImage
            }
        }
    }
}