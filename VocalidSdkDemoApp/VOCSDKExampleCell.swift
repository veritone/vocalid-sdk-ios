//
//  VOCSDKExampleCell.swift
//  BeSpokeDemoApp
//
//  Created by Rixing Wu on 11/2/18.
//  Copyright © 2018 vocalid. All rights reserved.
//

import Foundation
import UIKit


class VOCSDKExampleCell: UITableViewCell {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var apiView: UIView!
    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var downloadToken: UILabel!
    @IBOutlet weak var streamSynthesis: UIButton!
    @IBOutlet weak var localSynthesis: UIButton!
    @IBOutlet weak var downloadVoice: UIButton!
    @IBOutlet weak var downloadLicense: UIButton!
    
    @IBOutlet weak var voiceDownloadInfo: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        localView.isHidden = true
        apiView.isHidden = false
        voiceDownloadInfo.text = ""
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
