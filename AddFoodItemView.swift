//
//  AddFoodItemView.swift
//  FoodItemTracker
//

import SwiftUI
import AVFoundation
import UIKit
import Foundation

var strBarName: String = ""

struct AddFoodItemView: View {
    @State var foodItemName: String = ""
    @State var foodItemQuantity: String = ""
    @State var foodItemShelfLife: String = ""
    @State var showAlert = false
    @ObservedObject var myFoodItems: MyFoodItems
    //@State var goToBarcodeScanner = false
    @State private var showSheet = false
    @State private var cameraWasOn = false
    
    

    var body: some View {
        //NavigationView {
        
            VStack(alignment: .center, spacing: 25) {
                
                Button("Use Barcode") {
                    cameraWasOn = true;
                   self.showSheet = true
                }

                TextField("Food Item Name", text: $foodItemName)
                
                TextField("Quantity", text: $foodItemQuantity)
                    .keyboardType(.decimalPad)
                
                TextField("Shelf Life (days)", text: $foodItemShelfLife)
                    .keyboardType(.decimalPad)

                Button(action: {
                    if (strBarName != "" && cameraWasOn) {
                        myFoodItems.addFoodItem(foodItem: FoodItem(name: strBarName, quantity: foodItemQuantity == "" ? 0 : Int(foodItemQuantity)!, shelfLife: foodItemShelfLife == "" ? 0 : Int(foodItemShelfLife)!))
                        cameraWasOn = false;
                        self.showAlert = true
                        
                    } else {
                        myFoodItems.addFoodItem(foodItem: FoodItem(name: foodItemName, quantity: foodItemQuantity == "" ? 0 : Int(foodItemQuantity)!, shelfLife: foodItemShelfLife == "" ? 0 : Int(foodItemShelfLife)!))
                        self.showAlert = true
                    }
                    
                }, label: {
                    Text("Add Set")
                })
                
                
                /*NavigationLink(destination: BarcodeScanner(), isActive: self.$goToBarcodeScanner) {
                    EmptyView()
                }
                Button(action: {
                    self.goToBarcodeScanner = true
                }, label: {
                    Image(systemName: "plus")
                })*/
                
            }
            .sheet(isPresented: $showSheet) {
                BarScanner()
                
            }
            .padding(.horizontal, 15)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Success"), message: Text("Food Item added to your pantry."), dismissButton: .default(Text("Ok")))
            }
            .navigationBarTitle("New Food Item", displayMode: .inline)
            
        }
        
    //}
}


struct AddFoodItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddFoodItemView(myFoodItems: MyFoodItems())
    }
}
struct BarScanner: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ScannerViewController {
        let scanner = ScannerViewController()
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        
    }
    
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        dismiss(animated: true)
    }

    func found(code: String) {
        print(code)
        //insert method to evaluate barcode number
        strBarName = itemName(code: code)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func itemName(code: String) -> String {
        struct Food: Codable {
            var product : Product
        }
        struct Product: Codable {
            //var product : String
            var product_name: String
        }
        let barcodeNum = code
        let str = String(barcodeNum)
        let start = str.index(str.startIndex, offsetBy: 1)
        let range = start..<str.endIndex
        let mySubstring = str[range]
        let barcode = String(mySubstring)
        
        let urlString = "https://world.openfoodfacts.org/api/v0/product/" + barcode + ".json"
        print("url " + urlString)
        
        if let url = URL(string: urlString) {
            do {
                let contents = try String(contentsOf: url)
                 let jsonData = contents.data(using: .utf8)!
                 let decoder = JSONDecoder()
                 let user = try decoder.decode(Food.self, from: jsonData)
                print(user.product.product_name)
                let entryFood = user.product.product_name
                return entryFood
                 //print(contents)
                
            } catch {
                // contents could not be loaded
                print("help")
                return "barcode was not found"
            }
        } else {
            // the URL was bad!
            print("help2")
            return "url was bad"
        }
        
    }
}

