import Foundation
import UIKit
import CoreGraphics

/// SWColorArt
///
/// A class to analyze an UIImage and get it's basic color usage
///
public class SWColorArt {

  var minimunColorCount: Int
  var image: UIImage
  
  public var backgroundColor: UIColor?
  public var primaryColor: UIColor?
  public var secondaryColor: UIColor?
  public var detailColor: UIColor?
  
  var border: Border

  let analyzedBackgroundColor: String = "analyzedBackgroundColor"
  let analyzedPrimaryColor: String    = "analyzedPrimaryColor"
  let analyzedSecondaryColor: String  = "analyzedSecondaryColor"
  let analyzedDetailColor: String     = "analyzedDetailColor"
  
  public convenience init(inputImage: UIImage) {
    let sampleSize: CGSize = CGSize(width: 128, height: 128)

    self.init(inputImage: inputImage, imageSampleSize: sampleSize, minimunColorCount: 0)
  }
  
  public init(inputImage: UIImage, imageSampleSize: CGSize, minimunColorCount: Int) {
    self.minimunColorCount = minimunColorCount
    
    self.image = SWColorArt.resizeImage(inputImage, targetSize: imageSampleSize)
  
    let rect = CGRect(x: 0, y: 0, width: self.image.size.width, height: self.image.size.height)
    border = Border(rect: rect, width: 3, top: true, right: true, bottom: true, left: true)
    
    self.processImage()
  }
  
  private func processImage() {
    
    let storage = Storage()
    
    if storage.doesCacheExistForImage(self.image) {
      let storedColors = storage.loadColorsForImage(self.image)
      
      self.backgroundColor = storedColors.backgroundColor
      self.primaryColor = storedColors.primaryColor
      self.secondaryColor = storedColors.secondaryColor
      self.detailColor = storedColors.detailColor
    } else {
      var colors: [String: UIColor] = self.analyzeImage(self.image)
      
      self.backgroundColor = colors[self.analyzedBackgroundColor]!
      self.primaryColor    = colors[self.analyzedPrimaryColor]!
      self.secondaryColor  = colors[self.analyzedSecondaryColor]!
      self.detailColor     = colors[self.analyzedDetailColor]!

      let storedColors = Colors(backgroundColor: self.backgroundColor!, primaryColor: self.primaryColor!, secondaryColor: self.secondaryColor!, detailColor: self.detailColor!)
      storage.storeColorsForImage(storedColors, image: self.image)
    }
  }
  
  private func analyzeImage(_ inputImage: UIImage) -> [String: UIColor] {
    var imageColors: [CountedColor] = []
    var backgroundColor: UIColor = self.findEdgeColorInImage(inputImage, colors: &imageColors);
    
    var primaryColor: UnsafeMutablePointer<UIColor>?   = nil
    var secondaryColor: UnsafeMutablePointer<UIColor>? = nil
    var detailColor: UnsafeMutablePointer<UIColor>?    = nil
    
    let darkBackground: Bool = backgroundColor.sca_isDarkColor()

    self.findTextColors(imageColors, primaryColor: &primaryColor, secondaryColor: &secondaryColor, detailColor: &detailColor, backgroundColor: &backgroundColor)
    
    var dict: Dictionary = Dictionary<String, UIColor>()

    dict[self.analyzedBackgroundColor] = backgroundColor
    
    if primaryColor == nil {
      if darkBackground {
        dict[self.analyzedPrimaryColor] = UIColor.white()
      } else {
        dict[self.analyzedPrimaryColor] = UIColor.black()
      }
    } else {
      dict[self.analyzedPrimaryColor] = primaryColor?.pointee
    }

    
    if secondaryColor == nil {
      if darkBackground {
        dict[self.analyzedSecondaryColor] = UIColor.white()
      } else {
        dict[self.analyzedSecondaryColor] = UIColor.black()
      }
    } else {
      dict[self.analyzedSecondaryColor] = secondaryColor?.pointee
    }

    
    if detailColor == nil {
      if darkBackground {
        dict[self.analyzedDetailColor] = UIColor.white()
      } else {
        dict[self.analyzedDetailColor] = UIColor.black()
      }
    } else {
      dict[self.analyzedDetailColor] = detailColor?.pointee
    }
    
    return dict
  }
  
  private func findEdgeColorInImage(_ inputImage: UIImage, colors: inout [CountedColor]) -> UIColor {
    let imageRep: CGImage = image.cgImage!;
    
    let width: Int  = imageRep.width
    let height: Int = imageRep.height
    
    let context: CGContext  = self.createBitmapContextFromImage(image.cgImage!)
    let rect: CGRect        = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(width), height: CGFloat(height))
    
    context.draw(in: rect, image: image.cgImage!);

