//
//  iTermMetalUnavailableReason.m
//  iTerm2SharedARC
//
//  Created by George Nachman on 12/15/21.
//

#import "iTermMetalUnavailableReason.h"

NSString *iTermMetalUnavailableReasonDescription(iTermMetalUnavailableReason reason) {
    switch (reason) {
        case iTermMetalUnavailableReasonNone:
            return nil;
        case iTermMetalUnavailableReasonNoGPU:
            return NSLocalizedString(@"no usable GPU found on this machine.", @"UI");
        case iTermMetalUnavailableReasonDisabled:
            return NSLocalizedString(@"GPU Renderer is disabled in Settings > General.", @"UI");
        case iTermMetalUnavailableReasonNotATerminal:
            return NSLocalizedString(@"the current session is not a terminal.", @"UI");
        case iTermMetalUnavailableReasonLigatures:
            return NSLocalizedString(@"ligatures are enabled. You can disable them in Settings > Profiles > Text > Use ligatures.", @"UI");
        case iTermMetalUnavailableReasonInitializing:
            return NSLocalizedString(@"the GPU renderer is initializing. It should be ready soon.", @"UI");
        case iTermMetalUnavailableReasonInvalidSize:
            return NSLocalizedString(@"the session is too large or too small.", @"UI");
        case iTermMetalUnavailableReasonSessionInitializing:
            return NSLocalizedString(@"the session is initializing.", @"UI");
        case iTermMetalUnavailableReasonTransparency:
            return NSLocalizedString(@"transparent windows are not supported. They can be disabled in Settings > Profiles > Window > Transparency.", @"UI");
        case iTermMetalUnavailableReasonVerticalSpacing:
            return NSLocalizedString(@"the font's vertical spacing set to less than 100%. You can change it in Settings > Profiles > Text > Change Font.", @"UI");
        case iTermMetalUnavailableReasonMarginSize:
            return NSLocalizedString(@"terminal window margins are too small. You can edit them in Settings > Advanced.", @"UI");
        case iTermMetalUnavailableReasonAnnotations:
            return NSLocalizedString(@"annotations or URL shortcuts are open.", @"UI");
        case iTermMetalUnavailableReasonPortholes:
            return NSLocalizedString(@"this session has natively rendered items.", @"UI");
        case iTermMetalUnavailableReasonFindPanel:
            return NSLocalizedString(@"the find panel is open.", @"UI");
        case iTermMetalUnavailableReasonPasteIndicator:
            return NSLocalizedString(@"the paste progress indicator is open.", @"UI");
        case iTermMetalUnavailableReasonAnnouncement:
            return NSLocalizedString(@"an announcement (yellow bar) is visible.", @"UI");
        case iTermMetalUnavailableReasonURLPreview:
            return NSLocalizedString(@"a URL preview is visible.", @"UI");
        case iTermMetalUnavailableReasonWindowResizing:
            return NSLocalizedString(@"the window is being resized.", @"UI");
        case iTermMetalUnavailableReasonDisconnectedFromPower:
            return NSLocalizedString(@"the computer is not connected to power. You can enable GPU rendering while disconnected from power in Settings > General > Advanced GPU Settings.", @"UI");
        case iTermMetalUnavailableReasonIdle:
            return NSLocalizedString(@"the session is idle. You can enable Metal while idle in Settings > Advanced.", @"UI");
        case iTermMetalUnavailableReasonTooManyPanesReason:
            return NSLocalizedString(@"This tab has too many split panes", @"UI");
        case iTermMetalUnavailableReasonNoFocus:
            return NSLocalizedString(@"the window does not have keyboard focus.", @"UI");
        case iTermMetalUnavailableReasonTabInactive:
            return NSLocalizedString(@"this tab is not active.", @"UI");
        case iTermMetalUnavailableReasonTabBarTemporarilyVisible:
            return NSLocalizedString(@"the tab bar is temporarily visible.", @"UI");
        case iTermMetalUnavailableReasonScreensChanging:
            return NSLocalizedString(@"the screen configuration has just changed.", @"UI");
        case iTermMetalUnavailableReasonContextAllocationFailure:
            return NSLocalizedString(@"of a temporary failure to allocate a graphics context.", @"UI");
        case iTermMetalUnavailableReasonTabDragInProgress:
            return NSLocalizedString(@"a tab is being dragged.", @"UI");
        case iTermMetalUnavailableReasonSessionHasNoWindow:
            return NSLocalizedString(@"the current session has no window (this shouldn't happen).", @"UI");
        case iTermMetalUnavailableReasonDropTargetsVisible:
            return NSLocalizedString(@"secure copy drop targets are visible.", @"UI");
        case iTermMetalUnavailableReasonSwipingBetweenTabs:
            return NSLocalizedString(@"swiping between tabs", @"UI");
        case iTermMetalUnavailableReasonSplitPaneBeingDragged:
            return NSLocalizedString(@"a split pane is being dragged.", @"UI");
        case iTermMetalUnavailableReasonWindowObscured:
            return NSLocalizedString(@"the window is mostly under another window.", @"UI");
        case iTermMetalUnavailableReasonLowerPowerMode:
            return NSLocalizedString(@"macOS is in low power mode.", @"UI");
    }

    return NSLocalizedString(@"of an internal error. Please file a bug report!", @"UI");
}
