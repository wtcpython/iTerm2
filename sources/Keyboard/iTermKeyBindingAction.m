//
//  iTermKeyBindingAction.m
//  iTerm2SharedARC
//
//  Created by George Nachman on 3/21/20.
//

#import "iTermKeyBindingAction.h"

#import "DebugLogging.h"
#import "iTerm2SharedARC-Swift.h"
#import "ITAddressBookMgr.h"
#import "iTermPasteSpecialViewController.h"
#import "iTermSnippetsModel.h"
#import "NSArray+iTerm.h"
#import "NSDictionary+iTerm.h"
#import "PTYTextView.h"  // just for PTYTextViewSelectionExtensionUnit
#import "ProfileModel.h"

NSString *const iTermKeyBindingDictionaryKeyAction = @"Action";
NSString *const iTermKeyBindingDictionaryKeyParameter = @"Text";
NSString *const iTermKeyBindingDictionaryKeyLabel = @"Label";
NSString *const iTermKeyBindingDictionaryKeyVersion = @"Version";
NSString *const iTermKeyBindingDictionaryKeyEscaping = @"Escaping";
NSString *const iTermKeyBindingDictionaryKeyApplyMode = @"Apply Mode";


static NSString *GetProfileName(NSString *guid) {
    return [[[ProfileModel sharedInstance] bookmarkWithGuid:guid] objectForKey:KEY_NAME];
}

@implementation iTermKeyBindingAction {
    NSDictionary *_dictionary;
}

+ (NSString *)escapedText:(NSString *)text mode:(iTermSendTextEscaping)escaping {
    NSString *temp = text;
    switch (escaping) {
        case iTermSendTextEscapingNone:
            return text;
        case iTermSendTextEscapingCommon:
            return [temp stringByReplacingCommonlyEscapedCharactersWithControls];
        case iTermSendTextEscapingCompatibility:
            temp = [temp stringByReplacingEscapedChar:'n' withString:@"\n"];
            temp = [temp stringByReplacingEscapedChar:'e' withString:@"\e"];
            temp = [temp stringByReplacingEscapedChar:'a' withString:@"\a"];
            temp = [temp stringByReplacingEscapedChar:'t' withString:@"\t"];
            return temp;
        case iTermSendTextEscapingVimAndCompatibility:
            temp = [temp stringByExpandingVimSpecialCharacters];
            temp = [temp stringByReplacingEscapedChar:'n' withString:@"\n"];
            temp = [temp stringByReplacingEscapedChar:'e' withString:@"\e"];
            temp = [temp stringByReplacingEscapedChar:'a' withString:@"\a"];
            temp = [temp stringByReplacingEscapedChar:'t' withString:@"\t"];
            return temp;
        case iTermSendTextEscapingVim:
            return [temp stringByExpandingVimSpecialCharacters];
    }
    assert(NO);
    return @"";
}


+ (instancetype)fromString:(NSString *)string {
    NSData *decoded = [[NSData alloc] initWithBase64EncodedString:string options:0];
    if (!decoded) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:decoded options:0 error:nil];
    if (!dict) {
        return nil;
    }
    return [self withDictionary:dict];
}

- (NSString *)stringValue {
    NSDictionary *dict = [self dictionaryValue];
    if (!dict) {
        return nil;
    }
    NSData *json = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    if (!json) {
        return nil;
    }
    NSData *data = [json base64EncodedDataWithOptions:0];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (instancetype)withDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initWithDictionary:dictionary];
}

+ (instancetype)withAction:(KEY_ACTION)action
                 parameter:(NSString *)parameter
                  escaping:(iTermSendTextEscaping)escaping
                 applyMode:(iTermActionApplyMode)applyMode {
    return [[self alloc] initWithDictionary:@{ iTermKeyBindingDictionaryKeyAction: @(action),
                                               iTermKeyBindingDictionaryKeyParameter: parameter ?: @"",
                                               iTermKeyBindingDictionaryKeyVersion: @2,
                                               iTermKeyBindingDictionaryKeyEscaping: @(escaping),
                                               iTermKeyBindingDictionaryKeyApplyMode: @(applyMode)
    }];
}

