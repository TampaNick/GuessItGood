//
//  QuickStartView.swift
//  GUESSITGOOD
//
//  Created by Nicholas Olivieri on 1/13/25.
//

import SwiftUI
import WebKit


// WebView for displaying an HTML file
struct QuickStart: UIViewRepresentable {
    let htmlFileName: String
    

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()

        if let filePath = Bundle.main.path(forResource: htmlFileName, ofType: "htm") {
            print("HTML File Path: \(filePath)") // Print the full path of the HTML file

            do {
                let fileURL = URL(fileURLWithPath: filePath)
                guard let bundleURL = Bundle.main.resourceURL else {
                    print("Error: Could not get bundle URL")
                    return webView
                }

                let htmlString = try String(contentsOf: fileURL, encoding: .utf8)

                // Use regular expressions to find image paths
                let imageRegex = try! NSRegularExpression(pattern: "<img[^>]*src=\"(.*?)\"")
                let matches = imageRegex.matches(in: htmlString, range: NSRange(location: 0, length: htmlString.utf16.count))

                for match in matches {
                    let imageRange = Range(match.range(at: 1), in: htmlString)!
                    let imagePath = String(htmlString[imageRange])
                    print("Image Path: \(imagePath)")
                }

                webView.loadHTMLString(htmlString, baseURL: bundleURL)
            } catch {
                print("Error loading HTML string: \(error.localizedDescription)")
            }
        } else {
            print("File \(htmlFileName).htm not found in app bundle.")
        }

        return webView
    }

       func updateUIView(_ uiView: WKWebView, context: Context) {
           // No updates needed for this example
       }
   }

    // UserGuideView struct to show the user guide
struct QuickStartView: View {
        var body: some View {
            WebView(htmlFileName: "quickstart") // Replace with the file name without extension
                .edgesIgnoringSafeArea(.all)
        }
    }
