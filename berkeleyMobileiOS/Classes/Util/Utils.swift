
import UIKit


// Get class name of obj as string.
func className(_ obj: AnyObject) -> String
{
    return "\(type(of: obj))"
}

// Globally set the status bar style/color.
func setStatusBarStyle(_ style: UIStatusBarStyle)
{
    UIApplication.shared.statusBarStyle = style
}