+ (instancetype)withAction:(KEY_ACTION)action
                 parameter:(NSString *)parameter
                     label:(NSString *)label
                  escaping:(iTermSendTextEscaping)escaping
                 applyMode:(iTermActionApplyMode)applyMode {
    if (label) {
        return [[self alloc] initWithDictionary:@{ iTermKeyBindingDictionaryKeyAction: @(action),
                                                   iTermKeyBindingDictionaryKeyParameter: parameter ?: @"",
                                                   iTermKeyBindingDictionaryKeyLabel: label,
                                                   iTermKeyBindingDictionaryKeyVersion: @2,
                                                   iTermKeyBindingDictionaryKeyEscaping: @(escaping),
                                                   iTermKeyBindingDictionaryKeyApplyMode: @(applyMode)
        }];
    } else {
        return [[self alloc] initWithDictionary:@{ iTermKeyBindingDictionaryKeyAction: @(action),
                                                   iTermKeyBindingDictionaryKeyParameter: parameter ?: @"",
                                                   iTermKeyBindingDictionaryKeyVersion: @2,
                                                   iTermKeyBindingDictionaryKeyEscaping: @(escaping),
                                                   iTermKeyBindingDictionaryKeyApplyMode: @(applyMode)
        }];
    }
}

+ (NSString *)stringForSelectionMovementUnit:(PTYTextViewSelectionExtensionUnit)unit {
    switch (unit) {
        case kPTYTextViewSelectionExtensionUnitLine:
            return NSLocalizedString(@"By Line", @"UI");
        case kPTYTextViewSelectionExtensionUnitCharacter:
            return NSLocalizedString(@"By Character", @"UI");
        case kPTYTextViewSelectionExtensionUnitWord:
            return NSLocalizedString(@"By Word", @"UI");
        case kPTYTextViewSelectionExtensionUnitBigWord:
            return NSLocalizedString(@"By WORD", @"UI");
        case kPTYTextViewSelectionExtensionUnitMark:
            return NSLocalizedString(@"By Mark", @"UI");
    }
    XLog(@"Unrecognized selection movement unit %@", @(unit));
    return @"";
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (dictionary != nil && ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if (self) {
        _keyAction = [dictionary[iTermKeyBindingDictionaryKeyAction] intValue];
        _parameter = [dictionary[iTermKeyBindingDictionaryKeyParameter] ?: @"" copy];
        _label = [dictionary[iTermKeyBindingDictionaryKeyLabel] ?: @"" copy];
        _applyMode = [dictionary[iTermKeyBindingDictionaryKeyApplyMode] unsignedIntegerValue];

        const int version = [dictionary[iTermKeyBindingDictionaryKeyVersion] intValue];
        if (version == 0) {
            _escaping = iTermSendTextEscapingCompatibility;
        } else if (version == 1) {
            _escaping = iTermSendTextEscapingCommon;
        } else {
            _escaping = [dictionary[iTermKeyBindingDictionaryKeyEscaping] unsignedIntegerValue];
        }
        _dictionary = [dictionary copy];
    }
    return self;
}

- (NSDictionary *)dictionaryValue {
    if (_dictionary) {
        return _dictionary;
    }
    // This is complicated because it wants to avoid changing the dictionary unless it is necessary.
    int version;
    id escaping;
    switch (_escaping) {
        case iTermSendTextEscapingCompatibility:
            version = 0;
            escaping = [NSNull null];
            break;
        case iTermSendTextEscapingCommon:
            version = 1;
            escaping = [NSNull null];
            break;
        default:
            version = 2;
            escaping = @(_escaping);
            break;
    }
    NSDictionary *temp = @{ iTermKeyBindingDictionaryKeyAction: @(_keyAction),
                            iTermKeyBindingDictionaryKeyParameter: _parameter ?: @"",
                            iTermKeyBindingDictionaryKeyLabel: _label ?: [NSNull null],
                            iTermKeyBindingDictionaryKeyVersion: @(version),
                            iTermKeyBindingDictionaryKeyEscaping: escaping,
                            iTermKeyBindingDictionaryKeyApplyMode: @(_applyMode)
    };
    return [temp dictionaryByRemovingNullValues];
}

- (iTermSendTextEscaping)vimEscaping {
    switch (_escaping) {
        case iTermSendTextEscapingNone:
        case iTermSendTextEscapingCommon:
        case iTermSendTextEscapingVim:
            return iTermSendTextEscapingVim;
        case iTermSendTextEscapingCompatibility:
        case iTermSendTextEscapingVimAndCompatibility:
            return iTermSendTextEscapingVimAndCompatibility;
    }
}

- (NSString *)displayName {
    NSString *actionString = nil;

    switch (_keyAction) {
        case KEY_ACTION_MOVE_TAB_LEFT:
            actionString = NSLocalizedString(@"Move Tab Left", @"UI");
            break;
        case KEY_ACTION_MOVE_TAB_RIGHT:
            actionString = NSLocalizedString(@"Move Tab Right", @"UI");
            break;
        case KEY_ACTION_NEXT_MRU_TAB:
            actionString = NSLocalizedString(@"Cycle Tabs Forward", @"UI");
            break;
        case KEY_ACTION_PREVIOUS_MRU_TAB:
            actionString = NSLocalizedString(@"Cycle Tabs Backward", @"UI");
            break;
        case KEY_ACTION_NEXT_PANE:
            actionString = NSLocalizedString(@"Next Pane", @"UI");
            break;
        case KEY_ACTION_PREVIOUS_PANE:
            actionString = NSLocalizedString(@"Previous Pane", @"UI");
            break;
        case KEY_ACTION_NEXT_SESSION:
            actionString = NSLocalizedString(@"Next Tab", @"UI");
            break;
        case KEY_ACTION_NEXT_WINDOW:
            actionString = NSLocalizedString(@"Next Window", @"UI");
            break;
        case KEY_ACTION_PREVIOUS_SESSION:
            actionString = NSLocalizedString(@"Previous Tab", @"UI");
            break;
        case KEY_ACTION_PREVIOUS_WINDOW:
            actionString = NSLocalizedString(@"Previous Window", @"UI");
            break;
        case KEY_ACTION_SCROLL_END:
            actionString = NSLocalizedString(@"Scroll To End", @"UI");
            break;
        case KEY_ACTION_SCROLL_HOME:
            actionString = NSLocalizedString(@"Scroll To Top", @"UI");
            break;
        case KEY_ACTION_SCROLL_LINE_DOWN:
            actionString = NSLocalizedString(@"Scroll One Line Down", @"UI");
            break;
        case KEY_ACTION_SCROLL_LINE_UP:
            actionString = NSLocalizedString(@"Scroll One Line Up", @"UI");
            break;
        case KEY_ACTION_SCROLL_PAGE_DOWN:
            actionString = NSLocalizedString(@"Scroll One Page Down", @"UI");
            break;
        case KEY_ACTION_SCROLL_PAGE_UP:
            actionString = NSLocalizedString(@"Scroll One Page Up", @"UI");
            break;
        case KEY_ACTION_ESCAPE_SEQUENCE:
            actionString = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Send ^[", @"UI"), _parameter];
            break;
        case KEY_ACTION_HEX_CODE:
            actionString = [NSString stringWithFormat: @"%@ %@", NSLocalizedString(@"Send Hex Codes:", @"UI"), _parameter];
            break;
        case KEY_ACTION_VIM_TEXT:
            actionString = [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"Send:", @"UI"), _parameter];
            break;
        case KEY_ACTION_VIM_TEXT_NO_BROADCAST:
            actionString = [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"Send (no broadcast):", @"UI"), _parameter];
            break;
        case KEY_ACTION_TEXT:
            actionString = [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"Send:", @"UI"), _parameter];
            break;
        case KEY_ACTION_SEND_SNIPPET: {
            iTermSnippet *snippet = [[iTermSnippetsModel sharedInstance] snippetWithActionKey:_parameter];
            if (snippet) {
                actionString = [NSString stringWithFormat:NSLocalizedString(@"Send Snippet “%@”", @"UI"), snippet.displayTitle];
            } else {
                actionString = NSLocalizedString(@"Send Deleted Snippet (no action)", @"UI");
            }
            break;
        }
        case KEY_ACTION_COMPOSE:
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Compose “%@”", @"UI"), _parameter];
            break;
        case KEY_ACTION_SEND_TMUX_COMMAND:
            actionString = [NSString stringWithFormat:NSLocalizedString(@"tmux: %@", @"UI"), _parameter];
            break;
        case KEY_ACTION_RUN_COPROCESS:
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Run Coprocess \"%@\"", @"UI"),
						    _parameter];
            break;
        case KEY_ACTION_SELECT_MENU_ITEM: {
            NSArray *parts = [_parameter componentsSeparatedByString:@"\n"];
            actionString = [NSString stringWithFormat:@"%@ “%@”", NSLocalizedString(@"Select Menu Item", @"UI"), parts.firstObject];
            break;
        }
        case KEY_ACTION_NEW_WINDOW_WITH_PROFILE:
            if ([[ProfileModel sharedInstance] bookmarkWithGuid:_parameter]) {
                actionString = [NSString stringWithFormat:NSLocalizedString(@"New Window with \"%@\" Profile", @"UI"), GetProfileName(_parameter)];
            } else {
                actionString = NSLocalizedString(@"New Window with unavailable Profile", @"UI");
            }
            break;
        case KEY_ACTION_NEW_TAB_WITH_PROFILE:
            if ([[ProfileModel sharedInstance] bookmarkWithGuid:_parameter]) {
                actionString = [NSString stringWithFormat:NSLocalizedString(@"New Tab with \"%@\" Profile", @"UI"), GetProfileName(_parameter)];
            } else {
                actionString = NSLocalizedString(@"New Tab with unavailable Profile", @"UI");
            }
            break;
        case KEY_ACTION_SPLIT_HORIZONTALLY_WITH_PROFILE:
            if ([[ProfileModel sharedInstance] bookmarkWithGuid:_parameter]) {
                actionString = [NSString stringWithFormat:NSLocalizedString(@"Split Horizontally with \"%@\" Profile", @"UI"), GetProfileName(_parameter)];
            } else {
                actionString = NSLocalizedString(@"Split Horizontally with unavailable Profile", @"UI");
            }
            break;
        case KEY_ACTION_SPLIT_VERTICALLY_WITH_PROFILE:
            if ([[ProfileModel sharedInstance] bookmarkWithGuid:_parameter]) {
                actionString = [NSString stringWithFormat:NSLocalizedString(@"Split Vertically with \"%@\" Profile", @"UI"), GetProfileName(_parameter)];
            } else {
                actionString = NSLocalizedString(@"Split Vertically with unavailable Profile", @"UI");
            }
            break;
        case KEY_ACTION_SET_PROFILE:
            if ([[ProfileModel sharedInstance] bookmarkWithGuid:_parameter]) {
                actionString = [NSString stringWithFormat:NSLocalizedString(@"Change Profile to \"%@\"", @"UI"), GetProfileName(_parameter)];
            } else {
                actionString = NSLocalizedString(@"Change Profile to unavailable profile", @"UI");
            }
            break;
        case KEY_ACTION_LOAD_COLOR_PRESET:
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Load Color Preset \"%@\"", @"UI"), _parameter];
            break;
        case KEY_ACTION_SEND_C_H_BACKSPACE:
            actionString = NSLocalizedString(@"Send ^H Backspace", @"UI");
            break;
        case KEY_ACTION_SEND_C_QM_BACKSPACE:
            actionString = NSLocalizedString(@"Send ^? Backspace", @"UI");
            break;
        case KEY_ACTION_IGNORE:
            actionString = NSLocalizedString(@"Ignore", @"UI");
            break;
        case KEY_ACTION_BYPASS:
            actionString = NSLocalizedString(@"Bypass Terminal", @"UI");
            break;
        case KEY_ACTION_IR_FORWARD:
            actionString = NSLocalizedString(@"Unsupported Command", @"UI");
            break;
        case KEY_ACTION_IR_BACKWARD:
            actionString = NSLocalizedString(@"Start Instant Replay", @"UI");
            break;
        case KEY_ACTION_SELECT_PANE_LEFT:
            actionString = NSLocalizedString(@"Select Split Pane on Left", @"UI");
            break;
        case KEY_ACTION_SELECT_PANE_RIGHT:
            actionString = NSLocalizedString(@"Select Split Pane on Right", @"UI");
            break;
        case KEY_ACTION_SELECT_PANE_ABOVE:
            actionString = NSLocalizedString(@"Select Split Pane Above", @"UI");
            break;
        case KEY_ACTION_SELECT_PANE_BELOW:
            actionString = NSLocalizedString(@"Select Split Pane Below", @"UI");
            break;
        case KEY_ACTION_DO_NOT_REMAP_MODIFIERS:
            actionString = NSLocalizedString(@"Do Not Remap Modifiers", @"UI");
            break;
        case KEY_ACTION_REMAP_LOCALLY:
            actionString = NSLocalizedString(@"Remap Modifiers in iTerm2 Only", @"UI");
            break;
        case KEY_ACTION_TOGGLE_FULLSCREEN:
            actionString = NSLocalizedString(@"Toggle Fullscreen", @"UI");
            break;
        case KEY_ACTION_TOGGLE_HOTKEY_WINDOW_PINNING:
            actionString = NSLocalizedString(@"Toggle Pin Hotkey Window", @"UI");
            break;
        case KEY_ACTION_UNDO:
            actionString = NSLocalizedString(@"Undo", @"UI");
            break;
        case KEY_ACTION_FIND_REGEX:
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Find Regex “%@”", @"UI"), _parameter];
            break;
        case KEY_FIND_AGAIN_DOWN:
            actionString = NSLocalizedString(@"Find Again Down", @"UI");
            break;
        case KEY_FIND_AGAIN_UP:
            actionString = NSLocalizedString(@"Find Again Up", @"UI");
            break;
        case KEY_ACTION_PASTE_SPECIAL_FROM_SELECTION: {
            NSString *pasteDetails =
                [iTermPasteSpecialViewController descriptionForCodedSettings:_parameter];
            if (pasteDetails.length) {
                actionString = [NSString stringWithFormat:NSLocalizedString(@"Paste from Selection: %@", @"UI"), pasteDetails];
            } else {
                actionString = NSLocalizedString(@"Paste from Selection", @"UI");
            }
            break;
        }
        case KEY_ACTION_PASTE_SPECIAL: {
            NSString *pasteDetails =
                [iTermPasteSpecialViewController descriptionForCodedSettings:_parameter];
            if (pasteDetails.length) {
                actionString = [NSString stringWithFormat:NSLocalizedString(@"Paste: %@", @"UI"), pasteDetails];
            } else {
                actionString = NSLocalizedString(@"Paste", @"UI");
            }
            break;
        }
        case KEY_ACTION_MOVE_END_OF_SELECTION_LEFT:
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Move End of Selection Left %@", @"UI"),
                            [self.class stringForSelectionMovementUnit:_parameter.integerValue]];
            break;
        case KEY_ACTION_MOVE_END_OF_SELECTION_RIGHT:
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Move End of Selection Right %@", @"UI"),
                            [self.class stringForSelectionMovementUnit:_parameter.integerValue]];
            break;
        case KEY_ACTION_MOVE_START_OF_SELECTION_LEFT:
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Move Start of Selection Left %@", @"UI"),
                            [self.class stringForSelectionMovementUnit:_parameter.integerValue]];
            break;
        case KEY_ACTION_MOVE_START_OF_SELECTION_RIGHT:
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Move Start of Selection Right %@", @"UI"),
                            [self.class stringForSelectionMovementUnit:_parameter.integerValue]];
            break;

        case KEY_ACTION_DECREASE_HEIGHT:
            actionString = NSLocalizedString(@"Decrease Height", @"UI");
            break;
        case KEY_ACTION_INCREASE_HEIGHT:
            actionString = NSLocalizedString(@"Increase Height", @"UI");
            break;

        case KEY_ACTION_DECREASE_WIDTH:
            actionString = NSLocalizedString(@"Decrease Width", @"UI");
            break;
        case KEY_ACTION_INCREASE_WIDTH:
            actionString = NSLocalizedString(@"Increase Width", @"UI");
            break;

        case KEY_ACTION_SWAP_PANE_LEFT:
            actionString = NSLocalizedString(@"Swap With Split Pane on Left", @"UI");
            break;
        case KEY_ACTION_SWAP_PANE_RIGHT:
            actionString = NSLocalizedString(@"Swap With Split Pane on Right", @"UI");
            break;
        case KEY_ACTION_SWAP_PANE_ABOVE:
            actionString = NSLocalizedString(@"Swap With Split Pane Above", @"UI");
            break;
        case KEY_ACTION_SWAP_PANE_BELOW:
            actionString = NSLocalizedString(@"Swap With Split Pane Below", @"UI");
            break;
        case KEY_ACTION_TOGGLE_MOUSE_REPORTING:
            actionString = NSLocalizedString(@"Toggle Mouse Reporting", @"UI");
            break;
        case KEY_ACTION_INVOKE_SCRIPT_FUNCTION:
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Call %@", @"UI"), _parameter];
            break;
        case KEY_ACTION_DUPLICATE_TAB:
            actionString = NSLocalizedString(@"Duplicate Tab", @"UI");
            break;
        case KEY_ACTION_SEQUENCE: {
            NSArray<NSString *> *names = [[_parameter keyBindingActionsFromSequenceParameter] mapWithBlock:^id _Nullable(iTermKeyBindingAction * _Nonnull action) {
                return [action displayName];
            }];
            return [names componentsJoinedByString:NSLocalizedString(@", then ", @"UI")];
        }
        default:
            actionString = [NSString stringWithFormat: @"%@ %d", NSLocalizedString(@"Unknown Action ID", @"UI"), _keyAction];
            break;
        case KEY_ACTION_MOVE_TO_SPLIT_PANE:
            actionString = NSLocalizedString(@"Move to Split Pane", @"UI");
            break;
        case KEY_ACTION_SWAP_WITH_NEXT_PANE:
            actionString = NSLocalizedString(@"Swap with Next Pane", @"UI");
            break;
        case KEY_ACTION_SWAP_WITH_PREVIOUS_PANE:
            actionString = NSLocalizedString(@"Swap with Previous Pane", @"UI");
            break;
        case KEY_ACTION_COPY_OR_SEND:
            actionString = NSLocalizedString(@"Copy Selection or Send ^C", @"UI");
            break;
        case KEY_ACTION_PASTE_OR_SEND:
            actionString = NSLocalizedString(@"Paste or Send ^V", @"UI");
            break;
        case KEY_ACTION_ALERT_ON_NEXT_MARK:
            actionString = NSLocalizedString(@"Alert on Next Mark", @"UI");
            break;
        case KEY_ACTION_COPY_INTERPOLATED_STRING:
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Copy Interpolated String “%@”", @"UI"), _parameter];
            break;
        case KEY_ACTION_COPY_MODE:
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Copy mode: %@", @"UI"), _parameter];
            break;
        case KEY_ACTION_TOGGLE_SETTING:
            actionString = [NSString stringWithFormat:NSLocalizedString(@"Toggle %@", @"UI"), self.toggleSettingLabel];
            break;
    }

    switch (self.applyMode) {
        case iTermActionApplyModeCurrentSession:
            return actionString;
        case iTermActionApplyModeAllSessions:
            return [NSString stringWithFormat:NSLocalizedString(@"In all sessions, %@", @"UI"), actionString];
        case iTermActionApplyModeUnfocusedSessions:
            return [NSString stringWithFormat:NSLocalizedString(@"In unfocused sessions, %@", @"UI"), actionString];
        case iTermActionApplyModeAllInWindow:
            return [NSString stringWithFormat:NSLocalizedString(@"In all sessions in the window, %@", @"UI"), actionString];
        case iTermActionApplyModeAllInTab:
            return [NSString stringWithFormat:NSLocalizedString(@"In all sessions in the tab, %@", @"UI"), actionString];
        case iTermActionApplyModeBroadcasting:
            return [NSString stringWithFormat:NSLocalizedString(@"In all broadcasted-to sessions, %@", @"UI"), actionString];
    }
    return actionString;
}

