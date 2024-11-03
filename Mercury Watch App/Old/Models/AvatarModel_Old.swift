//
//  AvatarModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 14/05/24.
//

import SwiftUI
import TDLibKit

struct AvatarModel_Old {
    var tdImage: TDImage?
    var letters: String = ""
    var color: Color = .blue
    var isOnline: Bool = false
}




extension File {
    static var empty: File {
        return File(expectedSize: 0, id: 0, local: LocalFile(canBeDeleted: false, canBeDownloaded: false, downloadOffset: 0, downloadedPrefixSize: 0, downloadedSize: 0, isDownloadingActive: false, isDownloadingCompleted: false, path: ""), remote: RemoteFile(id: "", isUploadingActive: false, isUploadingCompleted: false, uniqueId: "", uploadedSize: 0), size: 0)
    }
}
