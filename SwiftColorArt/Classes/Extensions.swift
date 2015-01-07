import Foundation
import UIKit

extension UIColor {
    func pc_isDarkColor() -> Bool
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
    
    func pc_isBlackOrWhite() -> Bool
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
    
    func pc_colorWithMinimumSaturation(minSaturation:CGFloat) -> UIColor
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
    
    func pc_isContrastingColor(color:UIColor) -> Bool
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
        
        //return contrast > 3.0; //3-4.5
        return contrast > 1.6;
    }
    
    func pc_isDistinct(compareColor:UIColor) -> Bool
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
        
        var threshold:CGFloat = CGFloat(0.25) //.15
    
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

struct RGBAPixel
{
    var red:Byte;
    var green:Byte;
    var blue:Byte;
    var alpha:Byte;
}


class PCCountedColor: NSObject {

    var color:UIColor
    var count:Int
    
    init (color:UIColor, count:Int)
    {
        self.color = color;
        self.count = count;

        super.init()
    }
    
    func compare(object:PCCountedColor) -> NSComparisonResult
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