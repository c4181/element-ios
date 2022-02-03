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

class PollIncomingBubbleCell: PollBaseBubbleCell {

    override func setupViews() {
        super.setupViews()
        
        // TODO: Use constants
        let bubbleBackgroundSideMargin: CGFloat = 10
        let messageViewMarginRight: CGFloat = 80 + bubbleBackgroundSideMargin
        let messageLeftMargin: CGFloat = 48 + bubbleBackgroundSideMargin
        
        bubbleCellContentView?.innerContentViewTrailingConstraint.constant = messageViewMarginRight
        bubbleCellContentView?.innerContentViewLeadingConstraint.constant = messageLeftMargin        
    }
    
    override func update(theme: Theme) {
        super.update(theme: theme)
        
        self.bubbleBackgroundColor = theme.roomCellIncomingBubbleBackgroundColor
    }        
}
