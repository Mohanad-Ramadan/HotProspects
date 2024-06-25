//
//  MeView.swift
//  HotProspects
//
//  Created by Mohanad Ramdan on 06/09/2023.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import UserNotifications

struct MeView: View {
    @State var name = "Name"
    @State var emailAddress = "unKnown@mail.com"
    @State var qrCode = UIImage()
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView {
            VStack{
                Divider()
                Image(uiImage: qrCode)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .contextMenu{
                        Button{
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: qrCode)
                        } label:{
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                        }
                    }
                Divider()
                    .frame(width: 189)
                VStack {
                    TextField ("Name", text: $name)
                        .textContentType(.name)
                        .font(.title2)
                    TextField ("Email address", text: $emailAddress)
                        .textContentType(.emailAddress)
                        .font(.footnote)
                }
                .multilineTextAlignment(.center)
                Spacer()
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button("Cancel"){
                        //
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Done"){
                        //
                    }
                }
            }
            
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: updateQrcode)
            .onChange(of: name) { _ in updateQrcode()}
            .onChange(of: emailAddress) { _ in updateQrcode()}
        }
    }
    
    func updateQrcode() {
        qrCode = generateQRCode(from: "\(name)\n\(emailAddress)")
    }
    
    func generateQRCode(from string:String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent){
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
