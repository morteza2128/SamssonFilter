//
//  ViewController.swift
//  CoreImageDemo
//
//  Created by Simon Ng on 1/2/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView?
    @IBOutlet var image: UIImage?
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLoad() {
        
        image = imageView?.image
    }
    
    func applyFirstFilter() {
        
        guard let cgimg = self.image?.cgImage else {
            print("imageView doesn't have an image!")
            return
        }
        
        let openGLContext = EAGLContext(api: .openGLES2)
        let context = CIContext(eaglContext: openGLContext!)
        
        let coreImage = CIImage(cgImage: cgimg)
        
        let sepiaFilter = CIFilter(name: "CISepiaTone")
        sepiaFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(1, forKey: kCIInputIntensityKey)
        
        if let sepiaOutput = sepiaFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            
            let output = context.createCGImage(sepiaOutput, from: sepiaOutput.extent)
            let result = UIImage(cgImage: output!)
            imageView?.image = result
            

        }
    }
    
    func applySecondFilter() {
        

        guard let cgimg = self.image?.cgImage else {
            print("imageView doesn't have an image!")
            return
        }
        
        let openGLContext = EAGLContext(api: .openGLES2)
        let context = CIContext(eaglContext: openGLContext!)
        
        let coreImage = CIImage(cgImage: cgimg)
        
        let sepiaFilter = CIFilter(name: "CIUnsharpMask")
        sepiaFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(100, forKey: kCIInputIntensityKey)
        
        if let sepiaOutput = sepiaFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            
            let output = context.createCGImage(sepiaOutput, from: sepiaOutput.extent)
            let result = UIImage(cgImage: output!)
            imageView?.image = result

        }
    }
    
    func applythirdFilter() {
        
        
        guard let cgimg = self.image?.cgImage else {
            print("imageView doesn't have an image!")
            return
        }
        
        let openGLContext = EAGLContext(api: .openGLES2)
        let context = CIContext(eaglContext: openGLContext!)
        
        let coreImage = CIImage(cgImage: cgimg)
        
        let sepiaFilter = CIFilter(name: "CIPhotoEffectInstant")
        sepiaFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let sepiaOutput = sepiaFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            
            let output = context.createCGImage(sepiaOutput, from: sepiaOutput.extent)
            let result = UIImage(cgImage: output!)
            imageView?.image = result
            
        }
    }
    
    func applyFourthFilter() {
        
        
        guard let cgimg = self.image?.cgImage else {
            print("imageView doesn't have an image!")
            return
        }
        
        let openGLContext = EAGLContext(api: .openGLES2)
        let context = CIContext(eaglContext: openGLContext!)
        
        let coreImage = CIImage(cgImage: cgimg)
        
        let sepiaFilter = CIFilter(name: "CIPhotoEffectTonal")
        sepiaFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        if let sepiaOutput = sepiaFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            
            let output = context.createCGImage(sepiaOutput, from: sepiaOutput.extent)
            let result = UIImage(cgImage: output!)
            imageView?.image = result
            
        }
    }
    
    @IBAction func firstButtonClicked(_ sender: UIButton) {

        applyFirstFilter()
    }
    
    @IBAction func secondButtonClicked(_ sender: UIButton) {
        
        applySecondFilter()
    }
    
    @IBAction func thirdButtonClicked(_ sender: UIButton) {
        
        applythirdFilter()
    }
    
    @IBAction func fourthButtonClicked(_ sender: UIButton) {
        
        applyFourthFilter()
    }
    
}



