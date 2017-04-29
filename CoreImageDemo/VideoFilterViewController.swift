//
//  VideoFilterViewController.swift
//  CoreImageDemo
//
//  Created by Morteza Hoseinizade on 4/23/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AVFoundation
import SCRecorder
import Photos




class VideoFilterViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var videoPreviewLayer: UIView!
    var playerItem:AVPlayerItem?
    var videoUrl : URL?
    var asset :AVAsset?
    var recordSession : SCRecordSession?
    var exportSession: SCAssetExportSession?
    var player : SCPlayer?
    
    
    
    
    var currentFilter: SCFilter?
    
    @IBOutlet weak var filterImView: SCFilterImageView!
    
    override func viewDidLoad() {


        recordSession = SCRecordSession()
        player = SCPlayer()
        
        filterImView.contentMode = .scaleToFill;
        filterImView.filter = SCFilter.init(ciFilterName: "CIPhotoEffectInstant")
        
        currentFilter = SCFilter.init(ciFilterName: "CIPhotoEffectInstant")
        
        player?.scImageView = self.filterImView;
        player?.loopEnabled = true;
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(true)
        player?.pause()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        player?.setItemBy(recordSession?.assetRepresentingSegments())
        player?.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let url = info[UIImagePickerControllerMediaURL] as? URL
        picker.dismiss(animated: true, completion: nil)
        
        let segment = SCRecordSessionSegment.init(url: url!, info: info)
        recordSession?.addSegment(segment)
        
        
        player?.setItemBy(recordSession?.assetRepresentingSegments())
        player?.play()
        
    }
    
    @IBAction func clicked(_ sender: UIButton) {
        
        let videoPicker = UIImagePickerController()
        videoPicker.delegate = self
        videoPicker.modalPresentationStyle = .custom
        videoPicker.mediaTypes = [(kUTTypeMovie as? String)!, (kUTTypeAVIMovie as? String)!, (kUTTypeVideo as? String)!, (kUTTypeMPEG4 as? String)!]
        videoPicker.allowsEditing = true
        videoPicker.videoMaximumDuration = 210
        present(videoPicker, animated: true, completion: { _ in })
        
    }

    @IBAction func change1(_ sender: UIButton) {
    
        currentFilter = SCFilter.init(ciFilterName: "CIPhotoEffectChrome")
        filterImView.filter = SCFilter.init(ciFilterName: "CIPhotoEffectChrome")
        player?.scImageView = filterImView;
    }
    
    @IBAction func change2(_ sender: UIButton) {
        
        currentFilter = SCFilter.init(ciFilterName: "CIPhotoEffectTonal")
        filterImView.filter = SCFilter.init(ciFilterName: "CIPhotoEffectTonal")
        player?.scImageView = filterImView;
    }
    
    @IBAction func change3(_ sender: UIButton) {
        
        currentFilter = SCFilter.init(ciFilterName: "CIPhotoEffectNoir")
        filterImView.filter = SCFilter.init(ciFilterName: "CIPhotoEffectNoir")
        player?.scImageView = filterImView;
    }
    @IBAction func shareButtonClicked(_ sender: UIButton) {
        
        filterVideo()
    }
    
    
    func filterVideo()  {
        
        let filter = CIFilter(name: "CIPhotoEffectNoir")!
        
        let composition = AVVideoComposition(asset: (recordSession?.assetRepresentingSegments())!, applyingCIFiltersWithHandler: { request in
            
            let source = request.sourceImage.clampingToExtent()
            filter.setValue(source, forKey: kCIInputImageKey)
            
            let output = filter.outputImage!.cropping(to: request.sourceImage.extent)
            
            request.finish(with: output, context: nil)
            
            
        })
        
        let exportPath: NSString = NSTemporaryDirectory().appendingFormat("\(randomString(length: 7)).mov") as NSString
        let exportUrl: NSURL = NSURL.fileURL(withPath: exportPath as String) as NSURL
        
        
        
        let export = AVAssetExportSession(asset: (recordSession?.assetRepresentingSegments())!, presetName: AVAssetExportPreset1920x1080)
        export?.outputFileType = AVFileTypeQuickTimeMovie
        export?.outputURL = exportUrl as URL
        export?.videoComposition = composition
        export?.exportAsynchronously {
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:exportUrl as URL)
            }) {
                completed, error in
                
                if completed {
                    print("Video is saved!")
                }
            }
        }
        
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }


}