    let imageColors: CountedSet = CountedSet(capacity: Int(width * height))
    let edgeColors: CountedSet  = CountedSet(capacity: Int(height))

    let data   = context.data
    let dataType = UnsafeMutablePointer<UInt8>(data)
    
    for y in 0...height-1 {
      for x in 0...width-1 {
        let offset:Int = Int(4 * (x + y * width))
        
        let alpha = CGFloat((dataType?[offset])!)   / 255.0
        let red   = CGFloat((dataType?[offset+1])!) / 255.0
        let green = CGFloat((dataType?[offset+2])!) / 255.0
        let blue  = CGFloat((dataType?[offset+3])!) / 255.0
        
        let color:UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        
        let point = CGPoint(x: Int(x), y: Int(y))
        
        if border.isPointInBorder(point) {
          edgeColors.add(color)
        } else {
          imageColors.add(color)
        }
      }
    }
    
    let imageEnumerator: NSEnumerator = imageColors.objectEnumerator()
    
    while let curColor = imageEnumerator.nextObject() as? UIColor
    {
      let colorCount: Int = edgeColors.count(for: curColor)
      
      if colorCount >= minimunColorCount {
        let container: CountedColor = CountedColor(color: curColor, count: colorCount)
        colors.append(container)
      }
    }
    
    let enumerator: NSEnumerator = edgeColors.objectEnumerator()
    
    let sortedColors: NSMutableArray = []
    
    while let curColor = enumerator.nextObject() as? UIColor
    {
      let colorCount: Int = edgeColors.count(for: curColor)
      
      if colorCount <= minimunColorCount {
        continue
      }
      
      let container: CountedColor = CountedColor(color: curColor, count: colorCount)
      sortedColors.add(container)
    }
    
