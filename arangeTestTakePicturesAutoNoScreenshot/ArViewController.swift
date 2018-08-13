//
//  ArViewController.swift
//  arangeTestTakePicturesAutoNoScreenshot
//
//  Created by Adrien Bigler on 09.07.18.
//  Copyright © 2018 Adrien Bigler. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import VideoToolbox

class ArViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBAction func buttonPressed(_ sender: Any) {
        let orient = UIApplication.shared.statusBarOrientation
        let viewportSize = sceneView.bounds.size
        
        let transform = lastFrameCaptured.displayTransform(for: orient, viewportSize: viewportSize).inverted()
        let cloudpoints = lastFrameCaptured.rawFeaturePoints
        print("========Cloud points======")
        print(cloudpoints?.points)
        print("========================")
        print("========ProjectionMatrix=======")
        print(lastFrameCaptured.camera.viewMatrix(for: orient))
        var point0 = lastFrameCaptured.camera.projectPoint((cloudpoints?.points[0])!, orientation: orient, viewportSize: viewportSize)
        
        
        print("========================")
        var screenshot = sceneView.snapshot()
        UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil);
//        let image = UIImage(pixelBuffer: lastFrameCaptured.capturedImage)
        let finalImage = CIImage(cvPixelBuffer: lastFrameCaptured.capturedImage).transformed(by: transform)
        let image = convert(cmage:finalImage)
        var imageToSave = convert(cmage:finalImage)
        print("viewportSize")
        print(viewportSize)
        print(image.size)
        var ratioy = (image.size.height/viewportSize.height)
        var ratiox = image.size.width/viewportSize.width
        
        for point in (cloudpoints?.points)! {
            
            var pointToDraw = lastFrameCaptured.camera.projectPoint(point, orientation: orient, viewportSize: viewportSize)
            imageToSave = drawRectangleOnImage(image: imageToSave,point:pointToDraw, ratiox: ratiox, ratioy: ratioy)
        }
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
    }
    
    func drawRectangleOnImage(image: UIImage, point: CGPoint, ratiox: CGFloat, ratioy: CGFloat) -> UIImage {
        let imageSize = image.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        
        image.draw(at: CGPoint(x: 0, y: 0))
        
        let rectangle = CGRect(x: point.x*ratiox, y: point.y*ratioy, width: 10, height: 10)
        
        UIColor.white.setFill()
        UIRectFill(rectangle)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    var lastFrameCaptured: ARFrame!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.showsStatistics = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, SCNDebugOptions.showWireframe]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    // ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame){
        lastFrameCaptured = frame
//        lastBufferCaptured = frame.capturedImage
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, nil, &cgImage)
        
        if let cgImage = cgImage {
            self.init(cgImage:cgImage)
        } else {
            return nil
        }
    }
}
