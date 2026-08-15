//
//  iTermApplicationDelegate.swift
//  iTerm2
//
//  Created by George Nachman on 3/28/25.
//

@objc
extension iTermApplicationDelegate {
    @objc
    func registerMenuTips() {
        guard let mainMenu = NSApp.mainMenu else {
            return
        }
        struct Tip {
            var identifier: String
            var imageName: String?
            var text: String
        }

        let toolbeltText = NSLocalizedString("""
        The **Toolbelt** provides a versatile, dockable sidebar that offers quick access to frequently used features and information. It supports multiple panels that can be displayed simultaneously, including clipboard history, recently opened directories, command history, a scratchpad for notes, and more.
        """, comment: "UI")

        let tips = [
            Tip(identifier: "Toolbelt",
                imageName: "Toolbelt-Screenshot",
                text: toolbeltText),
            Tip(identifier: "Show Toolbelt",
                imageName: "Toolbelt-Screenshot",
                text: toolbeltText),
            Tip(identifier: "Split Vertically with Current Profile",
                imageName: "VerticalSplit",
                text: NSLocalizedString("Splits the current session vertically, placing a new session in the right half. The new session inherits the profile of the current session, including any changes made in `Session > Edit Session`.", comment: "UI")),
            Tip(identifier: "Split Horizontally with Current Profile",
                imageName: "HorizontalSplit",
                text: NSLocalizedString("Splits the current session horizontally, placing a new session in the bottom half. The new session inherits the profile of the current session, including any changes made in `Session > Edit Session`.", comment: "UI")),
            Tip(identifier: "Split Vertically…",
                imageName: "VerticalSplit",
                text: NSLocalizedString("Prompts you to select a profile and then splits the current session vertically, placing the new session in the right half.", comment: "UI")),
            Tip(identifier: "Split Horizontally…",
                imageName: "HorizontalSplit",
                text: NSLocalizedString("Prompts you to select a profile and then splits the current session horizontally, placing the new session in the bottom half.", comment: "UI")),
            Tip(identifier: "tmux.Dashboard",
                imageName: "TmuxDashboard",
                text: NSLocalizedString("The **tmux Dashboard** helps you switch between tmux sessions, show and hide windows, and administer other features of tmux without needing to use tmux’s commands.", comment: "UI")),
            Tip(identifier: "Paste Special.Advanced Paste…",
                imageName: "AdvancedPaste",
                text: NSLocalizedString("**Advanced Paste** lets you edit text before pasting, remove control characters, convert tabs, base64-encode, and perform regular expression substitutions. It also lets you fine-tune how quickly pasted text is sent.", comment: "UI")),
            Tip(identifier: "Render Selection Natively",
                imageName: "RenderNatively",
                text: NSLocalizedString("**Render Natively** shows a nicely formatted, syntax-highlighted rendition of a document. For example, Markdown renders beautifully. It also allows for horizontal scrolling, making it a convenient way to view log files.", comment: "UI")),
            Tip(identifier: "Paste Special.Warn Before Multi-Line Paste",
                text: NSLocalizedString("You’ll be prompted any time you paste text containing a newline. See also **Limit Multi-Line Paste Warning to Shell Prompt**.", comment: "UI")),
            Tip(identifier: "Paste Special.Limit Multi-Line Paste Warning to Shell Prompt",
                text: NSLocalizedString("This is effective only when **Warn Before Multi-Line Paste** is enabled. It also requires Shell Integration. When enabled, it suppresses confirmation when pasting text containing a newline if you are not at a shell prompt.", comment: "UI")),
            Tip(identifier: "Paste Special.Warn Before Pasting One Line Ending in a Newline at Shell Prompt",
                text: NSLocalizedString("If enabled, you’ll be prompted to confirm that you wish to send a newline when pasting a single line of text ending in a newline. Shell Integration is required.", comment: "UI")),
            Tip(identifier: "Engage Artificial Intelligence",
                imageName: "AIMenuTip",
                text: NSLocalizedString("When selected at a shell prompt (provided Shell Integration is installed) or in the Composer, it sends the current command to the configured AI system along with a prompt for it to generate a command. If no input is provided, you’ll be asked to give instructions. The generated command goes into the Composer.", comment: "UI")),
            Tip(identifier: "Explain Output with AI",
                imageName: "AIExplainTip",
                text: NSLocalizedString("This is meant to be used at the shell prompt after executing a command. It requires Shell Integration. The output of the preceding (or selected) command is sent to AI, which annotates the output and opens a chat window for further discussion.", comment: "UI")),
            Tip(identifier: "Edit.Snippets",
                imageName: "SnippetsTip",
                text: NSLocalizedString("Snippets are pieces of text that you save to reuse later. They’re great for frequently used commands, hard-to-remember directories, and much more.", comment: "UI")),
            Tip(identifier: "Edit.Actions",
                imageName: "ActionsMenuTip",
                text: NSLocalizedString("Actions are saved instructions for iTerm2. For example, you could create an action that opens a new window and then creates a split pane.", comment: "UI")),
            Tip(identifier: "Set Default Width",
                text: NSLocalizedString("Records the current width of the toolbelt for use in newly created windows.", comment: "UI")),
            Tip(identifier: "Toolbelt.Actions",
                imageName: "ActionsMenuTip",
                text: NSLocalizedString("Actions are saved instructions for iTerm2. For example, you could create an action that opens a new window and then creates a split pane.", comment: "UI")),
            Tip(identifier: "Selection Respects Soft Boundaries",
                imageName: "SelectionRespectsSoftBoundariesMenuTip",
                text: NSLocalizedString("When enabled, dividers rendered by programs like vim or emacs are detected, and text selection wraps around them.", comment: "UI")),
            Tip(identifier: "Find.Filter",
                imageName: "FilterMenuTip",
                text: NSLocalizedString("**Filter** allows you to hide any lines that do not match a search query, which can be a substring or regular expression. It updates live as new text arrives.", comment: "UI")),
            Tip(identifier: "Marks and Annotations.Set Mark",
                text: NSLocalizedString("A **Mark** appears as a blue triangle in the left margin. You can easily navigate among marks using **Jump to Mark**, **Next Mark**, and **Previous Mark**. If Shell Integration is enabled, a Mark is automatically added at each shell prompt.", comment: "UI")),
            Tip(identifier: "Set Named Mark",
                text: NSLocalizedString("A **Named Mark** appears as a blue triangle in the left margin. In addition to being easy to navigate with **Next Mark** and **Previous Mark**, you can also find Named Marks in the Toolbelt’s **Named Marks** tool.", comment: "UI")),
            Tip(identifier: "Toolbelt.Named Marks",
                text: NSLocalizedString("A **Named Mark** appears as a blue triangle in the left margin. In addition to being easy to navigate with **Next Mark** and **Previous Mark**, you can also find Named Marks in this Toolbelt tool.", comment: "UI")),
            Tip(identifier: "Fold Selected Lines",
                imageName: "FoldMenuTip",
                text: NSLocalizedString("**Fold** lets you collapse multiple lines into a single line to hide distracting text. You can always unfold it by clicking the arrow in the margin, selecting the text and using **Edit > Unfold in Selection**, or right-clicking and choosing **Unfold**.", comment: "UI")),
            Tip(identifier: "Toolbelt.Captured Output",
                imageName: "CapturedOutputMenuTip",
                text: NSLocalizedString("**Captured Output** works in conjunction with a Trigger to detect interesting text in the terminal and make it easy to find. The Toolbelt tool shows a list of captured text. You can click to navigate to it or double-click to enter a programmable command. This is useful for finding errors in the output of a build command, for example. It requires Shell Integration.", comment: "UI")),
            Tip(identifier: "Toolbelt.Codecierge",
                imageName: "CodeciergeMenuTip",
                text: NSLocalizedString("**Codecierge** uses AI to help you achieve a goal. Tell it what you want to do, and it can watch your terminal to interpret output and suggest commands. Shell Integration is required.", comment: "UI")),
            Tip(identifier: "Toolbelt.Command History",
                text: NSLocalizedString("If Shell Integration is installed, **Command History** shows a searchable list of recently run commands on the current host.", comment: "UI")),
            Tip(identifier: "Toolbelt.Notes",
                imageName: "NotesMenuTip",
                text: NSLocalizedString("**Notes** is a single, persistent notepad in your Toolbelt. It’s useful for keeping track of what you’re doing or composing messages.", comment: "UI")),
            Tip(identifier: "Toolbelt.Paste History",
                text: NSLocalizedString("**Paste History** shows text that you have copied and pasted in iTerm2. You can configure it to be saved long term.", comment: "UI")),
            Tip(identifier: "Toolbelt.Profiles",
                text: NSLocalizedString("Shows a list of your profiles so you can create new sessions easily.", comment: "UI")),
            Tip(identifier: "Toolbelt.Recent Directories",
                text: NSLocalizedString("Shows your most used directories, sorted by a combination of frequency and recency of use. Requires Shell Integration.", comment: "UI")),
            Tip(identifier: "Toolbelt.Snippets",
                imageName: "SnippetsTip",
                text: NSLocalizedString("Snippets are pieces of text that you save to reuse later. They’re great for frequently used commands, hard-to-remember directories, and much more.", comment: "UI")),
            Tip(identifier: "Zoom In on Selection",
                text: NSLocalizedString("Hides everything except the lines of selected text to remove distractions.", comment: "UI")),
            Tip(identifier: "Find Cursor",
                imageName: "FindCursorMenuTip",
                text: NSLocalizedString("Highlights the location of the cursor and unhides it if it is currently hidden.", comment: "UI")),
            Tip(identifier: "Show Annotations",
                imageName: "AnnotationsMenuTip",
                text: NSLocalizedString("Annotations are inline markup. When closed, they appear as a yellow underline; when open, they look like yellow stickies where you can write memos about content in the terminal window.", comment: "UI")),
            Tip(identifier: "Composer",
                imageName: "ComposerMenuTip",
                text: NSLocalizedString("The Composer is a window within the terminal where you can edit text using macOS-native controls. It does syntax highlighting, command and filename completion—even over SSH (provided you use SSH Integration). If AI features are enabled, you can also get AI-powered suggestions. You can even have multiple cursors! When you're ready, you can send the whole buffer or just a line at a time to your shell.", comment: "UI")),
            Tip(identifier: "Auto Composer",
                imageName: "AutoComposerMenuTip",
                text: NSLocalizedString("**Auto Composer** replaces your shell prompt with a macOS-native text field. It does syntax highlighting and command and filename completion. You can also enable AI-powered suggestions. Shell Integration is required.", comment: "UI")),
            Tip(identifier: "Open Quickly",
                imageName: "OpenQuicklyMenuTip",
                text: NSLocalizedString("**Open Quickly** provides quick access to many common actions. You can use it to find a session by typing its name, directory, hostname, or recent command. You can also use it to switch profiles or create a new window by typing the name of a profile. Restore an arrangement by entering its name. Press `/` to get tips for quick commands.", comment: "UI")),
            Tip(identifier: "Start Instant Replay",
                imageName: "InstantReplayMenuTip",
                text: NSLocalizedString("**Instant Replay** lets you review recent terminal history. It’s handy if something just disappeared from the screen and it isn’t in scrollback history.", comment: "UI")),
            Tip(identifier: "Run Coprocess…",
                imageName: "CoprocessMenuTip",
                text: NSLocalizedString("A **Coprocess** is a program that automates interactions in the terminal. Input to the terminal is redirected to stdin of the coprocess, and its output is sent back to the terminal as though the coprocess were typing.", comment: "UI")),
            Tip(identifier: "Stop Coprocess",
                imageName: "CoprocessMenuTip",
                text: NSLocalizedString("Stops the active coprocess. Input to the terminal is no longer redirected to the coprocess, and its output ceases.", comment: "UI")),
            Tip(identifier: "Triggers",
                imageName: "TriggersMenuTip",
                text: NSLocalizedString("**Triggers** are actions the terminal performs automatically when text matching a regular expression is received. For example, you can highlight text or display an alert.", comment: "UI")),
            Tip(identifier: "Terminal State.Literal Mode",
                text: NSLocalizedString("When enabled, control characters are displayed visually rather than being interpreted as usual.", comment: "UI")),
            Tip(identifier: "Terminal State.Report Modifiers with CSI u",
                text: NSLocalizedString("This mode is generally not recommended. **Disambiguate Escape** is a more modern approach.", comment: "UI")),
            Tip(identifier: "Bury Session",
                imageName: "BurySessionMenuTip",
                text: NSLocalizedString("Buried sessions are hidden in the **Buried Sessions** menu below and do not appear in any window. These are particularly useful for the session where you initiate tmux integration by running `tmux -CC`.", comment: "UI")),
            Tip(identifier: "Open Interactive Window",
                text: NSLocalizedString("The Python REPL opens a window running a special Python interpreter that lets you experiment with iTerm2’s Python API. You can use `await` at the top level of the interpreter.", comment: "UI")),
            Tip(identifier: "Manage Dependencies",
                text: NSLocalizedString("Opens a UI where you can add, update, or remove pip dependencies of a Python API script.", comment: "UI")),
            Tip(identifier: "Install Python Runtime",
                text: NSLocalizedString("iTerm2’s Python Runtime is a large binary package (hundreds of MBs) that enables the Python API by installing a pre-built Python environment that scripts can use.", comment: "UI")),
            Tip(identifier: "Import Script",
                text: NSLocalizedString("Use **Import** to install scripts others have shared with you. These scripts have the `.its` extension.", comment: "UI")),
            Tip(identifier: "Export Script",
                text: NSLocalizedString("If you want to share Python API scripts, you can export them to an `.its` file. If you have a code signing certificate and private key in your Keychain, you can also sign the `.its` file.", comment: "UI")),
            Tip(identifier: "Script Console",
                text: NSLocalizedString("View errors and low-level communication between Python API scripts and iTerm2 here.\n\nThe Inspector can be accessed from the Console. It allows you to browse variables in sessions, tabs, and windows.", comment: "UI")),
            Tip(identifier: "Arrangements",
                imageName: "ArrangementsMenuTip",
                text: NSLocalizedString("**Window Arrangements** are a saved record of one or more windows, their tabs, and split panes, including how each pane is configured. They do not include content. They’re a quick way to create a working environment with multiple sessions in various configurations.", comment: "UI")),
            Tip(identifier: "Password Manager",
                imageName: "PasswordManagerMenuTip",
                text: NSLocalizedString("The **Password Manager** helps you keep track of your passwords securely. By default, it stores them in the macOS Keychain, but it can also use 1Password or LastPass.", comment: "UI")),
            Tip(identifier: "AI Chats",
                imageName: "AIChatMenuTip",
                text: NSLocalizedString("**AI Chats** opens a chat window where you can interact with AI. It can optionally view and control the terminal if you grant it permission.", comment: "UI")),
            Tip(identifier: "Pin Hotkey Window",
                text: NSLocalizedString("A **pinned** Hotkey Window does not close automatically when it loses keyboard focus.", comment: "UI")),
            Tip(identifier: "GPU Renderer Availability",
                text: NSLocalizedString("Checks whether the GPU Renderer is currently being used in the active session. This is sometimes useful for debugging.", comment: "UI")),
            Tip(identifier: "Secure Keyboard Entry",
                text: NSLocalizedString("**Secure Keyboard Entry** prevents other programs from intercepting your keystrokes in the terminal. However, it also breaks some functionality: other programs cannot activate their windows while this is enabled. For example, the `open` command will still open an app, but it won’t be activated.", comment: "UI")),
            Tip(identifier: "Install Shell Integration",
                text: NSLocalizedString("**Shell Integration** consists of shell scripts that run when you log in. They inform iTerm2 of where your shell prompt is. This enables dozens of useful features such as command history, directory history, AI features, and more.", comment: "UI")),
            Tip(identifier: "Toggle Debug Logging",
                text: NSLocalizedString("Debug logs are saved in memory while this setting is enabled and written to `/tmp/debuglog.txt` when you turn it off. Memory use is capped at about 200MB; if the log grows past that, the oldest entries are discarded so the most recent activity is always kept.", comment: "UI")),
            Tip(identifier: "Broadcast Input.Broadcast Input to All Panes in All Tabs",
                text: NSLocalizedString("When enabled, anything you type in this window is sent to all sessions in this window.", comment: "UI")),
            Tip(identifier: "Broadcast Input.Broadcast Input to All Panes in Current Tab",
                text: NSLocalizedString("When enabled, anything you type in this tab is sent to all sessions in this tab.", comment: "UI")),
            Tip(identifier: "Broadcast Input.Toggle Broadcast Input to Current Session",
                text: NSLocalizedString("Adds or removes this session from the set of sessions in this window that have broadcast enabled. When you type in a session with broadcast enabled, the keystrokes are sent to all other sessions in the same window that have broadcast enabled.", comment: "UI")),
            Tip(identifier: "Broadcast Input.Show Background Pattern Indicator",
                imageName: "BroadcastStripesMenuTip",
                text: NSLocalizedString("When enabled, prominent red lines are drawn in the background to indicate that text you type is being broadcast to other sessions.", comment: "UI")),
            Tip(identifier: "Broadcast Input.Current Session is Broadcast Source",
                text: NSLocalizedString("When enabled, typing in this session is broadcast to other sessions in the same broadcast domain. Typing in other sessions sends input only to those sessions.", comment: "UI")),
            Tip(identifier: "Lock Size",
                text: NSLocalizedString("Locked windows resist being resized. This can be useful when macOS screws up your windows when connecting or disconnecting displays.", comment: "UI")),
            Tip(identifier: "Lock Layout",
                text: NSLocalizedString("When a window’s layout is locked, its tabs and panes can’t be added, closed, reordered, dragged, or moved to another window, so a stray click or drag can’t rearrange it. Resizing panes, opening new windows, and closing the window still work. This is an alternative to Lock Size; turning one on turns the other off.", comment: "UI")),
            Tip(identifier: "Notify on Status Change",
                text: NSLocalizedString("When enabled, the next time any session in this window changes its status (such as waiting, idle, or busy) an alert is shown and this setting turns itself back off. This is the same toggle as the bell button in the **Session Status** toolbelt tool, which must be open for this to be available.", comment: "UI")),
            Tip(identifier: "Toggle Buffer Input", text: NSLocalizedString("While Buffer Input is turned on, keyboard input is stored in a buffer. It will be sent when Buffer Input is turned off. You can also configure a trigger to change the Buffer Input setting.", comment: "UI")),
            Tip(identifier: "Toolbelt.Session Status",
                imageName: "TabStatus",
                text: NSLocalizedString("The **Session Status** tool shows the status of sessions across all tabs. Statuses can be set by the **Set Tab Status** trigger or by programs using a control sequence. Each entry shows the session name, a colored indicator dot, status text, and a keyboard shortcut to jump to that session.", comment: "UI")),
        ]
        var index = [String: NSMenuItem]()
        func makeIndex(menu: NSMenu) {
            for item in menu.items {
                if let identifier = item.identifier?.rawValue, !identifier.isEmpty {
                    index[identifier] = item
                }
                if let sub = item.submenu {
                    makeIndex(menu: sub)
                }
            }
        }
        makeIndex(menu: mainMenu)
        let controller = MenuItemTipController.instance
        for tip in tips {
            if let item = index[tip.identifier] {
                controller.registerTip(forMenuItem: item,
                                       image: tip.imageName.compactMap { NSImage.it_imageNamed($0, for: Self.self) },
                                       attributedString: NSAttributedString.attributedString(markdown: tip.text,
                                                                                             font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
                                                                                             paragraphStyle: NSParagraphStyle.default)!)
            } else {
                #if(DEBUG)
                it_fatalError("Index missing \(tip.identifier)")
                #endif
            }
        }
    }
}

@objc
extension iTermApplicationDelegate {
    @IBAction func restoreArchive(_ sender: Any?) {
        ArchivesMenuBuilder.shared?.restoreArchive(nil)
    }
}

@objc
extension iTermApplicationDelegate {
    @IBAction func revealCockpit(_ sender: Any?) {
        CockpitWindowController.shared.showAndFocusSearch()
    }
}