    // TODO: Use swifts sorting capabilities for this...
    let finalColors: Array = sortedColors.sortedArray(using: #selector(CountedColor.compare(_:)))
    
    var proposedEdgeColor: CountedColor?
    
    if finalColors.count > 0 {
      
      proposedEdgeColor = finalColors[0] as? CountedColor
      
      if proposedEdgeColor!.color.sca_isBlackOrWhite() {
  
        for i in 1...finalColors.count - 1 {
          let nextProposedColor: CountedColor = finalColors[i] as! CountedColor
          
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
      return UIColor.white()
    }
    
    return proposedEdgeColor!.color;
  }
  
  private func findTextColors(_ imageColors: [CountedColor], primaryColor: inout UnsafeMutablePointer<UIColor>?,
    secondaryColor: inout UnsafeMutablePointer<UIColor>?, detailColor: inout UnsafeMutablePointer<UIColor>?,
    backgroundColor: inout UIColor) {
    var curColor: UIColor
    
    let sortedColors: NSMutableArray = NSMutableArray(capacity: imageColors.count)
    let findDarkTextColor: Bool = !backgroundColor.sca_isDarkColor()
    
    if (imageColors.count > 0) {
      for index in 0...imageColors.count-1 {
        
        let countedColor: CountedColor = imageColors[index]
        
        let curColor: UIColor = countedColor.color.sca_colorWithMinimumSaturation(0.15)
        
        if curColor.sca_isDarkColor() == findDarkTextColor {
          let colorCount: Int = countedColor.count;
          
          //if ( colorCount <= 2 ) // prevent using random colors, threshold should be based on input image size
          //	continue;
          
          let container: CountedColor = CountedColor(color: curColor, count: colorCount)
          
          sortedColors.add(container)
        }
      }
    }
    
    var finalSortedColors: Array = sortedColors.sortedArray(using: #selector(CountedColor.compare(_:)))
    
    if finalSortedColors.count > 0 {
      for index in 0...finalSortedColors.count-1 {
        
        let curContainer: CountedColor = finalSortedColors[index] as! CountedColor
        
        curColor = curContainer.color;
        
        if primaryColor == nil {
          if curColor.sca_isContrastingColor(backgroundColor) {
            primaryColor = UnsafeMutablePointer<UIColor>(calloc(1, sizeof(UIColor)))
            primaryColor?.pointee = curColor;
          }
        } else if secondaryColor == nil {
          if !(primaryColor?.pointee.sca_isDistinct(curColor))! || !curColor.sca_isContrastingColor(backgroundColor) {
            continue;
          }
          secondaryColor = UnsafeMutablePointer<UIColor>(calloc(1, sizeof(UIColor)))
          secondaryColor?.pointee = curColor;
        } else if detailColor == nil {
          if
            !(secondaryColor?.pointee.sca_isDistinct(curColor))! ||
            !(primaryColor?.pointee.sca_isDistinct(curColor))! ||
            !curColor.sca_isContrastingColor(backgroundColor) {
            continue;
          }
          detailColor = UnsafeMutablePointer<UIColor>(calloc(1, sizeof(UIColor)))
          detailColor?.pointee = curColor;
          break;
        }
      }
    }
  }
  
  private func createBitmapContextFromImage(_ inImage: CGImage) -> CGContext {
    let pixelsWide: Int = inImage.width
    let pixelsHigh: Int = inImage.height

    let bitmapBytesPerRow: Int = Int(pixelsWide * 4)
    let bitmapByteCount: Int   = Int(pixelsHigh) * bitmapBytesPerRow

    let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()

    let bitmapData: UnsafeMutablePointer<Void> = malloc(bitmapByteCount)
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

    let context: CGContext = CGContext(data: bitmapData, width: pixelsWide, height: pixelsHigh, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
    
    return context
  }
  
  class func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
    let size: CGSize = image.size
    
    let widthRatio: CGFloat  = targetSize.width  / image.size.width
    let heightRatio: CGFloat = targetSize.height / image.size.height
    
    var newSize: CGSize
    
    if widthRatio > heightRatio {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    let rect: CGRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    return newImage
  }
}

//MARK: Additional classes and necessary extensions


/// CountedColor
///
/// A class to keep track of times a color appears
///
public class CountedColor: NSObject {
  
  let color: UIColor
  let count: Int
  
  init (color: UIColor, count: Int) {
    self.color = color;
    self.count = count;
    
    super.init()
  }
  
  func compare(_ object: CountedColor) -> ComparisonResult {
    if self.count < object.count  {
      return ComparisonResult.orderedDescending
    } else if self.count == object.count {
      return ComparisonResult.orderedSame
    }
    
    return ComparisonResult.orderedAscending
  }
}

extension UIColor {
  public func sca_isDarkColor() -> Bool {
    let convertedColor: UIColor = self
    
    var r: CGFloat = CGFloat()
    var g: CGFloat = CGFloat()
    var b: CGFloat = CGFloat()
    var a: CGFloat = CGFloat()
    
    convertedColor.getRed(&r, green: &g, blue: &b, alpha: &a)
    
    let lum: CGFloat = 0.2126 * r + 0.7152 * g + 0.0722 * b
    
    if lum < 0.5 {
      return true;
    }
    
    return false;
  }
  
  public func sca_isBlackOrWhite() -> Bool {
    let tempColor: UIColor = self
    
    var r: CGFloat = CGFloat()
    var g: CGFloat = CGFloat()
    var b: CGFloat = CGFloat()
    var a: CGFloat = CGFloat()
    
    tempColor.getRed(&r, green: &g, blue: &b, alpha: &a)
    
    if r > 0.91 && g > 0.91 && b > 0.91 {
      return true
    }
    
    if r < 0.09 && g < 0.09 && b < 0.09 {
      return true
    }
    
    return false
  }
  
  public func sca_colorWithMinimumSaturation(_ minSaturation: CGFloat) -> UIColor {
    let tempColor: UIColor = self
    
    var hue: CGFloat        = CGFloat(0.0)
    var saturation: CGFloat = CGFloat(0.0)
    var brightness: CGFloat = CGFloat(0.0);
    var alpha: CGFloat      = CGFloat(0.0);
    
    tempColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    
    if saturation < minSaturation {
      return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    return self;
  }
  
  public func sca_isContrastingColor(_ color: UIColor) -> Bool {
    let backgroundColor: UIColor = self;
    let foregroundColor: UIColor = color;
    
    var br: CGFloat = CGFloat(0)
    var bg: CGFloat = CGFloat(0)
    var bb: CGFloat = CGFloat(0)
    var ba: CGFloat = CGFloat(0)
    var fr: CGFloat = CGFloat(0)
    var fg: CGFloat = CGFloat(0)
    var fb: CGFloat = CGFloat(0)
    var fa: CGFloat = CGFloat(0)
    
    backgroundColor.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
    foregroundColor.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
    
    let bLum: CGFloat = CGFloat(0.2126 * br + 0.7152 * bg + 0.0722 * bb)
    let fLum: CGFloat = CGFloat(0.2126 * fr + 0.7152 * fg + 0.0722 * fb)
    
    var contrast: CGFloat = CGFloat(0);
    
    if bLum > fLum {
      contrast = (bLum + 0.05) / (fLum + 0.05);
    } else {
      contrast = (fLum + 0.05) / (bLum + 0.05);
    }
    
    return contrast > 1.8
  }
  
  public func sca_isDistinct(_ compareColor: UIColor) -> Bool {
    let convertedColor: UIColor = self;
    let convertedCompareColor: UIColor = compareColor;
    
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
    
    let threshold:CGFloat = CGFloat(0.15)
    
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
