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
        self.init(inputImage:inputImage, threshold:0)
    }
    
    init(inputImage:UIImage, threshold:NSInteger)
    {
        self.randomColorThreshold = threshold
        
        let targetSize:CGSize = CGSize(width: 64, height: 64)
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
        var imageColors:Array<CountedColor> = Array<CountedColor>()
        var backgroundColor:UIColor = self.findEdgeColor(inputImage,colors:&imageColors);
        
        var primaryColor:UnsafeMutablePointer<UIColor>   = nil
        var secondaryColor:UnsafeMutablePointer<UIColor> = nil
        var detailColor:UnsafeMutablePointer<UIColor>    = nil
        
        var darkBackground:Bool = backgroundColor.sca_isDarkColor()

        self.findTextColors(imageColors, primaryColor:&primaryColor, secondaryColor:&secondaryColor, detailColor:&detailColor, backgroundColor:&backgroundColor)
        
        var dict:Dictionary = Dictionary<String, UIColor>()

        dict[self.kAnalyzedBackgroundColor] = backgroundColor
        
        if primaryColor == nil {
            if darkBackground {
                dict[self.kAnalyzedPrimaryColor] = UIColor.whiteColor()
            } else {
                dict[self.kAnalyzedPrimaryColor] = UIColor.blackColor()
            }
        } else {
            dict[self.kAnalyzedPrimaryColor] = primaryColor.memory
        }

        
        if secondaryColor == nil {
            if darkBackground {
                dict[self.kAnalyzedSecondaryColor] = UIColor.whiteColor()
            } else {
                dict[self.kAnalyzedSecondaryColor] = UIColor.blackColor()
            }
        } else {
            dict[self.kAnalyzedSecondaryColor] = secondaryColor.memory
        }

        
        if detailColor == nil {
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
    
    private func findEdgeColor(inputImage:UIImage, inout colors:Array<CountedColor>) -> UIColor
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
            
            if colorCount >= self.randomColorThreshold {
                var container:CountedColor = CountedColor(color:curColor, count: colorCount)
                colors.append(container)
            }
        }
        
        var enumerator:NSEnumerator = edgeColors.objectEnumerator()
        
        var sortedColors:NSMutableArray = []
        
        while let curColor = enumerator.nextObject() as? UIColor
        {
            var colorCount:Int = edgeColors.countForObject(curColor)
            
            if colorCount <= self.randomColorThreshold {
                continue
            }
            
            var container:CountedColor = CountedColor(color:curColor, count: colorCount)
            sortedColors.addObject(container)
        }
        
        // TODO: Use swifts sorting capabilities for this...
        var finalColors:Array = sortedColors.sortedArrayUsingSelector(Selector("compare:"))
        
        var proposedEdgeColor:CountedColor?
        
        if finalColors.count > 0 {
            
            proposedEdgeColor = finalColors[0] as? CountedColor
            
            if proposedEdgeColor!.color.sca_isBlackOrWhite() {
    
                for i in 1...finalColors.count - 1 {
                    var nextProposedColor:CountedColor = finalColors[i] as CountedColor
                    
                    if Double( nextProposedColor.count / proposedEdgeColor!.count) > 0.4 {  // make sure the second choice color is 40% as common as the first choice
                        
                        if nextProposedColor.color.sca_isBlackOrWhite() {
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
    
    private func findTextColors(imageColors:Array<CountedColor>, inout primaryColor:UnsafeMutablePointer<UIColor>, inout secondaryColor:UnsafeMutablePointer<UIColor>, inout detailColor:UnsafeMutablePointer<UIColor>, inout backgroundColor:UIColor)
    {
        var curColor:UIColor
        
        var sortedColors:NSMutableArray = NSMutableArray(capacity: imageColors.count)
        var findDarkTextColor:Bool = !backgroundColor.sca_isDarkColor()
        
        if (imageColors.count > 0) {
            for index in 0...imageColors.count-1 {
                
                var countedColor:CountedColor = imageColors[index]
                
                var curColor:UIColor = countedColor.color.sca_colorWithMinimumSaturation(0.15)
                
                if curColor.sca_isDarkColor() == findDarkTextColor {
                    var colorCount:Int = countedColor.count;
                    
                    //if ( colorCount <= 2 ) // prevent using random colors, threshold should be based on input image size
                    //	continue;
                    
                    var container:CountedColor = CountedColor(color: curColor, count: colorCount)
                    
                    sortedColors.addObject(container)
                }
            }
        }
        
        var finalSortedColors:Array = sortedColors.sortedArrayUsingSelector(Selector("compare:"))
        
        if finalSortedColors.count > 0 {
            for index in 0...finalSortedColors.count-1 {
                
                var curContainer:CountedColor = finalSortedColors[index] as CountedColor
                
                curColor = curContainer.color;
                
                if primaryColor == nil {
                    if curColor.sca_isContrastingColor(backgroundColor) {
                        primaryColor = UnsafeMutablePointer<UIColor>(calloc(1, UInt(sizeof(UIColor))))
                        primaryColor.memory = curColor;
                    }
                } else if secondaryColor == nil {
                    if !primaryColor.memory.sca_isDistinct(curColor) || !curColor.sca_isContrastingColor(backgroundColor) {
                        continue;
                    }
                    secondaryColor = UnsafeMutablePointer<UIColor>(calloc(1, UInt(sizeof(UIColor))))
                    secondaryColor.memory = curColor;
                } else if detailColor == nil {
                    if !secondaryColor.memory.sca_isDistinct(curColor) || !primaryColor.memory.sca_isDistinct(curColor) || !curColor.sca_isContrastingColor(backgroundColor) {
                        continue;
                    }
                    detailColor = UnsafeMutablePointer<UIColor>(calloc(1, UInt(sizeof(UIColor))))
                    detailColor.memory = curColor;
                    break;
                }
            }
        }
    }
    
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

//MARK : Additional classes and necessary extensions

class CountedColor: NSObject {
    
    var color:UIColor
    var count:Int
    
    init (color:UIColor, count:Int)
    {
        self.color = color;
        self.count = count;
        
        super.init()
    }
    
    func compare(object:CountedColor) -> NSComparisonResult
    {
        if ( self.count < object.count )
        {
            return NSComparisonResult.OrderedDescending
        }
        else if ( self.count == object.count )
        {
            return NSComparisonResult.OrderedSame
        }
        
        return NSComparisonResult.OrderedAscending
    }
}

extension UIColor {
    func sca_isDarkColor() -> Bool
    {
        var convertedColor:UIColor = self
        
        var r:CGFloat = CGFloat()
        var g:CGFloat = CGFloat()
        var b:CGFloat = CGFloat()
        var a:CGFloat = CGFloat()
        
        convertedColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        var lum:CGFloat = 0.2126 * r + 0.7152 * g + 0.0722 * b
        
        if lum < 0.5 {
            return true;
        }
        
        return false;
    }
    
    func sca_isBlackOrWhite() -> Bool
    {
        var tempColor:UIColor = self
        
        var r:CGFloat = CGFloat()
        var g:CGFloat = CGFloat()
        var b:CGFloat = CGFloat()
        var a:CGFloat = CGFloat()
        
        tempColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        if (r > 0.91 && g > 0.91 && b > 0.91) {
            return true
        }
        
        if (r < 0.09 && g < 0.09 && b < 0.09) {
            return true
        }
        
        return false
    }
    
    func sca_colorWithMinimumSaturation(minSaturation:CGFloat) -> UIColor
    {
        var tempColor:UIColor = self
        
        var hue:CGFloat        = CGFloat(0.0)
        var saturation:CGFloat = CGFloat(0.0)
        var brightness:CGFloat = CGFloat(0.0);
        var alpha:CGFloat      = CGFloat(0.0);
        
        tempColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        if saturation < minSaturation {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        
        return self;
    }
    
    func sca_isContrastingColor(color:UIColor) -> Bool
    {
        var backgroundColor:UIColor = self;
        var foregroundColor:UIColor = color;
        
        var br: CGFloat = CGFloat(0)
        var bg: CGFloat = CGFloat(0)
        var bb: CGFloat = CGFloat(0)
        var ba: CGFloat = CGFloat(0)
        var fr: CGFloat = CGFloat(0)
        var fg: CGFloat = CGFloat(0)
        var fb: CGFloat = CGFloat(0)
        var fa: CGFloat = CGFloat(0)
        
        backgroundColor.getRed(&br, green:&bg, blue:&bb, alpha:&ba)
        foregroundColor.getRed(&fr, green:&fg, blue:&fb, alpha:&fa)
        
        var bLum:CGFloat = CGFloat(0.2126 * br + 0.7152 * bg + 0.0722 * bb)
        var fLum:CGFloat = CGFloat(0.2126 * fr + 0.7152 * fg + 0.0722 * fb)
        
        var contrast:CGFloat = CGFloat(0);
        
        if bLum > fLum {
            contrast = (bLum + 0.05) / (fLum + 0.05);
        } else {
            contrast = (fLum + 0.05) / (bLum + 0.05);
        }
        
        return contrast > 1.6
    }
    
    func sca_isDistinct(compareColor:UIColor) -> Bool
    {
        var convertedColor:UIColor = self;
        var convertedCompareColor:UIColor = compareColor;
        
        var r: CGFloat = CGFloat(0)
        var g: CGFloat = CGFloat(0)
        var b: CGFloat = CGFloat(0)
        var a: CGFloat = CGFloat(0)
        
        var r1: CGFloat = CGFloat(0)
        var g1: CGFloat = CGFloat(0)
        var b1: CGFloat = CGFloat(0)
        var a1: CGFloat = CGFloat(0)
        
        convertedColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        convertedCompareColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        
        var threshold:CGFloat = CGFloat(0.15)
        
        if fabs(r - r1) > threshold || fabs(g - g1) > threshold || fabs(b - b1) > threshold || fabs(a - a1) > threshold {
            // check for grays, prevent multiple gray colors
            
            if fabs(r - g) < 0.03 && fabs(r - b) < 0.03 {
                if fabs(r1 - g1) < 0.03 && fabs(r1 - b1) < 0.03 {
                    return false
                }
            }
            
            return true
        }
        
        return false
    }
}