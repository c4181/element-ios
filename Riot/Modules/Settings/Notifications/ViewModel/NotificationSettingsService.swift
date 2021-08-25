// 
// Copyright 2021 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import Combine

/*
 A service for changing notification settings and keywords
 */
@available(iOS 14.0, *)
protocol NotificationSettingsServiceType {
    /*
     Publisher of all push rules
     */
    var rulesPublisher: AnyPublisher<[MXPushRule], Never> { get }
    /*
     Publisher of content rules.
     */
    var contentRulesPublisher: AnyPublisher<[MXPushRule], Never> { get }
    /*
     Adds a keword.
     
     - Parameters:
     - keyword: The keyword to add
     - enabled: Wether the keyword should be added in the enabled or disabled state.
     */
    func add(keyword: String, enabled: Bool)
    /*
     Removes a keword.
     
     - Parameters:
     - keyword: The keyword to remove
     */
    func remove(keyword: String)
    /*
     Updates the push rule actions.
     
     - Parameters:
     - ruleId: The id of the rule.
     - enabled: Wether the rule should be enabled or disabled.
     - actions: The actions to update with.
     */
    func updatePushRuleActions(for ruleId: String, enabled: Bool, actions: NotificationActions?)
}

@available(iOS 14.0, *)
class NotificationSettingsService: NotificationSettingsServiceType {
    
    private let session: MXSession
    private var cancellables = Set<AnyCancellable>()
    
    @Published private var contentRules = [MXPushRule]()
    @Published private var rules = [MXPushRule]()
    
    var rulesPublisher: AnyPublisher<[MXPushRule], Never> {
        $rules.eraseToAnyPublisher()
    }
    
    var contentRulesPublisher: AnyPublisher<[MXPushRule], Never> {
        $contentRules.eraseToAnyPublisher()
    }
    
    init(session: MXSession) {
        self.session = session
        // publisher of all rule updates
        let rulesUpdated = NotificationCenter.default.publisher(for: NSNotification.Name(rawValue: kMXNotificationCenterDidUpdateRules))
        
        // Set initial value of the content rules
        if let contentRules = session.notificationCenter.rules.global.content as? [MXPushRule] {
            self.contentRules = contentRules
        }
        
        // Observe future updates to content rules
        rulesUpdated
            .compactMap({ _ in self.session.notificationCenter.rules.global.content as? [MXPushRule] })
            .assign(to: &$contentRules)
        
        // Set initial value of rules
        if let flatRules = session.notificationCenter.flatRules as? [MXPushRule] {
            rules = flatRules
        }
        // Observe future updates to rules
        rulesUpdated
            .compactMap({ _ in self.session.notificationCenter.flatRules as? [MXPushRule] })
            .assign(to: &$rules)
    }
    
    func add(keyword: String, enabled: Bool) {
        let index = NotificationIndex.index(enabled: enabled)
        guard let actions = NotificationPushRuleId.keywords.standardActions(for: index)?.actions
        else {
            return
        }
        session.notificationCenter.addContentRuleWithRuleId(matchingPattern: keyword, notify: actions.notify, sound: actions.sound, highlight: actions.highlight)
    }
    
    func remove(keyword: String) {
        guard let rule = session.notificationCenter.rule(byId: keyword) else { return }
        session.notificationCenter.removeRule(rule)
    }
    
    func updatePushRuleActions(for ruleId: String, enabled: Bool, actions: NotificationActions?) {
        guard let rule = session.notificationCenter.rule(byId: ruleId) else { return }
        session.notificationCenter.enableRule(rule, isEnabled: enabled)
        
        if let actions = actions {
            session.notificationCenter.updatePushRuleActions(ruleId,
                                                             kind: rule.kind,
                                                             notify: actions.notify,
                                                             soundName: actions.sound,
                                                             highlight: actions.highlight)
        }
    }
}
