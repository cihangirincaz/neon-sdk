//
//  NeonLongPaywallFAQItem.swift
//  NeonLongOnboardingPlayground
//
//  Created by Tuna Öztürk on 2.12.2023.
//

import Foundation

public class NeonLongPaywallFAQItem: Equatable{
    var question = String()
    var answerTitle = String()
    var answerSubtitle = String()
    
    init(question: String, answerTitle: String, answerSubtitle: String) {
        self.question = question
        self.answerTitle = answerTitle
        self.answerSubtitle = answerSubtitle
    }
    
    public static func == (lhs: NeonLongPaywallFAQItem, rhs: NeonLongPaywallFAQItem) -> Bool {
        return lhs.question == rhs.question &&
        lhs.answerTitle == rhs.answerTitle &&
        lhs.answerSubtitle == rhs.answerSubtitle
    }
}
