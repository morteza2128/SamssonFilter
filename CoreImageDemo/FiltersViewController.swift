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

    var originalImage: UIImage!
    var isFiltering = false
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
    
    var currentFilter : FilterObject?
    
    
    var filters : [FilterObject]?
    {
        didSet{
            self.collectionView.reloadData()
        }
    
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var slider3: UISlider!
    
    @IBOutlet weak var parameter1titleLabel: UILabel!
    @IBOutlet weak var parameter2titleLabel: UILabel!
    @IBOutlet weak var parameter3titleLabel: UILabel!
    
    let openGLContext = EAGLContext(api: .openGLES2)
    var context  : CIContext?
    var ciFilter : CIFilter?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        initCollectionView()
        filters = FilterCore.sharedInstance.parseFilters()
        context = CIContext(eaglContext: openGLContext!)
        

        imageView.layer.masksToBounds = true;
        
        self.restFilters()
    }
    
    func initCollectionView() {
        
        collectionView.register(UINib.init(nibName: "FilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "filterCellID")
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - CollectionView
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
        
        if imageView.image != nil {
            
            isFiltering = true
            tempImage = filteredImage
            currentFilter = filters?[indexPath.row]
            setSlidersWithfilter(filter: currentFilter!)
            
            let coreImage = CIImage(cgImage: (filteredImage?.cgImage)!)
            
            ciFilter = CIFilter(name: (currentFilter?.coreImageName)!)
            ciFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        }else{
            
            let alert = UIAlertController.init(title: nil, message: "Select Image first, you want filter nothing!!!", preferredStyle: .alert)
            
            let okAction = UIAlertAction.init(title: "OK", style: .default, handler: { (UIAlertAction) in
                
            })
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
       

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
        
        filteredImage = originalImage
        
        self.slider1.value        = 0
        self.slider2.value        = 0
        self.slider3.value        = 0
        
        isFiltering = false
        slider1.isEnabled = true
        slider2.isEnabled = true
        slider3.isEnabled = true
    }
    
    @IBAction func confrimFilterButtonClicked(_ sender: UIButton) {
        
        filteredImage = tempImage
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
                
            case 1:
                ciFilter?.setValue(sender.value, forKey: (currentFilter?.parametrs?[1].coreImageName)!)
                
            case 2:
                ciFilter?.setValue(sender.value, forKey: (currentFilter?.parametrs?[2].coreImageName)!)
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
    
    
    //MARK: - Pick Photo
    
    @IBAction func selectImageButtonClicked(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
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
        
        let shareVC: UIActivityViewController = UIActivityViewController(activityItems: ["Original",(originalImage),"Filtered",(filteredImage)], applicationActivities: nil)
        self.present(shareVC, animated: true, completion: nil)
    }
    

}
