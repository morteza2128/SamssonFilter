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
import SVProgressHUD




class VideoFilterViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource{

    var filterString :String?
    var devFilterString :String?
    var isFiltering = false
    
    //MARK: - Video UI Properties
    var asset :AVAsset?
    var recordSession : SCRecordSession?
    var exportSession: SCAssetExportSession?
    var player : SCPlayer?
    
    
    //MARK: - UI Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var slider3: UISlider!
    @IBOutlet weak var parameter1titleLabel: UILabel!
    @IBOutlet weak var parameter2titleLabel: UILabel!
    @IBOutlet weak var parameter3titleLabel: UILabel!
    

    //MARK: - Filter Properties
    var ouputUrl :URL?
    var numberOffilterApplied : Int = 0
    var scFilter : SCFilter?
    var curentScFilter : SCFilter?
    var ciFilter : CIFilter?
    var currentFilter : FilterObject?

    var filters : [FilterObject]?
    {
        didSet{
            self.collectionView.reloadData()
        }
        
    }
    
    @IBOutlet weak var filterImView: SCFilterImageView!
    
    override func viewDidLoad() {
        
        recordSession = SCRecordSession()
        player = SCPlayer()
        
        
        player?.scImageView = self.filterImView;
        player?.loopEnabled = true;
        
        scFilter = SCFilter.empty()
        
        initCollectionView()
        filters = FilterCore.sharedInstance.parseFilters()
        self.restFilters()
        
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
    

    //MARK: - CollectionView
    func initCollectionView() {
        
        collectionView.register(UINib.init(nibName: "FilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "filterCellID")
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.filters?.count)!;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCellID", for: indexPath) as! FilterCollectionViewCell
        
        let filterObj = filters?[indexPath.row]
        cell.filterNameLabel.text = filterObj?.name
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:90, height: 90)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if filterImView != nil {
            
            isFiltering = true
            currentFilter = filters?[indexPath.row]
            setSlidersWithfilter(filter: currentFilter!)
            ciFilter = CIFilter(name: (currentFilter?.coreImageName)!)
            
            let selectedCell:UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
            selectedCell.contentView.backgroundColor = UIColor(red: 102/256, green: 255/256, blue: 255/256, alpha: 0.66)
            
            if(scFilter != nil ){
                if ((scFilter?.subFilters.count)! > numberOffilterApplied)
                {
                    scFilter?.removeSubFilter(at: numberOffilterApplied)
                }
            }
            
            curentScFilter = SCFilter.init(ciFilter: ciFilter)
            scFilter?.addSubFilter(curentScFilter!)
            
            
        }else{
            
            let alert = UIAlertController.init(title: nil, message: "Select Video first, you want filter nothing!!!", preferredStyle: .alert)
            
            let okAction = UIAlertAction.init(title: "OK", style: .default, handler: { (UIAlertAction) in
                
            })
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cellToDeselect:UICollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath)!
        cellToDeselect.contentView.backgroundColor = UIColor(red: 250/256, green: 180/256, blue: 33/256, alpha: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 0 , left: 0 , bottom: 0, right:0 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    


    //MARK: - filter actions
    @IBAction func resetFilterBittonClicked(_ sender: UIButton) {
        
        self.restFilters()
        
    }
    
    func restFilters()  {
        
        filterString = ""
        numberOffilterApplied = 0
        
        self.slider1.value        = 0
        self.slider2.value        = 0
        self.slider3.value        = 0
        
        isFiltering = false
        slider1.isEnabled = false
        slider2.isEnabled = false
        slider3.isEnabled = false
        
        self.parameter1titleLabel.text = "-"
        self.parameter2titleLabel.text = "-"
        self.parameter3titleLabel.text = "-"
        
        for indexPath in self.collectionView.indexPathsForVisibleItems {
            
            self.collectionView.deselectItem(at: indexPath, animated: false)
        }
    }
    
    @IBAction func confrimFilterButtonClicked(_ sender: UIButton) {
        
        numberOffilterApplied += 1
        makeFilterString()
        
    }
    
    @IBAction func cancelFilterButtonClicked(_ sender: UIButton) {
        
    }
    
    
    
    //MARK: - Sliders
    
    func setSlidersWithfilter(filter:FilterObject){
        
        let parametrsCount  = filter.parametrs?.count
        
        self.slider1.value = 0;
        self.slider2.value = 0;
        self.slider3.value = 0;
        
        switch parametrsCount! {
        case 0:
            slider1.isEnabled = false
            slider2.isEnabled = false
            slider3.isEnabled = false
            
            self.parameter1titleLabel.text = "-"
            self.parameter2titleLabel.text = "-"
            self.parameter3titleLabel.text = "-"
            
        case 1:
            slider1.isEnabled = true
            slider2.isEnabled = false
            slider3.isEnabled = false
            
            let parameter1  = filter.parametrs?[0]
            
            self.parameter1titleLabel.text = parameter1?.name
            self.parameter2titleLabel.text = "-"
            self.parameter3titleLabel.text = "-"
            
            self.slider1.minimumValue = (parameter1?.min)!
            self.slider1.maximumValue = (parameter1?.max)!
            
            self.slider1.value        = (parameter1?.defaultV)!
            self.slider2.value        = 0
            self.slider3.value        = 0
            
            
        case 2:
            slider1.isEnabled = true
            slider2.isEnabled = true
            slider3.isEnabled = false
            
            let parameter1  = filter.parametrs?[0]
            let parameter2  = filter.parametrs?[1]
            
            self.parameter1titleLabel.text = parameter1?.name
            self.parameter2titleLabel.text = parameter2?.name
            self.parameter3titleLabel.text = "-"
            
            
            self.slider1.minimumValue = (parameter1?.min)!
            self.slider1.maximumValue = (parameter1?.max)!
            self.slider2.minimumValue = (parameter2?.min)!
            self.slider2.maximumValue = (parameter2?.max)!
            
            self.slider1.value        = (parameter1?.defaultV)!
            self.slider2.value        = (parameter2?.defaultV)!
            self.slider3.value        = 0
            
            
        case 3:
            slider1.isEnabled = true
            slider2.isEnabled = true
            slider3.isEnabled = true
            
            let parameter1  = filter.parametrs?[0]
            let parameter2  = filter.parametrs?[1]
            let parameter3  = filter.parametrs?[2]
            
            self.parameter1titleLabel.text = parameter1?.name
            self.parameter2titleLabel.text = parameter2?.name
            self.parameter3titleLabel.text = parameter3?.name
            
            self.slider1.minimumValue = (parameter1?.min)!
            self.slider1.maximumValue = (parameter1?.max)!
            self.slider2.minimumValue = (parameter2?.min)!
            self.slider2.maximumValue = (parameter2?.max)!
            self.slider3.minimumValue = (parameter3?.min)!
            self.slider3.maximumValue = (parameter3?.max)!
            
            self.slider1.value        = (parameter1?.defaultV)!
            self.slider2.value        = (parameter2?.defaultV)!
            self.slider3.value        = (parameter3?.defaultV)!
            
        default: break
            
        }
        
        
    }
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        if isFiltering{
            
            switch sender.tag {
            case 0:
                ciFilter?.setValue(sender.value, forKey: (currentFilter?.parametrs?[0].coreImageName)!)
                currentFilter?.parametrs?[0].defaultV = sender.value
                
            case 1:
                ciFilter?.setValue(sender.value, forKey: (currentFilter?.parametrs?[1].coreImageName)!)
                currentFilter?.parametrs?[1].defaultV = sender.value
                
            case 2:
                ciFilter?.setValue(sender.value, forKey: (currentFilter?.parametrs?[2].coreImageName)!)
                currentFilter?.parametrs?[2].defaultV = sender.value
            default: break
                
            }
            
            scFilter?.removeSubFilter(at: numberOffilterApplied)
            curentScFilter = SCFilter.init(ciFilter: ciFilter)
            scFilter?.addSubFilter(curentScFilter!)
            print("slideValue:\(sender.value)")
            
            filterImView.filter = scFilter
            player?.scImageView = filterImView;

            
        }
    }

    //MARK: - Pick Video
    
    @IBAction func selectvideoButtonClicked(_ sender: UIButton) {
        
        let videoPicker = UIImagePickerController()
        videoPicker.delegate = self
        videoPicker.modalPresentationStyle = .custom
        videoPicker.mediaTypes = [(kUTTypeMovie as? String)!, (kUTTypeAVIMovie as? String)!, (kUTTypeVideo as? String)!, (kUTTypeMPEG4 as? String)!]
        videoPicker.allowsEditing = true
        videoPicker.videoMaximumDuration = 210
        present(videoPicker, animated: true, completion: { _ in })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let url = info[UIImagePickerControllerMediaURL] as? URL
        picker.dismiss(animated: true, completion: nil)
        
        let segment = SCRecordSessionSegment.init(url: url!, info: info)
        recordSession?.addSegment(segment)
        
        ouputUrl = url
        
        player?.setItemBy(recordSession?.assetRepresentingSegments())
        player?.play()
        
    }

    //MARK: - Share

    @IBAction func shareButtonClicked(_ sender: UIButton) {
        
        let asset = recordSession?.assetRepresentingSegments()

        if (asset?.tracks(withMediaType: AVMediaTypeVideo).first) != nil {
        
            filterVideo()
            
        }
        else{
            
            let alert = UIAlertController.init(title: nil, message: "Seriously men ?!?!?  select video first, OK dude!!!", preferredStyle: .alert)
            
            let okAction = UIAlertAction.init(title: "OK", style: .default, handler: { (UIAlertAction) in
                
            })
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        
    }

    
    func makeFilterString() {
        
    }

   
    func filterVideo()  {
        
        SVProgressHUD.show(withStatus: "Filtering...")
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)

        
        let asset = recordSession?.assetRepresentingSegments()
        
        let exportSession = SCAssetExportSession.init(asset: asset!)
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let exportPath = documentsPath.appendingFormat("/\(randomString(length: 7)).mp4")
        let exportUrl = URL(fileURLWithPath: exportPath)
        
        exportSession.outputUrl = exportUrl
        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.videoConfiguration.filter = scFilter
        exportSession.videoConfiguration.keepInputAffineTransform = false
        
        let videoComposition = AVMutableVideoComposition()
        
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60 , 30))
        
        let clipVideoTrack = asset?.tracks(withMediaType: AVMediaTypeVideo).first!
        let size:CGSize = clipVideoTrack!.naturalSize
        
        var videoRect: CGRect = CGRect(x:0.0, y:0.0, width:size.width, height:size.height)
        videoRect = videoRect.applying((clipVideoTrack?.preferredTransform)!)
        
        var t1:CGAffineTransform = CGAffineTransform.identity
        var t2:CGAffineTransform = CGAffineTransform.identity
        
        if (videoRect.height > videoRect.width){
            
            videoComposition.renderSize = CGSize(width: videoRect.height, height: videoRect.width )
            
            if (asset?.availableMetadataFormats)! != [] {
                for index in 0..<(asset?.availableMetadataFormats.count)! {
                    if (asset?.availableMetadataFormats[index].contains("com.apple.quicktime.mdta"))! {
                        
                        t1 = CGAffineTransform(translationX: 0, y: 0)
                        t2 = t1.rotated(by: CGFloat(Double.pi/2))
                    }
                    else{
                        
                        t1 = CGAffineTransform(translationX: 0 , y: 0)
                        t2 = t1
                    }
                }
            }
            else{
                
                videoComposition.renderSize = CGSize(width: videoRect.width, height: videoRect.height)

                t1 = CGAffineTransform(translationX: 0 , y: 0)
                t2 = t1
            }

        }
        else{
            
            videoComposition.renderSize = CGSize(width: videoRect.width, height: videoRect.height)
            
        }

        exportSession.videoConfiguration.affineTransform = t2
        
    
        
        let transformer : AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack!)
        transformer.setTransform(t1, at: kCMTimeZero)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        exportSession.videoConfiguration.composition = videoComposition;

