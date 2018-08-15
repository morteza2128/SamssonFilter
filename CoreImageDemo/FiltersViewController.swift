//
//  FiltersViewController.swift
//  CoreImageDemo
//
//  Created by Morteza Hoseinizade on 4/17/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import UIKit
import CoreImage


class FiltersViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    var filterString :String?
    var devFilterString :String?
    var isFiltering = false

    //MARK: - image states
    var originalImage: UIImage!
    var tempImage: UIImage!{
        
        didSet{
            self.imageView.image = tempImage
        }
    }
    var filteredImage: UIImage!{
        
        didSet{
            self.imageView.image = filteredImage
        }
    }
    
    
    //MARK: - UI Properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var slider3: UISlider!
    @IBOutlet weak var parameter1titleLabel: UILabel!
    @IBOutlet weak var parameter2titleLabel: UILabel!
    @IBOutlet weak var parameter3titleLabel: UILabel!
    
    //MARK: - Filter Properties
    let openGLContext = EAGLContext(api: .openGLES2)
    var context  : CIContext?
    var ciFilter : CIFilter?
    var currentFilter : FilterObject?
    var filters : [FilterObject]?
    {
        didSet{
            self.collectionView.reloadData()
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        initCollectionView()
        filters = FilterCore.sharedInstance.parseFilters()
        context = CIContext(eaglContext: openGLContext!)
        
        
        imageView.layer.masksToBounds = true;
        
        self.restFilters()
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
        
        if filterObj?.name == currentFilter?.name{
            cell.contentView.backgroundColor = UIColor(red: 102/256, green: 255/256, blue: 255/256, alpha: 0.66)
        }
        else{
            cell.contentView.backgroundColor = UIColor(red: 250/256, green: 180/256, blue: 33/256, alpha: 1.0)
        }
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:90, height: 90)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if imageView.image != nil {
            
            isFiltering = true
            tempImage = filteredImage
            currentFilter = filters?[indexPath.row]
            setSlidersWithfilter(filter: currentFilter!)
            
            let coreImage = CIImage(cgImage: (filteredImage?.cgImage)!)
            CGImage
            
            ciFilter = CIFilter(name: (currentFilter?.coreImageName)!)
            ciFilter?.setValue(coreImage, forKey: kCIInputImageKey)
            
            let selectedCell:UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
            selectedCell.contentView.backgroundColor = UIColor(red: 102/256, green: 255/256, blue: 255/256, alpha: 0.66)
            
            if currentFilter?.parametrs?.count == 0{
                
                applySingleFilter();
            }
            
        }else{
            
            let alert = UIAlertController.init(title: nil, message: "Select Image first, you want filter nothing!!!", preferredStyle: .alert)
            
            let okAction = UIAlertAction.init(title: "OK", style: .default, handler: { (UIAlertAction) in
                
            })
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cellToDeselect:UICollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath) else{
            
            return
        }
        
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
        filteredImage = originalImage
        
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
        
        if(currentFilter != nil){
            filteredImage = tempImage
            makeFilterString()
        }
        else{
            
            let alert = UIAlertController.init(title: nil, message: "First select filter then click on me, OK dude????", preferredStyle: .alert)
            
            let okAction = UIAlertAction.init(title: "OK", style: .default, handler: { (UIAlertAction) in
                
            })
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }

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
            
            print("slideValue:\(sender.value)")
            if let sepiaOutput = ciFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                
                let output = context?.createCGImage(sepiaOutput, from: sepiaOutput.extent)
                tempImage = UIImage(cgImage: output! , scale: 1.0, orientation: (filteredImage?.imageOrientation)!)
                
                print("Filter finished")
            }
            
        }
    }
    
    func applySingleFilter() {
        
        if let sepiaOutput = ciFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            
            let output = context?.createCGImage(sepiaOutput, from: sepiaOutput.extent)
            tempImage = UIImage(cgImage: output! , scale: 1.0, orientation: (filteredImage?.imageOrientation)!)
            
            print("Filter finished")
        }
    }
    
    
    //MARK: - Pick Photo
    
    @IBAction func selectImageButtonClicked(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        originalImage   = image
        filteredImage   = image
        imageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Share
    
    @IBAction func shareButtonclicked(_ sender: UIButton) {
        
        if (self.filterString?.characters.count)! > 0 {
        
            let shareVC: UIActivityViewController = UIActivityViewController(activityItems: [(originalImage),(filteredImage), self.filterString!], applicationActivities: nil)
            self.present(shareVC, animated: true, completion: nil)
        }
        else{
            
            let alert = UIAlertController.init(title: nil, message: "Share what?!?! first select image, filter image and then click on ✅ at right side of ME, OK dude???", preferredStyle: .alert)
            
            let okAction = UIAlertAction.init(title: "OK", style: .default, handler: { (UIAlertAction) in
                
            })
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    func makeFilterString() {
        
        var str = "\nFilterName:\(self.currentFilter!.name!)\n"
        
        if self.currentFilter?.parametrs != nil {
        
            for parametr in self.currentFilter!.parametrs! {
                
                let paStr = "\t\t\t\tParameter = Name:\(parametr.name!)(\(parametr.defaultV!))\n"
                str += paStr
            }
        }
        
        self.filterString?.append(str)
        
    }
    

}
