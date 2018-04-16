//import UIKit
//
//extension UIImage {
//    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
//        let radiansToDegrees: (CGFloat) -> CGFloat = {
//            return $0 * (180.0 / CGFloat(M_PI))
//        }
//        let degreesToRadians: (CGFloat) -> CGFloat = {
//            return $0 / 180.0 * CGFloat(M_PI)
//        }
//        
//        // calculate the size of the rotated view's containing box for our drawing space
//        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
//        let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees));
//        rotatedViewBox.transform = t
//        let rotatedSize = rotatedViewBox.frame.size
//
//        // Create the bitmap context
//        UIGraphicsBeginImageContext(rotatedSize)
//        let bitmap = UIGraphicsGetCurrentContext()
//        
//        // Move the origin to the middle of the image so we will rotate and scale around the center.
//        CGContextTranslateCTM(bitmap!, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
//
//        //   // Rotate the image context
//        CGContextRotateCTM(bitmap!, degreesToRadians(degrees));
//
//        // Now, draw the rotated/scaled image into the context
//        var yFlip: CGFloat
//        
//        if(flip){
//            yFlip = CGFloat(-1.0)
//        } else {
//            yFlip = CGFloat(1.0)
//        }
//        
//        CGContextScaleCTM(bitmap!, yFlip, -1.0)
//        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
//
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return newImage
//    }
//}

