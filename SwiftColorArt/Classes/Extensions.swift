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
}

struct RGBAPixel
{
    var red:Byte;
    var green:Byte;
    var blue:Byte;
    var alpha:Byte;
}


class PCCountedColor {

    var color:UIColor
    var count:Int
    
    init (color:UIColor, count:Int)
    {
        self.color = color;
        self.count = count;
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