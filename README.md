# SwiftColorArt

Is a demo application that includes a singe Swift file with all classes and extension necessary to create a font color schema matching to an image (similiar to what iTunes does).

This work is inspired by a lot of previous work from other people. It is also my first Swift project. [You can read the whole story here](https://www.jangregor.me/site/blog/2)

Usage is pretty simple and always yields a result (fallback colors are included)

    var swiftColorArt:SwiftColorArt = SwiftColorArt(inputImage: image)
      
    self.view.backgroundColor = swiftColorArt.backgroundColor!
      
    self.primaryColorLabel.textColor    = swiftColorArt.primaryColor!
    self.secondaryColorLabel.textColor  = swiftColorArt.secondaryColor!
    self.detailColorLabel.textColor     = swiftColorArt.detailColor!

![Screenshot](https://www.jangregor.me/site/storage/Blog/SwiftColorArtRelease.png)

**Please note that this is a work in progress performance and memory footprint need major improments and additional features will also be implemented in the future. Feel free to post issues or create pull requests**
