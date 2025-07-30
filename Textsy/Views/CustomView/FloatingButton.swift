


import SwiftUI

struct FloatingButton: View {
    var icon: String
    var backgroundColor: Color = .blue
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack{
                Text("Skip ")
                Image(systemName:icon)
              } .frame(width: 160,height: 50)
                .font(.system(size:25, weight:.bold))
                .background(backgroundColor)
                .padding(20)

        }
   
        .frame(width: 160,height: 50)
            .cornerRadius(20)
            .shadow(color:.appbar,radius: 5)
            .foregroundColor(.white)
         
        
           
           
    }
}
#Preview("ExploreView - Dark Mode") {
    FloatingButton(icon:"arrow.right.to.line") {
    }
}
