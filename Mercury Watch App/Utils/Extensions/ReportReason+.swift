//
//  ReportReason+.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 08/03/26.
//

import TDLibKit
import Foundation

extension ReportReason {
    var description: String {
        switch self {
        case .reportReasonSpam:
            "Spam"
        case .reportReasonViolence:
            "Violence"
        case .reportReasonPornography:
            "Pornography"
        case .reportReasonChildAbuse:
            "Child Abuse"
        case .reportReasonCopyright:
            "Copyright"
        case .reportReasonUnrelatedLocation:
            "Unrelated Location"
        case .reportReasonFake:
            "Fake Account"
        case .reportReasonIllegalDrugs:
            "Illegal Drugs"
        case .reportReasonPersonalDetails:
            "Personal Details"
        case .reportReasonCustom:
            "Custom"
        }
    }
}
