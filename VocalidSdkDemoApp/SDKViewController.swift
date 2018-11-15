//
//  SDKViewController.swift
//  BeSpokeDemoApp
//
//  Created by Rixing Wu on 10/30/18.
//  Copyright © 2018 vocalid. All rights reserved.
//

import UIKit
import AVKit
import VocalidSdk


class SDKViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var tableView: UITableView!
    
    var voiceResults = [VoiceInfo]()
    var sdk: VocalidSdk!
    var engine: VOCTTSEngine?
    var player : AVAudioPlayer?
    
    // to generate a token please visit
    // https://portal.vocalid.ai/api/docs/index.html#authentication
    var token: String = ""
    
    var greenColor = UIColor(red: 88/255.0, green: 192/255.0, blue: 164/255.0, alpha: 1)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        sdk = VocalidSdk.newInstance(bearerToken: token)

        self.engine = sdk.getEngine()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sdk.getApiVoices { (_voiceInfos, _error) in
            if let error = _error {
                print(error.localizedDescription)
                return
            }
            guard let voiceInfos = _voiceInfos else {
                print("no voice info fetched")
                return
            }
            self.voiceResults = voiceInfos
        
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    
    }
    
    
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voiceResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! VOCSDKExampleCell
        let voiceResult = self.voiceResults[indexPath.row]
        
        cell.segmentControl.tag = indexPath.row
        cell.localSynthesis.tag = indexPath.row
        cell.downloadLicense.tag = indexPath.row
        cell.downloadVoice.tag = indexPath.row
        cell.streamSynthesis.tag = indexPath.row
        cell.localSynthesis.addTarget(self, action: #selector(localSynthesis(sender:)), for: .touchUpInside)
        cell.downloadLicense.addTarget(self, action: #selector(downloadLicense(sender:)), for: .touchUpInside)
        cell.downloadVoice.addTarget(self, action: #selector(downloadVoice(sender:)), for: .touchUpInside)
        cell.streamSynthesis.addTarget(self, action: #selector(streamSynthesis(sender:)), for: .touchUpInside)
        cell.segmentControl.addTarget(self, action: #selector(segmentChanged(sender:)), for: .valueChanged)
        
        cell.downloadToken.text = "\(voiceResult.fileName)"
        
        if !voiceResult.isStreamable {
            cell.streamSynthesis.backgroundColor = UIColor.lightGray
            cell.streamSynthesis.isUserInteractionEnabled = false
            cell.streamSynthesis.setTitle("No Stream Available", for: .normal)
        }
        
        if !voiceResult.isDownloadable {
            cell.downloadVoice.backgroundColor = UIColor.lightGray
            cell.downloadVoice.isUserInteractionEnabled = false
            cell.downloadVoice.setTitle("No Voice Available", for: .normal)
            cell.downloadLicense.backgroundColor = UIColor.lightGray
            cell.downloadLicense.isUserInteractionEnabled = false
            cell.downloadLicense.setTitle("No License Available", for: .normal)
        }
        
        if voiceResult.isDownloaded {
            cell.downloadVoice.setTitleColor(greenColor, for: .normal)
        }
        if voiceResult.isDownloaded {
            cell.downloadLicense.setTitleColor(greenColor, for: .normal)
        }
    
        return cell
    }
    
    


    @objc func segmentChanged(sender: UISegmentedControl) {
        let cell = tableView.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as! VOCSDKExampleCell
        if sender.selectedSegmentIndex == 0{
            cell.apiView.isHidden = false
            cell.localView.isHidden = true
        }else{
            cell.localView.isHidden = false
            cell.apiView.isHidden = true
        }
    }
    
    
    
    @objc func downloadVoice(sender: UIButton) {
        let voiceResult = self.voiceResults[sender.tag]
        let cell = tableView.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as! VOCSDKExampleCell

        if voiceResult.isDownloadable{
            sdk.downloadVoiceFile(voiceInfo: voiceResult) { (sucess, error) in
                DispatchQueue.main.async {
                    if sucess {
                        cell.downloadVoice.setTitleColor(self.greenColor, for: .normal)
                        cell.voiceDownloadInfo.text = "Voice downloaded"
                    }else {
                    
                        cell.voiceDownloadInfo.text = "Error downloading voice"
                    }
                }
            }
            
        }
    }
    
    
    

    @objc func downloadLicense(sender: UIButton){
        let voiceResult = self.voiceResults[sender.tag]
        let cell = tableView.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as! VOCSDKExampleCell
        if voiceResult.isDownloadable {
            sdk.downloadLicenseFile(voiceInfo: voiceResult) { (sucess, error) in
                DispatchQueue.main.async {
                    if sucess {
                        cell.downloadLicense.setTitleColor(self.greenColor, for: .normal)
                        cell.voiceDownloadInfo.text = "License downloaded"
                    }else {
                        cell.voiceDownloadInfo.text = "Error downloading license"
                    }
                }
            }
        }
    }
    
    
    
    @objc func localSynthesis(sender: UIButton) {
        let voiceResult = self.voiceResults[sender.tag]
        
        if !voiceResult.isDownloaded  {
            showAlert(title: "Error", message: "Voice file does not exist")
            return
        }
        if !voiceResult.isLicensed  {
            showAlert(title: "Error", message: "License file does not exist")
            return
        }
        // loading license
        let licensePath = VOCDataStore.default.vocalidDirectory + voiceResult.licenseName
        self.engine?.loadLicense(licensePath)
        

        if engine?.voice() != voiceResult.fileName {
            // loading voice
            self.engine?.setVoicePath(VOCDataStore.default.vocalidDirectory)
            self.engine?.setVoice(voiceResult.fileName, loadNow: true)
        }

        engine?.speak("This is my vocal idenitiy")
    }
    
    
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title  , message: message , preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
            print("okay")
        }
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @objc func streamSynthesis(sender: UIButton) {
        let voiceResult = self.voiceResults[sender.tag]
        if voiceResult.isStreamable {
            sender.isEnabled = false
            let vocalidRequest = VocalidRequest(pitch: 1, rate: 1, script: "This is my vocal identity")

            sdk.streamSynthesis(voiceInfo: voiceResult, vq: vocalidRequest) { (_data, _error) in
                guard let data = _data else {
                    print("no data available")
                    sender.isEnabled = true
                    return
                }
                self.player = try? AVAudioPlayer(data: data)
                self.player?.play()
                DispatchQueue.main.async {
                    sender.isEnabled = true
                }
            }
       
            
        }
    }
    
    
}
