//
//  DroneView.swift
//  DronecodeSDKSwiftDemo
//
//  Created by Marjory Silvestre on 26.04.18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import Foundation
import MapKit

class DroneView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
            self.transform = CGAffineTransform(rotationAngle: CGFloat(CoreManager.shared().droneState.headingDeg * .pi / 180) )
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        
        willSet {

            calloutOffset = CGPoint(x: -5, y: 5)
     
            image = UIImage(named: "annotation-drone")
            
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = "drone"
            detailCalloutAccessoryView = detailLabel
        }
    }
    
}

