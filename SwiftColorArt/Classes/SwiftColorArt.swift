import Foundation
import UIKit
import CoreGraphics

class SwiftColorArt {

    var randomColorThreshold:NSInteger
    var image:UIImage
    
    var backgroundColor:UIColor?
    var primaryColor:UIColor?
    var secondaryColor:UIColor?
    var detailColor:UIColor?
    
    let kAnalyzedBackgroundColor:String = "kAnalyzedBackgroundColor"
    let kAnalyzedPrimaryColor:String    = "kAnalyzedPrimaryColor"
    let kAnalyzedSecondaryColor:String  = "kAnalyzedSecondaryColor"
    let kAnalyzedDetailColor:String     = "kAnalyzedDetailColor"
    
    convenience init(inputImage:UIImage)
    {
        self.init(inputImage:inputImage, threshold:2)
    }
    
    init(inputImage:UIImage, threshold:NSInteger)
    {
        self.randomColorThreshold = threshold
        self.image = inputImage
        self.processImage()
    }
    
    private func processImage()
    {
        var colors:Dictionary<String, UIColor> = self.analyzeImage(self.image)
        
        self.backgroundColor = colors[self.kAnalyzedBackgroundColor]!
        self.primaryColor    = colors[self.kAnalyzedPrimaryColor]!
        self.secondaryColor  = colors[self.kAnalyzedSecondaryColor]!
        self.detailColor     = colors[self.kAnalyzedDetailColor]!
    }
    
    private func analyzeImage(inputImage:UIImage) -> Dictionary<String, UIColor>
    {
        var imageColors:NSCountedSet = NSCountedSet()
        var backgroundColor:UIColor = self.findEdgeColor(inputImage,imageColors:&imageColors);
        var primaryColor:UIColor?
        var secondaryColor:UIColor?
        var detailColor:UIColor?
        
        // If the random color threshold is too high and the image size too small,
        // we could miss detecting the background color and crash.
        /*if backgroundColor == nil {
            backgroundColor = UIColor.whiteColor()
        }*/
        
        var darkBackground:Bool = backgroundColor.pc_isDarkColor()
            
        self.findTextColors(imageColors, primaryColor:&primaryColor!, secondaryColor:&secondaryColor!, detailColor:&detailColor!, backgroundColor:&backgroundColor)
            
        if primaryColor == nil {
            println("missed primary")
            if darkBackground {
                primaryColor = UIColor.whiteColor()
            } else {
                primaryColor = UIColor.blackColor()
            }
        }
        
        if secondaryColor == nil {
            println("missed secondary")
            if darkBackground {
                secondaryColor = UIColor.whiteColor()
            } else {
                secondaryColor = UIColor.blackColor()
            }
        }
        
        if detailColor == nil {
            println("missed detail")
            if darkBackground {
                detailColor = UIColor.whiteColor()
            } else {
                detailColor = UIColor.blackColor()
            }
        }
        
        var dict:Dictionary = Dictionary<String, UIColor>()
        
        dict[self.kAnalyzedBackgroundColor] = backgroundColor
        dict[self.kAnalyzedPrimaryColor]    = primaryColor
        dict[self.kAnalyzedSecondaryColor]  = secondaryColor
        dict[self.kAnalyzedDetailColor]     = detailColor
        
        return dict
    }
    
    private func findEdgeColor(inputImage:UIImage, inout imageColors:NSCountedSet) -> UIColor
    {
        
        var imageRep:CGImageRef = image.CGImage;
        
        var width:UInt  = CGImageGetWidth(imageRep)
        var height:UInt = CGImageGetHeight(imageRep)
        
        var cs:CGColorSpaceRef     = CGColorSpaceCreateDeviceRGB();
        var bmContext:CGContextRef = CGBitmapContextCreate(nil, width, height, 8, 4 * width, cs, CGBitmapInfo.ByteOrderDefault ); //CGImageAlphaInfo.NoneSkipLast
        var rect:CGRect            = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(width), height: CGFloat(height))
        
        CGContextDrawImage(bmContext, rect, image.CGImage);

        var imageColors:NSCountedSet = NSCountedSet(capacity: Int(width * height))
        var edgeColors:NSCountedSet  = NSCountedSet(capacity: Int(height))

        let pixels:[RGBAPixel] = CGBitmapContextGetData(bmContext) as [RGBAPixel]
        
        for y in 0...height-1 {
            for x in 0...width-1 {
                let index:Int = Int(x + y * width)
                var pixel:RGBAPixel = pixels[index]
                
                var red:CGFloat = CGFloat(pixel.red / 255)
                var green:CGFloat = CGFloat(pixel.green / 255)
                var blue:CGFloat = CGFloat(pixel.blue / 255)
                var alpha:CGFloat = CGFloat(pixel.alpha / 255)
                
                var color:UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                
                if x == 0 {
                    edgeColors.addObject(color)
                } else {
                    imageColors.addObject(color)
                }
            }
        }
        
        var colors = imageColors;
        
        var enumerator:NSEnumerator = edgeColors.objectEnumerator()

        var curColor:UIColor?
        
        var sortedColors:NSMutableArray = []
        
        while let curColor = enumerator.nextObject() as? UIColor
        {
            var colorCount:Int = edgeColors.countForObject(curColor)
            
            if colorCount <= self.randomColorThreshold {
                continue
            }
            
            var container:PCCountedColor = PCCountedColor(color:curColor, count: colorCount)
            sortedColors.addObject(container)
        }
        
        sortedColors.sortedArrayUsingSelector("compare")
        
        var proposedEdgeColor:PCCountedColor?
        
        if sortedColors.count > 0 {
            
            proposedEdgeColor = sortedColors.objectAtIndex(0) as? PCCountedColor
            
            if proposedEdgeColor!.color.pc_isBlackOrWhite() {
                
                for i in 1...sortedColors.count {
                    var nextProposedColor:PCCountedColor = sortedColors.objectAtIndex(i) as PCCountedColor
                    
                    if Double( nextProposedColor.count / proposedEdgeColor!.count) > 0.4 {  // make sure the second choice color is 40% as common as the first choice

                        if nextProposedColor.color.pc_isBlackOrWhite() {
                            proposedEdgeColor = nextProposedColor;
                            break;
                        }
                    } else {
                        // reached color threshold less than 40% of the original proposed edge color so bail
                        break;
                    }
                }
            }
        }
        
        return proposedEdgeColor!.color;
    }
    
    private func findTextColors(imageColors:NSCountedSet, inout primaryColor:UIColor, inout secondaryColor:UIColor, inout detailColor:UIColor, inout backgroundColor:UIColor)
    {}
}