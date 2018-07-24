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
//        let image = UIImage(pixelBuffer: lastFrameCaptured.capturedImage)
        let finalImage = CIImage(cvPixelBuffer: lastFrameCaptured.capturedImage).transformed(by: transform)
        let image = convert(cmage:finalImage)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
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
