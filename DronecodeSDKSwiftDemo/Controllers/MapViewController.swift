//
//  MapViewController.swift
//  DronecodeSDKSwiftDemo
//
//  Created by Marjory Silvestre on 05.04.18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import UIKit
import MAVSDK_Swift
import MapKit
import RxSwift

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    
    // MARK: IBOutlets -------
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var uploadMissionButton: UIButton!
    @IBOutlet weak var toggleRTLButton: UIButton!
    @IBOutlet weak var startMissionButton: UIButton!
    @IBOutlet weak var pauseMissionButton: UIButton!
    @IBOutlet weak var getCurrentIndexButton: UIButton!
    @IBOutlet weak var setCurrentIndexButton: UIButton!
    @IBOutlet weak var downloadMissionButton: UIButton!
    @IBOutlet weak var getMissionCountButton: UIButton!
    @IBOutlet weak var isMissionFinishedButton: UIButton!
    
    @IBOutlet weak var createFlightPathButton: UIButton!
    @IBOutlet weak var centerMapOnUsernButton: UIButton!
    
    // MARK: Location -------
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    let regionRadius: CLLocationDistance = 100
    
    // MARK: Misc -------
    
    private var droneAnnotation: DroneAnnotation!
    private var timer: Timer?
    
    // MARK: Mission -------
    
    private let missionExample:ExampleMission = ExampleMission()
    private var rtlAfterMissionToggleState = false
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set initial location of drone and center map on it
        let initialLocation = CLLocation(latitude: CoreManager.shared().droneState.location2D.latitude , longitude: CoreManager.shared().droneState.location2D.longitude)
        centerMapOnLocation(location: initialLocation)
        
        // init text for feedback and add round corner and border
        feedbackLabel.text = "Welcome"
        feedbackLabel.layer.cornerRadius   = UI_CORNER_RADIUS_BUTTONS
        feedbackLabel?.layer.masksToBounds = true
        feedbackLabel?.layer.borderColor = UIColor.lightGray.cgColor
        feedbackLabel?.layer.borderWidth = 1.0
        
        // set corners for buttons
        uploadMissionButton.layer.cornerRadius   = UI_CORNER_RADIUS_BUTTONS
        startMissionButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        createFlightPathButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        centerMapOnUsernButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        pauseMissionButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        getCurrentIndexButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        setCurrentIndexButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        downloadMissionButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        getMissionCountButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        isMissionFinishedButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        
        // location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        // init mapview delegate
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // drone annotation
        mapView.register(DroneView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(DroneView.self))
        droneAnnotation = DroneAnnotation(title: "Drone", coordinate:initialLocation.coordinate)
        mapView.addAnnotation(droneAnnotation)
        
        // timer to get drone state
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector:  #selector(updateDroneInfosDisplayed), userInfo: nil, repeats: true)
        
        // display mission trace
        self.createMissionTrace(mapView: mapView, listMissionsItems: missionExample.missionItems)
        
        let missionProgressObservable: Observable<Mission.MissionProgress> = CoreManager.shared().drone.mission.missionProgress
        missionProgressObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { missionProgress in
                print("Got mission progress update")
                self.displayFeedback(message:"\(missionProgress.currentItemIndex) / \(missionProgress.missionCount)")
            }, onError: { error in
                print("Error mission progress")
            })
            .disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - IBActions Mission
    
    @IBAction func uploadMissionPressed(_ sender: Any) {
        self.displayFeedback(message:"Upload Mission Pressed")
        
        self.uploadMission()
    }
    
    @IBAction func toggleRTLPressed(_ sender: Any) {
        CoreManager.shared().drone.mission.setReturnToLaunchAfterMission(enable: rtlAfterMissionToggleState)
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: {
                if self.rtlAfterMissionToggleState {
                    self.displayFeedback(message:"Enabled RTL after mission")
                } else {
                    self.displayFeedback(message:"Disabled RTL after mission")
                }
                self.rtlAfterMissionToggleState = !self.rtlAfterMissionToggleState
            }, onError: { (error) in
                if self.rtlAfterMissionToggleState {
                    self.displayFeedback(message: "Enable RTL after mission failed: \(error)")
                } else {
                    self.displayFeedback(message: "Disable RTL after mission failed: \(error)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func startMissionPressed(_ sender: Any) {
        self.displayFeedback(message:"Start Mission Pressed")
        
        // /!\ NEED TO ARM BEFORE START THE MISSION
        CoreManager.shared().drone.action.arm()
            .observeOn(MainScheduler.instance)
            .do(onError: { error in
                self.displayFeedback(message:"Arming failed")
            }, onCompleted: {
                self.startMission()
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func pauseMissionPressed(_ sender: UIButton) {
        self.displayFeedback(message:"Pause Mission Pressed")
        
        if self.pauseMissionButton.titleLabel?.text == "Resume Mission" {
            CoreManager.shared().drone.mission.startMission()
                .observeOn(MainScheduler.instance)
                .do(onError: { error in
                    self.displayFeedback(message: "Resume mission failed \(error)")
                }, onCompleted: {
                    self.displayFeedback(message:"Resume mission with success")
                    self.pauseMissionButton.setTitle("Pause Mission", for: .normal)
                })
                .subscribe()
                .disposed(by: disposeBag)
        } else {
            CoreManager.shared().drone.mission.pauseMission()
                .observeOn(MainScheduler.instance)
                .do(onError: { error in
                    self.displayFeedback(message:"Pausing Mission failed")
                }, onCompleted: {
                    self.displayFeedback(message:"Paused mission with success")
                    self.pauseMissionButton.setTitle("Resume Mission", for: .normal)
                })
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
    
    @IBAction func getIndexPressed(_ sender: UIButton) {
         self.displayFeedback(message:"Get Current Index Pressed")
        
        // DEPRECATED
//        CoreManager.shared().drone.mission.setCurrentMissionItemIndex(index: <#Int32#>)
//            .subscribe(onSuccess: { (index) in
//                self.displayFeedback(message:"Current mission index: \(index)")
//            }, onError: { (error) in
//                self.displayFeedback(message: "Get mission index failed \(error)")
//            })
//            .disposed(by: disposeBag)
    }
    
    @IBAction func setIndexPressed(_ sender: UIButton) {
         self.displayFeedback(message:"Set Current Index Pressed")
        
        CoreManager.shared().drone.mission.setCurrentMissionItemIndex(index: 2)
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: {
                self.displayFeedback(message:"Set mission index to 2.")
            }, onError: { (error) in
                self.displayFeedback(message: "Set mission index failed \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func downloadMissionPressed(_ sender: UIButton) {
         self.displayFeedback(message:"Download Mission Pressed")
        
        CoreManager.shared().drone.mission.downloadMission()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (mission) in
                self.displayFeedback(message:"Downloaded mission")
                print("Mission downloaded: \(mission)")
            }, onError: { (error) in
                self.displayFeedback(message: "Download mission failed \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func getCountPressed(_ sender: UIButton) {
         self.displayFeedback(message:"Get Mission Count Pressed")
        
        // DEPRECATED
//        CoreManager.shared().drone.mission.getMissionCount()
//            .subscribe(onSuccess: { (count) in
//                self.displayFeedback(message:"Mission count: \(count)")
//            }, onError: { (error) in
//                self.displayFeedback(message: "Get mission count failed \(error)")
//            })
//            .disposed(by: disposeBag)
    }
    
    @IBAction func isFinishedPressed(_ sender: UIButton) {
         self.displayFeedback(message:"Is Mission Finished Pressed")
        
        
        CoreManager.shared().drone.mission.isMissionFinished()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (finished) in
                self.displayFeedback(message:"Is mission finished: \(finished)")
            }, onError: { (error) in
                self.displayFeedback(message: "Error checking if mission is finihed \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Center Map and Create Flightpath
    
    @IBAction func centerOnUserPressed(_ sender: Any) {
        if let currentLocationLat = currentLocation?.coordinate.latitude, let currentLocationLong = currentLocation?.coordinate.longitude {
            let latitude:String = String(format: "%.4f", currentLocationLat)
            let longitude:String = String(format: "%.4f", currentLocationLong)
            self.displayFeedback(message:"User coordinates (\(latitude),\(longitude))")
            
            centerMapOnLocation(location: currentLocation!)
        }
    }
    
    @IBAction func createFlightPathPressed(_ sender: Any) {
        let latitude:String = String(format: "%.4f",
                                     mapView.centerCoordinate.latitude)
        let longitude:String = String(format: "%.4f",
                                      mapView.centerCoordinate.longitude)
        self.displayFeedback(message:"Create flightpath at  (\(latitude),\(longitude))")
        
        // remove all annotations and overlays
        //TODO improve : we could just remove annotations that we want to refresh and keep drone annotations instead of recreate it afterward
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        // re-create drone annotation
        droneAnnotation = DroneAnnotation(title: "Drone", coordinate: CoreManager.shared().droneState.location2D)
        mapView.addAnnotation(droneAnnotation)
        
        // create new mission with first point of mission equal to center of the map
        let centerMapLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        missionExample.generateSampleMissionForLocation(location: centerMapLocation)
        self.createMissionTrace(mapView: mapView, listMissionsItems: missionExample.missionItems)
    }
    
    // MARK: - Missions
    
    func uploadMission(){
        
        CoreManager.shared().drone.mission.uploadMission(missionItems: missionExample.missionItems)
            .observeOn(MainScheduler.instance)
            .do(onError: { error in
                self.displayFeedback(message:"Mission uploaded failed \(error)")
                
            }, onCompleted: {
                self.displayFeedback(message:"Mission uploaded with success")
            })
            .subscribe()
            .disposed(by: disposeBag)
        
    }
    
    func startMission(){
        CoreManager.shared().drone.mission.startMission()
            .observeOn(MainScheduler.instance)
            .do(onError: { error in
                self.displayFeedback(message: "Mission started failed \(error)")
            }, onCompleted: {
                self.displayFeedback(message:"Mission started with success")
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helper methods
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - DroneState
    
    @objc func updateDroneInfosDisplayed(_ _timer: Timer?) {
        DispatchQueue.main.async {
            // Update the UI
            self.droneAnnotation.coordinate = CoreManager.shared().droneState.location2D
        }
    }
    
    func displayFeedback(message:String){
        print(message)
        feedbackLabel.text = message
    }
    
    // MARK: - Mission trace
    
    func createMissionTrace(mapView: MKMapView, listMissionsItems : Array<Mission.MissionItem>) {
        var points = [CLLocationCoordinate2D]()
        
        for missionItem in listMissionsItems {
            points.append(CLLocationCoordinate2DMake(missionItem.latitudeDeg, missionItem.longitudeDeg))
        }
        
        let missionTrace = MKPolyline(coordinates: points, count: listMissionsItems.count)
        mapView.add(missionTrace)
        
        // add start pin
        let point1 = CustomPointAnnotation(title: "START")
        let missionItem1 = listMissionsItems[0]
        point1.coordinate = CLLocationCoordinate2DMake(missionItem1.latitudeDeg, missionItem1.longitudeDeg)
        mapView.addAnnotation(point1)
        
        // add stop pin
        let point2 = CustomPointAnnotation(title: "STOP")
        let missionItem2 = listMissionsItems[listMissionsItems.count - 1]
        point2.coordinate = CLLocationCoordinate2DMake(missionItem2.latitudeDeg, missionItem2.longitudeDeg)
        mapView.addAnnotation(point2)
        
    }
    
    // MARK: - Location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        ()
        /*if currentLocation == nil {
         // Zoom to user location
         if let userLocation = locations.last {
         let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
         mapView.setRegion(viewRegion, animated: false)
         }
         }*/
    }
    
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if(annotation is CustomPointAnnotation){
            _ = NSStringFromClass(CustomPinAnnotationView.self)
            let  view :CustomPinAnnotationView = CustomPinAnnotationView(annotation: annotation)
            return view
        }else{
            guard let annotation = annotation as? DroneAnnotation else { return nil }
            
            let identifier = NSStringFromClass(DroneView.self)
            var view: DroneView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? DroneView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = DroneView(annotation: annotation, reuseIdentifier: identifier)
            }
            return view
        }
        
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = .orange
            lineRenderer.lineWidth = 2.0
            return lineRenderer
        }
        fatalError("Fatal error in mapView MKOverlayRenderer")
    }
    
}