- (BOOL)sendsText {
    switch (self.keyAction) {
        case KEY_ACTION_ESCAPE_SEQUENCE:
        case KEY_ACTION_HEX_CODE:
        case KEY_ACTION_TEXT:
        case KEY_ACTION_SEND_SNIPPET:
        case KEY_ACTION_COMPOSE:
        case KEY_ACTION_SEND_TMUX_COMMAND:
        case KEY_ACTION_VIM_TEXT:
        case KEY_ACTION_VIM_TEXT_NO_BROADCAST:
        case KEY_ACTION_RUN_COPROCESS:
        case KEY_ACTION_SEND_C_H_BACKSPACE:
        case KEY_ACTION_SEND_C_QM_BACKSPACE:
        case KEY_ACTION_PASTE_SPECIAL:
        case KEY_ACTION_PASTE_SPECIAL_FROM_SELECTION:
        case KEY_ACTION_COPY_OR_SEND:
        case KEY_ACTION_PASTE_OR_SEND:
            return YES;
            
        case KEY_ACTION_IGNORE:
        case KEY_ACTION_BYPASS:
        case KEY_ACTION_INVALID:
        case KEY_ACTION_NEXT_SESSION:
        case KEY_ACTION_NEXT_WINDOW:
        case KEY_ACTION_PREVIOUS_SESSION:
        case KEY_ACTION_PREVIOUS_WINDOW:
        case KEY_ACTION_SCROLL_END:
        case KEY_ACTION_SCROLL_HOME:
        case KEY_ACTION_SCROLL_LINE_DOWN:
        case KEY_ACTION_SCROLL_LINE_UP:
        case KEY_ACTION_SCROLL_PAGE_DOWN:
        case KEY_ACTION_SCROLL_PAGE_UP:
        case KEY_ACTION_IR_FORWARD:
        case KEY_ACTION_IR_BACKWARD:
        case KEY_ACTION_SELECT_PANE_LEFT:
        case KEY_ACTION_SELECT_PANE_RIGHT:
        case KEY_ACTION_SELECT_PANE_ABOVE:
        case KEY_ACTION_SELECT_PANE_BELOW:
        case KEY_ACTION_DO_NOT_REMAP_MODIFIERS:
        case KEY_ACTION_TOGGLE_FULLSCREEN:
        case KEY_ACTION_REMAP_LOCALLY:
        case KEY_ACTION_SELECT_MENU_ITEM:
        case KEY_ACTION_NEW_WINDOW_WITH_PROFILE:
        case KEY_ACTION_NEW_TAB_WITH_PROFILE:
        case KEY_ACTION_SPLIT_HORIZONTALLY_WITH_PROFILE:
        case KEY_ACTION_SPLIT_VERTICALLY_WITH_PROFILE:
        case KEY_ACTION_NEXT_PANE:
        case KEY_ACTION_PREVIOUS_PANE:
        case KEY_ACTION_NEXT_MRU_TAB:
        case KEY_ACTION_MOVE_TAB_LEFT:
        case KEY_ACTION_MOVE_TAB_RIGHT:
        case KEY_ACTION_FIND_REGEX:
        case KEY_ACTION_SET_PROFILE:
        case KEY_ACTION_PREVIOUS_MRU_TAB:
        case KEY_ACTION_LOAD_COLOR_PRESET:
        case KEY_ACTION_TOGGLE_HOTKEY_WINDOW_PINNING:
        case KEY_ACTION_UNDO:
        case KEY_ACTION_MOVE_END_OF_SELECTION_LEFT:
        case KEY_ACTION_MOVE_END_OF_SELECTION_RIGHT:
        case KEY_ACTION_MOVE_START_OF_SELECTION_LEFT:
        case KEY_ACTION_MOVE_START_OF_SELECTION_RIGHT:
        case KEY_ACTION_DECREASE_HEIGHT:
        case KEY_ACTION_INCREASE_HEIGHT:
        case KEY_ACTION_DECREASE_WIDTH:
        case KEY_ACTION_INCREASE_WIDTH:
        case KEY_ACTION_SWAP_PANE_LEFT:
        case KEY_ACTION_SWAP_PANE_RIGHT:
        case KEY_ACTION_SWAP_PANE_ABOVE:
        case KEY_ACTION_SWAP_PANE_BELOW:
        case KEY_FIND_AGAIN_DOWN:
        case KEY_FIND_AGAIN_UP:
        case KEY_ACTION_TOGGLE_MOUSE_REPORTING:
        case KEY_ACTION_INVOKE_SCRIPT_FUNCTION:
        case KEY_ACTION_DUPLICATE_TAB:
        case KEY_ACTION_MOVE_TO_SPLIT_PANE:
        case KEY_ACTION_SWAP_WITH_NEXT_PANE:
        case KEY_ACTION_SWAP_WITH_PREVIOUS_PANE:
        case KEY_ACTION_ALERT_ON_NEXT_MARK:
        case KEY_ACTION_COPY_INTERPOLATED_STRING:
        case KEY_ACTION_COPY_MODE:
        case KEY_ACTION_TOGGLE_SETTING:
            break;

        case KEY_ACTION_SEQUENCE:
            return [[self.parameter keyBindingActionsFromSequenceParameter] anyWithBlock:^BOOL(iTermKeyBindingAction *action) {
                return action.sendsText;
            }];
    }
    return NO;
}

