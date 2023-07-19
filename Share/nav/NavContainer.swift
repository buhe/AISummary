//
//  NavContainer.swift
//  Share
//
//  Created by 顾艳华 on 2023/7/14.
//

import SwiftUI

struct NavContainer: View {
    @State var step = 0
    let close: () -> Void
    var body: some View {
        switch step {
        case 0:
            Welcome{
                step = 1
            }
        case 1:
            Use {
               close()
            }
        default:
        EmptyView()
        }
    }
}


struct NavContainerPreviews: PreviewProvider {
    static var previews: some View {
        NavContainer{}
    }
}
