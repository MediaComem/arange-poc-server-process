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
        
        var capturedFrame = lastFrameCaptured
        let transform = capturedFrame!.displayTransform(for: orient, viewportSize: viewportSize).inverted()
        let cloudpoints = capturedFrame!.rawFeaturePoints
        
        print("========Cloud points======")
        print(cloudpoints?.points)
        print("========================")
        print("========ViewMatrixProjectionMatrix=======")
        print(capturedFrame!.camera.viewMatrix(for: orient))
        print("========================")
        print("========CameraIntrasincs=======")
        let cameraIntrasincs = capturedFrame?.camera.intrinsics
        print(cameraIntrasincs)
        print("========================")
        print("========ProjectionMatrix=======")
        print(capturedFrame?.camera.projectionMatrix)
        print("========================")
        print("========ViewportSize=======")
        print(viewportSize)
        print("========================")
        print("========imageResolution=======")
        print(capturedFrame?.camera.imageResolution)
        print("========================")
        var screenshot = sceneView.snapshot()
        var pointsToDraw = cloudpoints?.points
        
        
        UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil);
//        let image = UIImage(pixelBuffer: lastFrameCaptured.capturedImage)
        let finalImage = CIImage(cvPixelBuffer: (capturedFrame?.capturedImage)!).transformed(by: transform)
        let image = convert(cmage:finalImage)
        var imageToSave = convert(cmage:finalImage)

        print(image.size)
        var ratioy = (image.size.height/viewportSize.height)
        var ratiox = image.size.width/viewportSize.width
        print("========Ratio=======")
        print(ratiox)
        print(ratioy)
        print("========================")
        var points2D: [CGPoint] = []
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            for point in (pointsToDraw)! {
                autoreleasepool {
                    var pointToDraw = capturedFrame?.camera.projectPoint(point, orientation: orient, viewportSize: viewportSize)
                    var point2D: CGPoint
                    (imageToSave, point2D) = self.drawRectangleOnImage(image: imageToSave,point:pointToDraw!, ratiox: ratiox, ratioy: ratioy)
                    points2D.append(point2D)
                }
            }
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
                UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
                print("========Points2D=======")
                print(points2D)
                print("=======================")
            }
        }
    }
    
    func drawRectangleOnImage(image: UIImage, point: CGPoint, ratiox: CGFloat, ratioy: CGFloat) -> (UIImage,CGPoint) {
        
        let imageSize = image.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        
        image.draw(at: CGPoint(x: 0, y: 0))
        let point2d = CGPoint(x: point.x*ratiox, y: point.y*ratioy)
        let rectangle = CGRect(x: point.x*ratiox, y: point.y*ratioy, width: 10, height: 10)
        
        UIColor.white.setFill()
        UIRectFill(rectangle)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return (newImage!,point2d)
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
