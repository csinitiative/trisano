/* See license.txt for terms of usage */

FBL.ns(function() { with (FBL) {

// ************************************************************************************************
// Constants

// ************************************************************************************************
// Implementation

/**
 * @module Command Line availability in other panels.
 */
Firebug.CommandLine.Popup = extend(Firebug.Module,
{
    lastFocused : null,

    initializeUI: function()
    {
        Firebug.Module.initializeUI.apply(this, arguments);

        this.setPopupBrowserStyle(Firebug.chrome);

        this.onKeyPress = bind(this.onKeyPress, this);

        this.attachListeners();
    },

    shutdown: function()
    {
        Firebug.chrome.$("fbContentBox").removeEventListener("keypress", this.onKeyPress, false);
    },

    reattachContext: function(browser, context)
    {
        this.setPopupBrowserStyle(Firebug.chrome);
        this.attachListeners();
    },

    showPanel: function(browser, panel)
    {
        if (FBTrace.DBG_COMMANDLINE)
            FBTrace.sysout("commandLine.Popup.showPanel; " + (panel?panel.name:"null panel"));

        var chrome = Firebug.chrome;
        var visible = this.isVisible();
        var isConsole = (panel && panel.name == "console");
        var largeCmd = Firebug.largeCommandLine;

        // Disable the console popup button (Firebug toolbar) if the Console panel
        // is disabled or selected.
        var consolePanelType = Firebug.getPanelType("console");
        var disabled = consolePanelType.prototype.isEnabled() ? "false" : "true";
        if (isConsole || !panel)
            disabled = "true";

        chrome.$("fbCommandPopupButton").setAttribute("disabled", disabled);

        if ((largeCmd && isConsole) || !panel)
        {
            collapse(chrome.$("fbPanelSplitter"), panel ? false : true);
            collapse(chrome.$("fbSidePanelDeck"), panel ? false : true);
            collapse(chrome.$("fbCommandBox"), true);
            chrome.$("fbSidePanelDeck").selectedPanel = chrome.$("fbLargeCommandBox");
        }

        // The console can't be multiline on other panels so, hide the toggle-to-multiline
        // button (displayed at the end of the one line command line)
        collapse(chrome.$("fbCommandToggleSmall"), !isConsole);

        // Update visibility of the console-popup (hidden if the Console panel is selected).
        this.updateVisibility(visible && !isConsole && panel && disabled != "true");

        // Make sure the console panel is attached to the proper document
        // (the one used by all panels, or the one used by console popup and available
        // for all the panels).
        if (panel)
            this.reattach(panel.context);

        // If the the console panel is opened on another panel, simulate show event for it.
        if (panel && !isConsole && visible)
            this.showPopupPanel(panel.context);
    },

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    setPopupBrowserStyle: function(chrome)
    {
        // Set additional style so we can make the panelNode-console node
        // always visible regardless of the currently selected panel.
        var doc = chrome.$("fbCommandPopupBrowser").contentDocument;
        var body = getBody(doc);
        setClass(body, "commandPopup");
    },

    attachListeners: function()
    {
        // Register event listeners.
        Firebug.chrome.$("fbContentBox").addEventListener("keypress", this.onKeyPress, false);
    },

    toggle: function(context)
    {
        var panel = Firebug.chrome.getSelectedPanel();
        if (panel && panel.name == "console")
            return;

        if (FBTrace.DBG_COMMANDLINE)
            FBTrace.sysout("commandLine.Popup.toggle;");

        var newState = !this.isVisible();
        Firebug.chrome.setGlobalAttribute("cmd_toggleCommandPopup", "checked", newState);
        this.updateVisibility(newState);

        this.reattach(context);
        this.showPopupPanel(context);
    },

    showPopupPanel: function(context)
    {
        // If the the console panel is opened on another panel, simulate show event for it.
        if (this.isVisible())
        {
            var panel = context.getPanel("console", true);
            if (panel)
            {
                var state = Firebug.getPanelState(panel);
                panel.showPanel(state);
            }
        }
    },

    updateVisibility: function(visible)
    {
        var chrome = Firebug.chrome;
        var popup = chrome.$("fbCommandPopup");
        var splitter = chrome.$("fbCommandPopupSplitter")
        var cmdbox = chrome.$("fbCommandBox");
        var toggle = chrome.$("fbCommandToggleSmall");

        // If all the visual parts are already visible then bail out.
        if (visible && !isCollapsed(popup) && !isCollapsed(splitter) &&
            !isCollapsed(cmdbox) && !isCollapsed(toggle))
            return;

        collapse(popup, !visible);
        collapse(splitter, !visible);
        collapse(cmdbox, !visible);

        // The command line can't be multiline in other panels.
        collapse(toggle, visible);

        var commandLineSmall = Firebug.CommandLine.getCommandLineLarge();
        var commandLineLarge = Firebug.CommandLine.getCommandLineSmall();

        // Focus the command line if it has been just displayed.
        if (visible)
        {
            this.lastFocused = document.commandDispatcher.focusedElement;
            commandLineSmall.focus();
        }
        else if (this.lastFocused && isVisible(this.lastFocused) &&
            typeof this.lastFocused.focus == "function")
        {
            this.lastFocused.focus();
            this.lastFocused = null;
        }

        if (Firebug.largeCommandLine)
        {
            if (visible)
                commandLineSmall.value = stripNewLines(commandLineLarge.value);
            else
                commandLineLarge.value = cleanIndentation(commandLineSmall.value);
        }
    },

    isVisible: function()
    {
        var checked = Firebug.chrome.getGlobalAttribute("cmd_toggleCommandPopup", "checked");
        return (checked == "true") ? true : false;
    },

    reattach: function(context)
    {
        var consolePanelType = Firebug.getPanelType("console");
        var doc = Firebug.chrome.getPanelDocument(consolePanelType);

        // Console doesn't have to be available (e.g. disabled)
        var panel = context.getPanel("console", true);
        if (panel)
            panel.reattach(doc);
    },

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    // Event Listeners

    onKeyPress: function(event)
    {
        if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey)
            return false;

        // ESC
        var target = event.target;
        // prevent conflict with inline editors being closed
        if (target && event.keyCode == 27 && !hasClass(event.target, "textEditorInner"))
            this.toggle(Firebug.currentContext);
    }
});

// ************************************************************************************************
// Registration

Firebug.registerModule(Firebug.CommandLine.Popup);

// ************************************************************************************************
return Firebug.CommandLine.Popup;
}});
