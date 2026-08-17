//
//  iTermShellIntegrationPasteShellCommandsViewController.m
//  iTerm2SharedARC
//
//  Created by George Nachman on 12/22/19.
//

#import "iTermShellIntegrationPasteShellCommandsViewController.h"

@interface iTermShellIntegrationPasteShellCommandsViewController ()

@property (nonatomic, strong) IBOutlet NSTextField *textField;
@property (nonatomic, strong) IBOutlet NSButton *previewCommandButton1;
@property (nonatomic, strong) IBOutlet NSButton *previewCommandButton2;
@property (nonatomic, strong) IBOutlet NSButton *previewCommandButton3;
@property (nonatomic, strong) IBOutlet NSButton *previewCommandButton4;
@property (nonatomic, strong) IBOutlet NSTextView *previewTextView;
@property (nonatomic, strong) IBOutlet NSViewController *popoverViewController;
@property (nonatomic, strong) IBOutlet NSPopover *popover;
@property (nonatomic, strong) IBOutlet NSButton *continueButton;
@property (nonatomic, strong) IBOutlet NSButton *skipButton;

@end

@implementation iTermShellIntegrationPasteShellCommandsViewController {
    BOOL _busy;
}

- (void)setShell:(iTermShellIntegrationShell)shell {
    _shell = shell;
    if (shell == iTermShellIntegrationShellUnknown) {
        self.continueButton.enabled = NO;
    } else {
        self.continueButton.enabled = YES;
    }
}

- (void)setStage:(int)stage {
    _stage = stage;
    [self update];
}

- (NSString *)waitingText {
    return NSLocalizedString(@"⏳ Waiting for command to complete…", @"UI");
}
- (void)update {
    const int stage = _stage;
    if (stage < 0) {
        self.shell = iTermShellIntegrationShellUnknown;
    }
    NSMutableArray<NSString *> *lines = [NSMutableArray array];
    NSInteger indexToBold = NSNotFound;
    NSString *step;
    NSString *prefix;

    if (stage < 0) {
        prefix = NSLocalizedString(@"1. Discover", @"UI");
    } else if (stage == 0) {
        if (_busy) {
            prefix = self.waitingText;
        } else {
            prefix = NSLocalizedString(@"➡ Select “Continue” to discover", @"UI");
        }
        indexToBold = lines.count;
    } else if (stage > 0) {
        if (self.shell == iTermShellIntegrationShellUnknown) {
            prefix = NSLocalizedString(@"🛑 Your shell is not supported.\n\nOnly bash, fish, tcsh, xonsh, and zsh work with shell integration", @"UI");
        } else {
            prefix = NSLocalizedString(@"✅ Discovered", @"UI");
        }
    }
    if (self.shell == iTermShellIntegrationShellUnknown || (_busy && stage == 0)) {
        step = prefix;
    } else {
        step = [NSString stringWithFormat:NSLocalizedString(@"%@ your shell", @"UI"), prefix];
    }
    if (stage > 0) {
        if (self.shell != iTermShellIntegrationShellUnknown) {
            step = [step stringByAppendingFormat:NSLocalizedString(@": you use “%@”.", @"UI"), iTermShellIntegrationShellString(self.shell)];
        }
    } else if (stage != 0 || !_busy) {
        step = [step stringByAppendingString:@"."];
    }
    [lines addObject:step];

    const BOOL unavailable = (stage == 1 && self.shell == iTermShellIntegrationShellUnknown);
    self.continueButton.enabled = !(unavailable || _busy);
    if (unavailable) {
        self.skipButton.enabled = NO;
    } else {
        if (stage < 1) {
            prefix = NSLocalizedString(@"Step 2. Write", @"UI");
        } else if (stage == 1) {
            if (self.shell == iTermShellIntegrationShellUnknown) {
                prefix = NSLocalizedString(@"Step 2. Write", @"UI");
            } else if (_busy) {
                prefix = self.waitingText;
            } else {
                prefix = NSLocalizedString(@"➡ Select “Continue” to write", @"UI");
            }
            indexToBold = lines.count;
        } else if (stage > 1) {
            prefix = NSLocalizedString(@"✅ Wrote", @"UI");
        }
        if (_busy && stage == 1) {
            step = prefix;
        } else {
            step = [NSString stringWithFormat:NSLocalizedString(@"%@ the shell integration script.", @"UI"), prefix];
        }
        [lines addObject:step];

        int i = 2;
        if (self.installUtilities) {
            i += 1;
            if (stage < 2) {
                prefix = NSLocalizedString(@"Step 3. Install", @"UI");
            } else if (stage == 2 && !_busy) {
                prefix = NSLocalizedString(@"➡ Select “Continue” to install", @"UI");
                indexToBold = lines.count;
            } else if (stage == 2 && _busy) {
                prefix = self.waitingText;
                indexToBold = lines.count;
            } else {
                prefix = NSLocalizedString(@"✅ Installed", @"UI");
            }
            if (_busy && stage == 2) {
                step = prefix;
            } else {
                step = [NSString stringWithFormat:NSLocalizedString(@"%@ iTerm2 utility scripts.", @"UI"), prefix];
            }
            [lines addObject:step];
        }

        // Xonsh auto-loads scripts from rc.d, so no dotfile modification is needed.
        // Show this step as already complete for xonsh.
        if (self.shell == iTermShellIntegrationShellXonsh) {
            if (stage < i) {
                step = [NSString stringWithFormat:NSLocalizedString(@"Step %d. Xonsh auto-loads scripts from rc.d (no dotfile update needed).", @"UI"), i + 1];
            } else {
                step = [NSString stringWithFormat:NSLocalizedString(@"✅ Xonsh auto-loads scripts from rc.d (no dotfile update needed).", @"UI")];
            }
            [lines addObject:step];
        } else {
            if (stage < i) {
                prefix = [NSString stringWithFormat:NSLocalizedString(@"Step %d. Update", @"UI"), i + 1];
            } else if (stage == i && !_busy) {
                prefix = NSLocalizedString(@"➡ Select “Continue” to update", @"UI");
                indexToBold = lines.count;
            } else if (stage == i && _busy) {
                prefix = self.waitingText;
                indexToBold = lines.count;
            } else if (stage > i) {
                prefix = NSLocalizedString(@"✅ Updated", @"UI");
            }
            if (_busy && stage == i) {
                step = prefix;
            } else {
                step =
                [NSString stringWithFormat:NSLocalizedString(@"%@ your shell's dotfile.", @"UI"), prefix];
            }
            [lines addObject:step];
        }
        
        // For xonsh, stage >= i means we're at the dotfile step which is a no-op,
        // so treat it as done. For other shells, we need stage > i.
        BOOL isDone = (stage > i) || (stage >= i && self.shell == iTermShellIntegrationShellXonsh);
        if (isDone) {
            [lines addObject:@""];
            indexToBold = lines.count;
            [lines addObject:NSLocalizedString(@"Done! Select “Continue” to proceed.", @"UI")];
            self.skipButton.enabled = NO;
        } else {
            self.skipButton.enabled = !_busy;
        }
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    NSDictionary *regularAttributes =
    @{ NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]],
       NSForegroundColorAttributeName: [NSColor textColor],
       NSParagraphStyleAttributeName: paragraphStyle
    };
    NSDictionary *boldAttributes =
    @{ NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSize]],
       NSForegroundColorAttributeName: [NSColor textColor],
       NSParagraphStyleAttributeName: paragraphStyle
    };
    [lines enumerateObjectsUsingBlock:^(NSString * _Nonnull string, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *temp = [string stringByAppendingString:@"\n"];
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:temp attributes:idx == indexToBold ? boldAttributes : regularAttributes];
        [attributedString appendAttributedString:as];
    }];
    self.textField.attributedStringValue = attributedString;
    NSString *preview = [self.shellInstallerDelegate shellIntegrationInstallerNextCommandForSendShellCommands];
    NSArray<NSButton *> *buttons = self.previewCommandButtons;
    for (NSInteger i = 0; i < self.previewCommandButtons.count; i++){
        buttons[i].hidden = unavailable || (i != stage) || preview == nil;
        if (_busy && i == stage) {
            [buttons[i] setTitle:NSLocalizedString(@"Send Again", @"Menu")];
        } else {
            [buttons[i] setTitle:NSLocalizedString(@"Preview Command", @"Menu")];
        }
    }
    self.previewTextView.string = preview ?: @"";
}