- (BOOL)isActionable {
    switch (self.keyAction) {
        case KEY_ACTION_DO_NOT_REMAP_MODIFIERS:
        case KEY_ACTION_REMAP_LOCALLY:
        case KEY_ACTION_BYPASS:
            return NO;

        case KEY_ACTION_IGNORE:
        case KEY_ACTION_ESCAPE_SEQUENCE:
        case KEY_ACTION_HEX_CODE:
        case KEY_ACTION_TEXT:
        case KEY_ACTION_VIM_TEXT:
        case KEY_ACTION_VIM_TEXT_NO_BROADCAST:
        case KEY_ACTION_SEND_SNIPPET:
        case KEY_ACTION_COMPOSE:
        case KEY_ACTION_SEND_TMUX_COMMAND:
        case KEY_ACTION_RUN_COPROCESS:
        case KEY_ACTION_SEND_C_H_BACKSPACE:
        case KEY_ACTION_SEND_C_QM_BACKSPACE:
        case KEY_ACTION_INVALID:
        case KEY_ACTION_NEXT_SESSION:
        case KEY_ACTION_NEXT_WINDOW:
        case KEY_ACTION_PREVIOUS_SESSION:
        case KEY_ACTION_PREVIOUS_WINDOW:
        case KEY_ACTION_SCROLL_END:
        case KEY_ACTION_SCROLL_HOME:
        case KEY_ACTION_SCROLL_LINE_DOWN:
        case KEY_ACTION_SCROLL_LINE_UP:
        case KEY_ACTION_SCROLL_PAGE_DOWN:
        case KEY_ACTION_SCROLL_PAGE_UP:
        case KEY_ACTION_IR_FORWARD:
        case KEY_ACTION_IR_BACKWARD:
        case KEY_ACTION_SELECT_PANE_LEFT:
        case KEY_ACTION_SELECT_PANE_RIGHT:
        case KEY_ACTION_SELECT_PANE_ABOVE:
        case KEY_ACTION_SELECT_PANE_BELOW:
        case KEY_ACTION_TOGGLE_FULLSCREEN:
        case KEY_ACTION_SELECT_MENU_ITEM:
        case KEY_ACTION_NEW_WINDOW_WITH_PROFILE:
        case KEY_ACTION_NEW_TAB_WITH_PROFILE:
        case KEY_ACTION_SPLIT_HORIZONTALLY_WITH_PROFILE:
        case KEY_ACTION_SPLIT_VERTICALLY_WITH_PROFILE:
        case KEY_ACTION_NEXT_PANE:
        case KEY_ACTION_PREVIOUS_PANE:
        case KEY_ACTION_NEXT_MRU_TAB:
        case KEY_ACTION_MOVE_TAB_LEFT:
        case KEY_ACTION_MOVE_TAB_RIGHT:
        case KEY_ACTION_FIND_REGEX:
        case KEY_ACTION_SET_PROFILE:
        case KEY_ACTION_PREVIOUS_MRU_TAB:
        case KEY_ACTION_LOAD_COLOR_PRESET:
        case KEY_ACTION_PASTE_SPECIAL:
        case KEY_ACTION_PASTE_SPECIAL_FROM_SELECTION:
        case KEY_ACTION_TOGGLE_HOTKEY_WINDOW_PINNING:
        case KEY_ACTION_UNDO:
        case KEY_ACTION_MOVE_END_OF_SELECTION_LEFT:
        case KEY_ACTION_MOVE_END_OF_SELECTION_RIGHT:
        case KEY_ACTION_MOVE_START_OF_SELECTION_LEFT:
        case KEY_ACTION_MOVE_START_OF_SELECTION_RIGHT:
        case KEY_ACTION_DECREASE_HEIGHT:
        case KEY_ACTION_INCREASE_HEIGHT:
        case KEY_ACTION_DECREASE_WIDTH:
        case KEY_ACTION_INCREASE_WIDTH:
        case KEY_ACTION_SWAP_PANE_LEFT:
        case KEY_ACTION_SWAP_PANE_RIGHT:
        case KEY_ACTION_SWAP_PANE_ABOVE:
        case KEY_ACTION_SWAP_PANE_BELOW:
        case KEY_FIND_AGAIN_DOWN:
        case KEY_FIND_AGAIN_UP:
        case KEY_ACTION_TOGGLE_MOUSE_REPORTING:
        case KEY_ACTION_INVOKE_SCRIPT_FUNCTION:
        case KEY_ACTION_DUPLICATE_TAB:
        case KEY_ACTION_MOVE_TO_SPLIT_PANE:
        case KEY_ACTION_SWAP_WITH_NEXT_PANE:
        case KEY_ACTION_SWAP_WITH_PREVIOUS_PANE:
        case KEY_ACTION_COPY_OR_SEND:
        case KEY_ACTION_PASTE_OR_SEND:
        case KEY_ACTION_ALERT_ON_NEXT_MARK:
        case KEY_ACTION_COPY_INTERPOLATED_STRING:
        case KEY_ACTION_COPY_MODE:
        case KEY_ACTION_TOGGLE_SETTING:
            break;

        case KEY_ACTION_SEQUENCE:
            return [[self.parameter keyBindingActionsFromSequenceParameter] anyWithBlock:^BOOL(iTermKeyBindingAction *action) {
                return action.isActionable;
            }];
    }
    return YES;
}

