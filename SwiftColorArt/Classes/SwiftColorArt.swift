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
        
        let targetSize:CGSize = CGSize(width: 128, height: 128)
        let scaledImage:UIImage = SwiftColorArt.resizeImage(inputImage, targetSize: targetSize)
        
        self.image = scaledImage
        
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
        var imageColors:Array<PCCountedColor> = Array<PCCountedColor>()
        var backgroundColor:UIColor = self.findEdgeColor(inputImage,colors:&imageColors);

        var primaryColor:UnsafeMutablePointer<UIColor>   = nil
        var secondaryColor:UnsafeMutablePointer<UIColor> = nil
        var detailColor:UnsafeMutablePointer<UIColor>    = nil
        
        var darkBackground:Bool = backgroundColor.pc_isDarkColor()

        self.findTextColors(imageColors, primaryColor:&primaryColor, secondaryColor:&secondaryColor, detailColor:&detailColor, backgroundColor:&backgroundColor)
        
        var dict:Dictionary = Dictionary<String, UIColor>()

        dict[self.kAnalyzedBackgroundColor] = backgroundColor
        
        if primaryColor == nil {
            println("missed primary")
            if darkBackground {
                dict[self.kAnalyzedPrimaryColor] = UIColor.whiteColor()
            } else {
                dict[self.kAnalyzedPrimaryColor] = UIColor.blackColor()
            }
        } else {
            dict[self.kAnalyzedPrimaryColor] = primaryColor.memory
        }

        
        if secondaryColor == nil {
            println("missed secondary")
            if darkBackground {
                dict[self.kAnalyzedSecondaryColor] = UIColor.whiteColor()
            } else {
                dict[self.kAnalyzedSecondaryColor] = UIColor.blackColor()
            }
        } else {
            dict[self.kAnalyzedSecondaryColor] = secondaryColor.memory
        }

        
        if detailColor == nil {
            println("missed detail")
            if darkBackground {
                dict[self.kAnalyzedDetailColor] = UIColor.whiteColor()
            } else {
                dict[self.kAnalyzedDetailColor] = UIColor.blackColor()
            }
        } else {
            dict[self.kAnalyzedDetailColor] = detailColor.memory
        }
        
        return dict
    }
    
    private func findEdgeColor(inputImage:UIImage, inout colors:Array<PCCountedColor>) -> UIColor
    {
        
        var imageRep:CGImageRef = image.CGImage;
        
        var width:UInt  = CGImageGetWidth(imageRep)
        var height:UInt = CGImageGetHeight(imageRep)
        
        var cs:CGColorSpaceRef = CGColorSpaceCreateDeviceRGB();
        var context:CGContext  = self.createBitmapContext(image.CGImage)
        var rect:CGRect        = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(width), height: CGFloat(height))
        
        CGContextDrawImage(context, rect, image.CGImage);

        var imageColors:NSCountedSet = NSCountedSet(capacity: Int(width * height))
        var edgeColors:NSCountedSet  = NSCountedSet(capacity: Int(height))

        var data     = CGBitmapContextGetData(context)
        var dataType = UnsafeMutablePointer<UInt8>(data)
        
        
        for y in 0...height-1 {
            for x in 0...width-1 {
                let offset:Int = Int(4 * (x + y * width))
                
                var alpha = CGFloat(dataType[offset])
                var red   = CGFloat(dataType[offset+1])
                var green = CGFloat(dataType[offset+2])
                var blue  = CGFloat(dataType[offset+3])
                
                alpha = alpha / 255.0
                red   = red / 255.0
                green = green / 255.0
                blue  = blue / 255.0
                
                var color:UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                
                if x == 0 {
                    edgeColors.addObject(color)
                } else {
                    imageColors.addObject(color)
                }
            }
        }
        
        var imageEnumerator:NSEnumerator = imageColors.objectEnumerator()
        
        while let curColor = imageEnumerator.nextObject() as? UIColor
        {
            var colorCount:Int = edgeColors.countForObject(curColor)
            
            if colorCount <= self.randomColorThreshold {
                continue
            }
            
            var container:PCCountedColor = PCCountedColor(color:curColor, count: colorCount)
            colors.append(container)
        }
        
        var enumerator:NSEnumerator = edgeColors.objectEnumerator()
        
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
        
        // TODO: Use swifts sorting capabilities for this...
        var finalColors:Array = sortedColors.sortedArrayUsingSelector(Selector("compare:"))
        
        var proposedEdgeColor:PCCountedColor?
        
        if finalColors.count > 0 {
            
            proposedEdgeColor = finalColors[0] as? PCCountedColor
            
            if proposedEdgeColor!.color.pc_isBlackOrWhite() {
    
                for i in 1...finalColors.count - 1 {
                    var nextProposedColor:PCCountedColor = finalColors[i] as PCCountedColor
                    
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
        
        if proposedEdgeColor == nil {
            return UIColor.whiteColor()
        }
        
        return proposedEdgeColor!.color;
    }
    
    private func findTextColors(imageColors:Array<PCCountedColor>, inout primaryColor:UnsafeMutablePointer<UIColor>, inout secondaryColor:UnsafeMutablePointer<UIColor>, inout detailColor:UnsafeMutablePointer<UIColor>, inout backgroundColor:UIColor)
    {
        var curColor:UIColor
        
        var sortedColors:NSMutableArray = NSMutableArray(capacity: imageColors.count)
        var findDarkTextColor:Bool = !backgroundColor.pc_isDarkColor()
        
        if (imageColors.count > 0) {
            //for countedColor: PCCountedColor in imageColors as [PCCountedColor] {
            for index in 0...imageColors.count-1 {
                
                var countedColor:PCCountedColor = imageColors[index]
                
                var curColor:UIColor = countedColor.color.pc_colorWithMinimumSaturation(0.15)
                
                if curColor.pc_isDarkColor() == findDarkTextColor {
                    var colorCount:Int = countedColor.count;
                    
                    //if ( colorCount <= 2 ) // prevent using random colors, threshold should be based on input image size
                    //	continue;
                    
                    var container:PCCountedColor = PCCountedColor(color: curColor, count: colorCount)
                    
                    sortedColors.addObject(container)
                }
            }
        }
        
        var finalSortedColors:Array = sortedColors.sortedArrayUsingSelector(Selector("compare:"))
        
        if finalSortedColors.count > 0 {
            //for curContainer: PCCountedColor in sortedColors as [PCCountedColor] {
            for index in 0...finalSortedColors.count-1 {
                
                var curContainer:PCCountedColor = finalSortedColors[index] as PCCountedColor
                
                println("Checking Color (\(curContainer.color.description)) with count \(curContainer.count)")
                println(primaryColor)
                
                curColor = curContainer.color;
                
                if primaryColor == nil {
                    println("No primary color yet")
                    if curColor.pc_isContrastingColor(backgroundColor) {
                        println("Current color is contrasting to background color")
                        primaryColor = UnsafeMutablePointer<UIColor>(calloc(1, UInt(sizeof(UIColor))))
                        primaryColor.memory = curColor;
                        println("Set primary color to \(curColor)")
                    }
                } else if secondaryColor == nil {
                    println("No secondary color yet")
                    if !primaryColor.memory.pc_isDistinct(curColor) || !curColor.pc_isContrastingColor(backgroundColor) {
                        continue;
                    }
                    secondaryColor = UnsafeMutablePointer<UIColor>(calloc(1, UInt(sizeof(UIColor))))
                    secondaryColor.memory = curColor;
                    println("Set secondary color to \(curColor)")
                } else if detailColor == nil {
                    println("No detail color yet")
                    if !secondaryColor.memory.pc_isDistinct(curColor) || !primaryColor.memory.pc_isDistinct(curColor) || !curColor.pc_isContrastingColor(backgroundColor) {
                        continue;
                    }
                    detailColor = UnsafeMutablePointer<UIColor>(calloc(1, UInt(sizeof(UIColor))))
                    detailColor.memory = curColor;
                    println("Set detail color to \(curColor)")
                    break;
                }
            }
        }
    }
    
    // MARK: Custom
    
    private func createBitmapContext(inImage: CGImageRef) -> CGContext
    {
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)

        let bitmapBytesPerRow = Int(pixelsWide) * 4
        let bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bitmapData = malloc(CUnsignedLong(bitmapByteCount))
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)

        let context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, CUnsignedLong(8), CUnsignedLong(bitmapBytesPerRow), colorSpace, bitmapInfo)
        return context
    }
    
    class func resizeImage(image:UIImage, targetSize: CGSize) -> UIImage {
        
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}