- (NSArray<NSButton *> *)previewCommandButtons {
    return @[ self.previewCommandButton1, self.previewCommandButton2, self.previewCommandButton3, self.previewCommandButton4 ];
}

- (NSButton *)previewCommandButton {
    NSArray<NSButton *> *buttons = self.previewCommandButtons;
    if (self.stage < 0 || self.stage >= buttons.count) {
        return nil;
    }
    return buttons[self.stage];
}

- (IBAction)previewCommand:(id)sender {
    if (_busy) {
        [self.shellInstallerDelegate shellIntegrationInstallerCancelExpectations];
        [self.shellInstallerDelegate shellIntegrationInstallerSendShellCommands:_stage];
        return;
    }
    self.popover.behavior = NSPopoverBehaviorTransient;
    [self.popoverViewController view];
    self.previewTextView.font = [NSFont fontWithName:@"Menlo" size:12];
    [self.popover showRelativeToRect:self.previewCommandButton.bounds
                              ofView:self.previewCommandButton
                       preferredEdge:NSRectEdgeMaxY];
}

- (IBAction)skip:(id)sender {
    [self.shellInstallerDelegate shellIntegrationInstallerSkipStage];
}

- (IBAction)next:(id)sender {
    [self.shellInstallerDelegate shellIntegrationInstallerSendShellCommands:_stage];
}

- (IBAction)back:(id)sender {
    [self.shellInstallerDelegate shellIntegrationInstallerCancelExpectations];
    if (_stage == 0) {
        [self.shellInstallerDelegate shellIntegrationInstallerBack];
    } else {
        self.stage = self.stage - 1;
    }
}

- (void)setBusy:(BOOL)busy {
    _busy = busy;
    [self update];
}

@end