@end

@implementation NSString(iTermKeyBindingAction)

+ (instancetype)parameterForKeyBindingActionSequence:(NSArray<iTermKeyBindingAction *> *)actions {
    NSArray<NSDictionary *> *dicts = [actions mapWithBlock:^id _Nullable(iTermKeyBindingAction * _Nonnull action) {
        return action.dictionaryValue;
    }];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dicts options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
}

- (NSArray<iTermKeyBindingAction *> *)keyBindingActionsFromSequenceParameter {
    NSArray<NSDictionary *> *dicts = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    if (![dicts isKindOfClass:[NSArray class]]) {
        return @[];
    }
    return [dicts mapWithBlock:^id _Nullable(NSDictionary * _Nonnull dict) {
        if (![dict isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        return [iTermKeyBindingAction withDictionary:dict];
    }];
}

@end

@implementation iTermKeyBindingAction(ParameterHelper)

- (NSDictionary *)toggleSettingDict {
    NSData *data = [self.parameter dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    NSDictionary *dict = [NSDictionary castFrom:[NSJSONSerialization JSONObjectWithData:data
                                                                                options:0
                                                                                  error:nil]];
    if (!dict) {
        return nil;
    }
    return dict;
}

- (NSString *)toggleSettingKey {
    return [NSString castFrom:self.toggleSettingDict[@"key"]];
}

- (NSString *)toggleSettingLabel {
    return [NSString castFrom:self.toggleSettingDict[@"label"]];
}

- (BOOL)toggleSettingIsProfile {
    return [[NSNumber castFrom:self.toggleSettingDict[@"isProfile"]] boolValue];
}

+ (NSString *)toggleSettingParameterForKey:(NSString *)key
                                 isProfile:(BOOL)isProfile
                                     label:(NSString *)label {
    NSDictionary *dict = @{ @"key": key,
                            @"isProfile": @(isProfile),
                            @"label": label };
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    if (!data) {
        return @"";
    }
    return [data stringWithEncoding:NSUTF8StringEncoding] ?: @"";
}

@end
