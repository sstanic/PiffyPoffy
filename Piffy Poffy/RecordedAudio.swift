//
//  RecordedAudio.swift
//  Piffy Poffy
//
//  Created by Sascha Stanic on 24.03.15.
//  Copyright (c) 2015 Sascha Stanic. All rights reserved.
//

import Foundation

// This is a data model class.
// Data:
// - File path to the audio file (url)
// - Audio title
class RecordedAudio: NSObject{
    var filePathUrl: NSURL!
    var title: String!
    
    init(filePathUrl: NSURL, title: String){
        self.filePathUrl = filePathUrl
        self.title = title
    }
}
