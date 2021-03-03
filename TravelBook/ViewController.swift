//
//  ViewController.swift
//  TravelBook
//
//  Created by Şeyma Nur on 2.03.2021.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

class ViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {

    var annotationTitle = ""
    var annotationSubTitle = ""
    var annotationLatitude = Double()
    var annotationLongtitude = Double()
    var chosenTitle = ""
    var chosenId = UUID()
    var choseLongititude = Double()
    var choseLatitude  = Double()
    var locationManager = CLLocationManager()
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var explanationText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapKit.delegate=self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        //konum bilgisini güncellemek
        locationManager.startUpdatingLocation()
       
        //pin eklemek
        //uzun basınca algılmasını sağlamak
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(choosenLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapKit.addGestureRecognizer(gestureRecognizer)
        
        if chosenTitle != ""{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context  = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Travel")
            let idString  = chosenId.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let title = result.value(forKey: "title") as? String{
                            annotationTitle = title
                            if let subTitle = result.value(forKey: "subTitle") as? String{
                            annotationSubTitle = subTitle
                                if let latitude = result.value(forKey: "latitude") as? Double{
                                    annotationLatitude = latitude
                                    if let longtitude = result.value(forKey: "longititude") as? Double{
                                        annotationLongtitude = longtitude
                                        
                                        let annotion = MKPointAnnotation()
                                        annotion.title = annotationTitle
                                        annotion.subtitle = annotationSubTitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongtitude)
                                        annotion.coordinate = coordinate
                                        mapKit.addAnnotation(annotion)
                                        nameText.text = annotationTitle
                                        explanationText.text = annotationSubTitle
                                        //yerim değiştiğinde lokasyonumun değişmesini istemiyorum
                                        locationManager.stopUpdatingLocation()
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapKit.setRegion(region, animated: true)
                                        
                                    }
                                    
                                }
                        }
                }
                    }
            }
            }catch{
                
            }
            
        }
    }
//navigasyon oluşturma
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if chosenTitle != ""{
            //koordinatlar ve pinler arasında bağlantı sağlıcaz
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongtitude)
            CLGeocoder().reverseGeocodeLocation(requestLocation){
                (placemarks,error) in
                //closure
                if let placemark = placemarks{
                    if placemark.count > 0{
                        let newPlaceMark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlaceMark)
                        item.name = self.annotationTitle
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let reuseId = "aid"
        var pinview = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinview == nil{
            pinview = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            //bilgi kutucuğu
            pinview?.canShowCallout = true
            pinview?.tintColor = UIColor.black
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinview?.rightCalloutAccessoryView = button
            
        }else{
            pinview?.annotation = annotation
            
        }
        return pinview
    }
    @objc func choosenLocation(gestureRecognizer :UILongPressGestureRecognizer){
        //dokunma başamış ise
        if gestureRecognizer.state == .began{
            //haritada ki dokunulan bölgeyi alıyoruz
            let touchedPoint = gestureRecognizer.location(in: self.mapKit)
            //dokunulan bölgenin koordinatını alıyoruz
            let touchedCoordinates = self.mapKit.convert(touchedPoint, toCoordinateFrom: self.mapKit)
            //burda pini oluşturuyoruz
            let annatation = MKPointAnnotation()
            annatation.coordinate = touchedCoordinates
            annatation.title = nameText.text
            annatation.subtitle = explanationText.text
            //haritaya ekledik.
            self.mapKit.addAnnotation(annatation)
            
            choseLatitude = touchedCoordinates.latitude
            choseLongititude = touchedCoordinates.longitude
            
        }
        
    }
    //güncellenen lokasyonları verir
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if chosenTitle == ""{
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude
        )
        //zoom için
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        //koordinat bölgesini belirler
        let region = MKCoordinateRegion(center: location, span:span)
        //o anda görülebilen bölgeyi değiştirir
        mapKit.setRegion(region, animated: true)
        }
        
    }
    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Travel", into: context)
        newPlace.setValue(nameText.text!, forKey: "title")
        newPlace.setValue(explanationText.text, forKey: "subTitle")
        newPlace.setValue(choseLongititude, forKey: "longititude")
        newPlace.setValue(choseLatitude, forKey: "latitude")
        newPlace.setValue(UUID(), forKey: "id")
        do{
            try context.save()
            
        }catch{
            print("error!")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("new"), object: nil)
        navigationController?.popViewController(animated: true)
    }
 
    }
    



