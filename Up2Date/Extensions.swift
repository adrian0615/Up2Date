//
//  Extensions.swift
//  Up2Date
//
//  Created by Brandon Stokes on 9/6/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import Foundation


extension String {
    
    //Checks for valid email address
    var isValidEmailAddress: Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let linkDetector = try? NSDataDetector(types: types.rawValue)
        let range = NSMakeRange(0, self.count)
        let result = linkDetector?.firstMatch(in: self, options: .reportCompletion, range: range)
        let scheme = result?.url?.scheme ?? ""
        return scheme == "mailto" && result?.range.length == self.count
    }

    //Checks for valid password
    var isValidPassword: Bool {
        var numTrue = false
        var capsTrue = false
        
        for char in self {
            if Int(String(char)) != nil {
                numTrue = true
            }
            if String(char) == String(char).capitalized {
                capsTrue = true
            }
        }
        if numTrue == true && capsTrue == true && self.count > 7 {
            return true
        } else {
            return false
        }
    }
    
}

//Resizes Image
extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

//Downloads Image for showing
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleToFill) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleToFill) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    func downloadedFrom2(link: String, contentMode mode: UIViewContentMode = .scaleToFill) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