        exportSession.videoConfiguration.preset = SCPresetHighestQuality
        exportSession.audioConfiguration.preset = SCPresetMediumQuality
        
        
        
        exportSession .exportAsynchronously {
            
            if(exportSession.error == nil){
                
                print("Export worked")
                SVProgressHUD.showSuccess(withStatus: "Done!")
                
                let saveToCameraRoll = SCSaveToCameraRollOperation.init()
                saveToCameraRoll.saveVideoURL(exportSession.outputUrl, completion: nil)
                
            }
            else{
                
                SVProgressHUD.showError(withStatus: "Can't Save!")
                print("Export fucked")
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
    
    
    
    
    
    
    //Apply filter with apple API
    
    
    
    //    func filterVideo()  {
    //
    //        let filter = CIFilter(name: "CIPhotoEffectNoir")!
    //
    //        let composition = AVVideoComposition(asset: (recordSession?.assetRepresentingSegments())!, applyingCIFiltersWithHandler: { request in
    //
    //            let source = request.sourceImage.clampingToExtent()
    //            filter.setValue(source, forKey: kCIInputImageKey)
    //
    //            let output = filter.outputImage!.cropping(to: request.sourceImage.extent)
    //
    //            request.finish(with: output, context: nil)
    //
    //
    //        })
    //
    //        let exportPath: NSString = NSTemporaryDirectory().appendingFormat("\(randomString(length: 7)).mov") as NSString
    //        let exportUrl: NSURL = NSURL.fileURL(withPath: exportPath as String) as NSURL
    //
    //
    //
    //        let export = AVAssetExportSession(asset: (recordSession?.assetRepresentingSegments())!, presetName: AVAssetExportPreset1920x1080)
    //        export?.outputFileType = AVFileTypeQuickTimeMovie
    //        export?.outputURL = exportUrl as URL
    //        export?.videoComposition = composition
    //        export?.exportAsynchronously {
    //
    //            PHPhotoLibrary.shared().performChanges({
    //                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:exportUrl as URL)
    //            }) {
    //                completed, error in
    //
    //                if completed {
    //                    print("Video is saved!")
    //                }
    //            }
    //        }
    //        
    //    }


}
