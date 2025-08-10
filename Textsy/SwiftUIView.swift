//
//  SwiftUIView.swift
//  Textsy
//
//  Created by Anika Tabasum on 8/10/25.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        VStack(alignment:.center,spacing:10){
            Image("Nothing")
                .resizable()
                .scaledToFit()
                .frame(width:300,height:300)
              //  .opacity(0.8)
            Text("No Users Found")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .padding(.top,50)
    }
}

#Preview {
    SwiftUIView()
}
