/* See license.txt for terms of usage */

FBL.ns(function() { with (FBL) {

// ************************************************************************************************
// Constants

const Cc = Components.classes;
const Ci = Components.interfaces;

const commandPrefix = ">>>";

const reOpenBracket = /[\[\(\{]/;
const reCloseBracket = /[\]\)\}]/;
const reCmdSource = /^with\(_FirebugCommandLine\){(.*)};$/;

// ************************************************************************************************
// Globals

// ************************************************************************************************

Firebug.CommandLine = extend(Firebug.Module,
{
    dispatchName: "commandLine",

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    // targetWindow was needed by evaluateInSandbox, let's leave it for a while in case
    // we rethink this yet again

    initializeCommandLineIfNeeded: function (context, win)
    {
        if (!context || !win)
            return;

      // The command-line requires that the console has been initialized first,
      // so make sure that's so.  This call should have no effect if the console
      // is already initialized.
      var consoleIsReady = Firebug.Console.isReadyElsePreparing(context, win);

      // Make sure the command-line is initialized.  This call should have no
      // effect if the command-line is already initialized.
      var commandLineIsReady = Firebug.CommandLine.isReadyElsePreparing(context, win);

      if (FBTrace.DBG_COMMANDLINE)
          FBTrace.sysout("commandLine.initializeCommandLineIfNeeded console ready: " +
            consoleIsReady + " commandLine ready: " + commandLineIsReady);
    },

    // returns user-level wrapped object I guess.
    evaluate: function(expr, context, thisValue, targetWindow, successConsoleFunction, exceptionFunction)
    {
        if (!context)
            return;

        try
        {
            var result = null;
            var debuggerState = Firebug.Debugger.beginInternalOperation();

            if (this.isSandbox(context))
                result = this.evaluateInSandbox(expr, context, thisValue, targetWindow, successConsoleFunction, exceptionFunction);
            else if (Firebug.Debugger.hasValidStack(context))
                result = this.evaluateInDebugFrame(expr, context, thisValue, targetWindow,  successConsoleFunction, exceptionFunction);
            else
                result = this.evaluateByEventPassing(expr, context, thisValue, targetWindow, successConsoleFunction, exceptionFunction);

            context.invalidatePanels('dom', 'html');
        }
        catch (exc)  // XXX jjb, I don't expect this to be taken, the try here is for the finally
        {
            if (FBTrace.DBG_ERRORS || FBTrace.DBG_COMMANDLINE)
                FBTrace.sysout("commandLine.evaluate with context.stopped:" + context.stopped +
                    " EXCEPTION " + exc, exc);
        }
        finally
        {
            Firebug.Debugger.endInternalOperation(debuggerState);
        }

        return result;
    },

    evaluateByEventPassing: function(expr, context, thisValue, targetWindow, successConsoleFunction, exceptionFunction)
    {
        var win = targetWindow ? targetWindow : (context.baseWindow ? context.baseWindow : context.window);

        if (!win)
        {
            if (FBTrace.DBG_ERRORS || FBTrace.DBG_COMMANDLINE)
                FBTrace.sysout("commandLine.evaluateByEventPassing: no targetWindow!\n");
            return;
        }

        // We're going to use some command-line facilities, but it may not have initialized yet.
        this.initializeCommandLineIfNeeded(context, win);

        // Make sure the command line script is attached.
        var attached = win.document.getUserData("firebug-CommandLineAttached");
        if (!attached)
        {
            FBTrace.sysout("commandLine: document does not have command line attached " +
                "its too early for command line "+safeGetWindowLocation(win), document);

            if (isXMLPrettyPrint(context, win))
            {
                var msg = $STR("commandline.disabledForXMLDocs");
                var row = Firebug.Console.logFormatted([msg], context, "warn", true);
                var objectBox = row.querySelector(".objectBox");

                // Log a message with a clickable link that can be used to enable
                // the command line - but the page will switch into HTML. The listener
                // passed into the function is called when the user clicks the link.
                FirebugReps.Description.render(msg, objectBox, bind(function()
                {
                    // Reset the flag that protect script injection into the page.
                    context.isXMLPrettyPrint = false;

                    // Now inject the command line.
                    Firebug.CommandLine.initializeCommandLineIfNeeded(context, win);
                }, this));
            }
            else
            {
                Firebug.Console.logFormatted(["Firebug cannot find firebug-CommandLineAttached " +
                    "document.getUserData , its too early for command line",
                     win], context, "error", true);
            }
            return;
        }

        var event = document.createEvent("Events");
        event.initEvent("firebugCommandLine", true, false);
        win.document.setUserData("firebug-methodName", "evaluate", null);

        expr = expr.toString();
        expr = "with(_FirebugCommandLine){" + expr + "\n};";
        win.document.setUserData("firebug-expr", expr, null);

        var consoleHandler = Firebug.Console.injector.getConsoleHandler(context, win);

        if (!consoleHandler)
        {
            FBTrace.sysout("commandLine evaluateByEventPassing no consoleHandler "+safeGetWindowLocation(win));
            return;
        }

        if (successConsoleFunction)
        {
            consoleHandler.setEvaluatedCallback( function useConsoleFunction(result)
            {
                if (result === "_firebugIgnore")
                    return;
                successConsoleFunction(result, context);  // result will be pass thru this function
            });
        }

        if (exceptionFunction)
        {
            consoleHandler.setEvaluateErrorCallback(function useExceptionFunction(result)
            {
                exceptionFunction(result, context, "errorMessage");
            });
        }
        else
        {
            consoleHandler.setEvaluateErrorCallback(function useErrorFunction(result)
            {
                if (result)
                {
                    var m = reCmdSource.exec(result.source);
                    if (m && m.length > 0)
                        result.source = m[1];
                }

                Firebug.Console.logFormatted([result], context, "error", true);
            });
        }

        if (FBTrace.DBG_COMMANDLINE)
            FBTrace.sysout("commandLine.evaluateByEventPassing \'"+expr+"\' using consoleHandler:", consoleHandler);
        try
        {
            win.document.dispatchEvent(event);
        }
        catch(exc)
        {
            if (FBTrace.DBG_COMMANDLINE || FBTrace.DBG_ERRORS)
                FBTrace.sysout("commandLine.evaluateByEventPassing dispatchEvent FAILS "+exc, {exc:exc, event:event});
        }

        if (FBTrace.DBG_COMMANDLINE)
            FBTrace.sysout("commandLine.evaluateByEventPassing return after firebugCommandLine event:", event);
    },

    evaluateInDebugFrame: function(expr, context, thisValue, targetWindow,  successConsoleFunction, exceptionFunction)
    {
        var result = null;

        // targetWindow may be frame in HTML
        var win = targetWindow ? targetWindow : (context.baseWindow ? context.baseWindow : context.window);

        if (!context.commandLineAPI)
            context.commandLineAPI = new FirebugCommandLineAPI(context);

        var htmlPanel = context.getPanel("html", true);
        var scope = {
            api       : context.commandLineAPI,
            vars      : htmlPanel?htmlPanel.getInspectorVars():null,
            thisValue : thisValue
        };

        try
        {
            result = Firebug.Debugger.evaluate(expr, context, scope);
            successConsoleFunction(result, context);  // result will be pass thru this function
        }
        catch (e)
        {
            exceptionFunction(e, context);
        }
        return result;
    },

    evaluateByPostMessage: function(expr, context, thisValue, targetWindow, successConsoleFunction, exceptionFunction)
    {
        // targetWindow may be frame in HTML
        var win = targetWindow ? targetWindow : (context.baseWindow ? context.baseWindow : context.window);
        if (!win)
        {
            if (FBTrace.DBG_ERRORS || FBTrace.DBG_COMMANDLINE)
                FBTrace.sysout("commandLine.evaluateByPostMessage: no targetWindow!\n");
            return;
        }

        // We're going to use some command-line facilities, but it may not have initialized yet.
        this.initializeCommandLineIfNeeded(context, win);

        expr = expr.toString();
        expr = "with(_FirebugCommandLine){" + expr + "\n};";

        var consoleHandler = Firebug.Console.injector.getConsoleHandler(context, win);

        if (!consoleHandler)
        {
            FBTrace.sysout("commandLine evaluateByPostMessage no consoleHandler "+safeGetWindowLocation(win));
            return;
        }

        if (successConsoleFunction)
        {
            consoleHandler.setEvaluatedCallback( function useConsoleFunction(result)
            {
                if (result === "_firebugIgnore")
                    return;
                successConsoleFunction(result, context);  // result will be pass thru this function
            });
        }

        if (exceptionFunction)
        {
            consoleHandler.evaluateError = function useExceptionFunction(result)
            {
                exceptionFunction(result, context, "errorMessage");
            }
        }
        else
        {
            consoleHandler.evaluateError = function useErrorFunction(result)
            {
                if (result)
                {
                    var m = reCmdSource.exec(result.source);
                    if (m && m.length > 0)
                        result.source = m[1];
                }

                Firebug.Console.logFormatted([result], context, "error", true);
            }
        }

        return win.postMessage(expr, "*");
    },

    evaluateInWebPage: function(expr, context, targetWindow)
    {
        var win = targetWindow || context.window;
        var element = addScript(win.document, "_firebugInWebPage", expr);
        if (!element)
            return;

        setTimeout(function delayRemoveScriptTag()
        {
            if (element.parentNode)
                element.parentNode.removeChild(element);  // we don't need the script element, result is in DOM object
        });

        return "true";
    },

    // isSandbox(context) true, => context.global is a Sandbox
    evaluateInSandbox: function(expr, context, thisValue, targetWindow, successConsoleFunction, exceptionFunction)
    {
        var result,
            scriptToEval = expr;

        try
        {
            result = Components.utils.evalInSandbox(scriptToEval, context.global);
            if (FBTrace.DBG_COMMANDLINE)
                FBTrace.sysout("commandLine.evaluateInSandbox success for sandbox ", scriptToEval);
            successConsoleFunction(result, context);  // result will be pass thru this function
        }
        catch (e)
        {
            if (FBTrace.DBG_ERRORS || FBTrace.DBG_COMMANDLINE)
                FBTrace.sysout("commandLine.evaluateInSandbox FAILED in "+context.getName()+
                    " because "+e, e);

            exceptionFunction(e, context);

            result = new FBL.ErrorMessage("commandLine.evaluateInSandbox FAILED: " + e,
                FBL.getDataURLForContent(scriptToEval, "FirebugCommandLineEvaluate"),
                e.lineNumber, 0, "js", context, null);
        }
        return result;
    },

    isSandbox: function (context)
    {
        return (context.global && context.global+"" === "[object Sandbox]");
    },

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    acceptCompletionOrReturnIt: function(context)
    {
        var commandLine = this.getCommandLine(context);
        var completionBox = this.getCompletionBox();
        if (completionBox.value.length === 0 || commandLine.value.length === completionBox.value.length) // we have nothing to complete
            return this.autoCompleter.getVerifiedText(commandLine);

        this.autoCompleter.acceptCompletionInTextBox(commandLine, completionBox);
        return ""; // next time we will return text
    },

    enter: function(context, command)
    {
        var expr = command ? command : this.acceptCompletionOrReturnIt(context);
        if (expr == "")
            return;

        var mozJSEnabled = Firebug.getPref("javascript", "enabled");
        if (mozJSEnabled)
        {
            if (!Firebug.largeCommandLine || context.panelName != "console")
            {
                this.clear(context);
                Firebug.Console.log(commandPrefix + " " + expr, context, "command", FirebugReps.Text);
            }
            else
            {
                var shortExpr = cropString(stripNewLines(expr), 100);
                Firebug.Console.log(commandPrefix + " " + shortExpr, context, "command", FirebugReps.Text);
            }

            this.commandHistory.appendToHistory(expr);

            var noscript = getNoScript();
            if (noscript)
            {
                var noScriptURI = noscript.getSite(Firebug.chrome.getCurrentURI().spec);
                if (noScriptURI)
                    noScriptURI = (noscript.jsEnabled || noscript.isJSEnabled(noScriptURI)) ? null : noScriptURI;
            }

            if (noscript && noScriptURI)
                noscript.setJSEnabled(noScriptURI, true);

            var goodOrBad = FBL.bind(Firebug.Console.log, Firebug.Console);
            this.evaluate(expr, context, null, null, goodOrBad, goodOrBad);

            if (noscript && noScriptURI)
                noscript.setJSEnabled(noScriptURI, false);

            this.autoCompleter.reset();
        }
        else
        {
            Firebug.Console.log($STR("console.JSDisabledInFirefoxPrefs"), context, "info");
        }
    },

    enterMenu: function(context)
    {
        var expr = this.acceptCompletionOrReturnIt(context);
        if (expr == "")
            return;

        this.commandHistory.appendToHistory(expr, true);

        this.evaluate(expr, context, null, null, function(result, context)
        {
            if (typeof(result) != "undefined")
            {
                Firebug.chrome.contextMenuObject = result;

                var popup = Firebug.chrome.$("fbContextMenu");
                var commandLine = this.getCommandLine(context);
                popup.showPopup(commandLine, -1, -1, "popup", "bottomleft", "topleft");
            }
        });
    },

    enterInspect: function(context)
    {
        var expr = this.acceptCompletionOrReturnIt(context);
        if (expr == "")
            return;

        this.clear(context);
        this.commandHistory.appendToHistory(expr);

        this.evaluate(expr, context, null, null, function(result, context)
        {
            if (typeof(result) != undefined)
                Firebug.chrome.select(result);
        });
    },

    reenter: function(context)
    {
        var command = this.commandHistory.commands[this.commandHistory.commandInsertPointer];
        if (command)
            this.enter(context, command);
    },

    copyBookmarklet: function(context)
    {
        var commandLine = this.getCommandLine(context);
        var expr = "javascript: " + stripNewLines(this.autoCompleter.getVerifiedText(commandLine));
        copyToClipboard(expr);
    },

    focus: function(context)
    {
        if (Firebug.isDetached())
            Firebug.chrome.focus();
        else
            Firebug.toggleBar(true);

        var commandLine = this.getCommandLine(context);

        if (!context.panelName)
        {
            Firebug.chrome.selectPanel("console");
        }
        else if (context.panelName != "console")
        {
            this.Popup.toggle(Firebug.currentContext);
            setTimeout(function() { commandLine.select(); });
        }
        else
        {
            // We are already on the console, if the command line has also
            // the focus, toggle back. But only if the UI has been already
            // opened.
            if (commandLine.getAttribute("focused") != "true")
                setTimeout(function() { commandLine.select(); });
        }
    },

    clear: function(context)
    {
        var commandLine = this.getCommandLine(context);
        var completionBox = this.getCompletionBox();

        completionBox.value = "";

        // Return false if the command line is already empty.
        if (!commandLine.value)
            return false;

        commandLine.value = context.commandLineText = "";
        this.autoCompleter.reset();
        this.autoCompleter.hide(this.getCompletionBox());

        return true;
    },

    cancel: function(context)
    {
        var commandLine = this.getCommandLine(context);
        if (this.autoCompleter.revert(commandLine))
            return;

        return this.clear(context);
    },

    update: function(context)
    {
        var commandLine = this.getCommandLine(context);
        context.commandLineText = this.autoCompleter.getVerifiedText(commandLine);
    },

    complete: function(context, reverse)
    {
        var commandLine = this.getCommandLine(context);
        var completionBox = this.getCompletionBox();
        this.autoCompleter.complete(context, commandLine, completionBox, true, reverse);
        context.commandLineText = this.autoCompleter.getVerifiedText(commandLine);
        this.autoCompleter.reset();
    },

    setMultiLine: function(multiLine, chrome, saveMultiLine)
    {
        if (Firebug.currentContext && Firebug.currentContext.panelName != "console")
            return;

        collapse(chrome.$("fbCommandBox"), multiLine);
        collapse(chrome.$("fbPanelSplitter"), !multiLine);
        collapse(chrome.$("fbSidePanelDeck"), !multiLine);

        if (multiLine)
            chrome.$("fbSidePanelDeck").selectedPanel = chrome.$("fbLargeCommandBox");

        var commandLineSmall = this.getCommandLineSmall();
        var commandLineLarge = this.getCommandLineLarge();

        if (saveMultiLine)  // we are just closing the view
        {
            commandLineSmall.value = commandLineLarge.value;
            return;
        }

        if (Firebug.currentContext)
        {
            Firebug.currentContext.commandLineText = Firebug.currentContext.commandLineText || "";

            if (multiLine)
                commandLineLarge.value = cleanIndentation(Firebug.currentContext.commandLineText);
            else
                commandLineSmall.value = stripNewLines(Firebug.currentContext.commandLineText);
        }
        // else we may be hiding a panel while turning Firebug off
    },

    toggleMultiLine: function(forceLarge)
    {
        var large = forceLarge || !Firebug.largeCommandLine;
        if (large != Firebug.largeCommandLine)
            Firebug.setPref(Firebug.prefDomain, "largeCommandLine", large);
    },

    checkOverflow: function(context)
    {
        if (!context)
            return;

        var commandLine = this.getCommandLine(context);
        if (commandLine.value.indexOf("\n") >= 0)
        {
            setTimeout(bindFixed(function()
            {
                Firebug.setPref(Firebug.prefDomain, "largeCommandLine", true);
            }, this));
        }
    },

    onCommandLineOverflow: function(event)
    {
        this.checkOverflow(Firebug.currentContext);
    },

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    setCursor: function(commandLine, position)
    {
        //commandLine.inputField.setSelectionRange(command.length, command.length);  // textbox version, https://developer.mozilla.org/en/XUL/Property/inputField
        commandLine.setSelectionRange(position, position);
    },

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    // extends Module

    initialize: function()
    {
        Firebug.Module.initialize.apply(this, arguments);

        this.setAutoCompleter();
        this.commandHistory = new Firebug.CommandLine.CommandHistory();

        if (Firebug.largeCommandLine)
            this.setMultiLine(true, Firebug.chrome);
    },

    setAutoCompleter: function()
    {
        var showCompletionPopup = Firebug.getPref(Firebug.prefDomain, "commandLineShowCompleterPopup");
        this.autoCompleter = new Firebug.AutoCompleter(getExpressionOffset, getDot,
                bind(autoCompleteEval, this), false, true, true, true, showCompletionPopup, isValidProperty);
    },

    initializeUI: function()
    {
        this.onCommandLineFocus = bind(this.onCommandLineFocus, true);
        this.onCommandLineInput = bind(this.onCommandLineInput, this);
        this.onCommandLineBlur = bind(this.onCommandLineBlur, this);
        this.onCommandLineKeyUp = bind(this.onCommandLineKeyUp, this);
        this.onCommandLineKeyDown = bind(this.onCommandLineKeyDown, this);
        this.onCommandLineKeyPress = bind(this.onCommandLineKeyPress, this);
        this.onCommandLineOverflow = bind(this.onCommandLineOverflow, this);
        this.attachListeners();
    },

    reattachContext: function(browser, context)
    {
        this.attachListeners();

        // Recreate auto-completer so, the correct popup panel (fbCommandLineCompletionList)
        // is used (the one in detached window or the one in the browser.xul)
        this.setAutoCompleter();
    },

    attachListeners: function()
    {
        var commandLineSmall = this.getCommandLineSmall(),
            commandLineLarge = this.getCommandLineLarge();

        commandLineLarge.addEventListener('focus', this.onCommandLineFocus, true);
        commandLineSmall.addEventListener('focus', this.onCommandLineFocus, true);
        commandLineSmall.addEventListener('input', this.onCommandLineInput, true);
        commandLineSmall.addEventListener('overflow', this.onCommandLineOverflow, true);
        commandLineSmall.addEventListener('keyup', this.onCommandLineKeyUp, true);
        commandLineSmall.addEventListener('keydown', this.onCommandLineKeyDown, true);
        commandLineSmall.addEventListener('keypress', this.onCommandLineKeyPress, true);
        commandLineSmall.addEventListener('blur', this.onCommandLineBlur, true);

        Firebug.Console.addListener(this);  // to get onConsoleInjection
    },

    shutdown: function()
    {
        var commandLineSmall = this.getCommandLineSmall(),
            commandLineLarge = this.getCommandLineLarge();

        commandLineLarge.removeEventListener('focus', this.onCommandLineFocus, true);
        commandLineSmall.removeEventListener('focus', this.onCommandLineFocus, true);
        commandLineSmall.removeEventListener('input', this.onCommandLineInput, true);
        commandLineSmall.removeEventListener('overflow', this.onCommandLineOverflow, true);
        commandLineSmall.removeEventListener('keydown', this.onCommandLineKeyDown, true);
        commandLineSmall.removeEventListener('keypress', this.onCommandLineKeyPress, true);
        commandLineSmall.removeEventListener('blur', this.onCommandLineBlur, true);
    },

    destroyContext: function(context, persistedState)
    {
        var panelState = getPersistedState(this, "console");
        panelState.commandLineText = context.commandLineText

        this.autoCompleter.clear(this.getCompletionBox());
        persistObjects(this, panelState);
        // more of our work is done in the Console
    },

    showPanel: function(browser, panel)
    {
        var chrome = Firebug.chrome;
        var panelState = getPersistedState(this, "console");
        var value = panel && panel.context.commandLineText ? panel.context.commandLineText : panelState.commandLineText;

        if (!Firebug.currentContext)
        {
            if (FBTrace.DBG_ERRORS)
                FBTrace.sysout("commandLine.showPanel; ERROR NO CONTEXT");
            return;
        }

        var commandLine = this.getCommandLine(browser);
        Firebug.currentContext.commandLineText = value ? value : "";
        commandLine.value = Firebug.currentContext.commandLineText;

        this.autoCompleter.hide(this.getCompletionBox());
    },

    updateOption: function(name, value)
    {
        if (name == "largeCommandLine")
            this.setMultiLine(value, Firebug.chrome);
        else if (name == "commandLineShowCompleterPopup")
            this.setAutoCompleter();
    },

    // called by users of command line, currently:
    // 1) Console on focus command line, 2) Watch onfocus, and 3) debugger loadedContext if watches exist
    isReadyElsePreparing: function(context, win)
    {
        if (FBTrace.DBG_COMMANDLINE)
            FBTrace.sysout("commandLine.isReadyElsePreparing ", context);

        if (this.isSandbox(context))
            return;

        if (isXMLPrettyPrint(context, win))
            return false;

        if (win)
        {
            Firebug.CommandLine.injector.attachCommandLine(context, win);
        }
        else
        {
            Firebug.CommandLine.injector.attachCommandLine(context, context.window);
            for (var i = 0; i < context.windows.length; i++)
                Firebug.CommandLine.injector.attachCommandLine(context, context.windows[i]);
        }

        if (!context.window.wrappedJSObject)  // we need to test for the wrappedJSObject because _FirebugCommandLine is evaluated into the page
        {
            FBTrace.sysout("context.window with no wrappedJSObject!", context.window);
            return false;
        }

        // the attach is asynchronous, we can report when it is complete:
        return context.window.wrappedJSObject._FirebugCommandLine;
    },

    onCommandLineKeyUp: function(event)
    {
        var commandLine = this.getCommandLine(Firebug.currentContext);
        var completionBox = this.getCompletionBox();

        //this.autoCompleter.handledKeyUp(event, Firebug.currentContext, commandLine, completionBox)
    },

    onCommandLineKeyDown: function(event)
    {
        if (event.keyCode === KeyEvent.DOM_VK_H && (event.ctrlKey || event.metaKey))
        {
            event.preventDefault();
            this.commandHistory.show($("fbCommandLineHistoryButton"));
            return true;
        }

        // Parts of the code moved into key-press handler due to bug 613752
    },

    onCommandLineKeyPress: function(event)
    {
        var commandLine = this.getCommandLine(Firebug.currentContext);
        var completionBox = this.getCompletionBox();

        if (!this.autoCompleter.handledKeyDown(event, Firebug.currentContext, commandLine, completionBox))
        {
            this.handledKeyDown(event);  // independent of completer
        }
    },

    handledKeyDown: function(event)
    {
        if (event.keyCode === 13 || event.keyCode === 14)  // RETURN , ENTER
        {
            event.preventDefault();

            if (!event.metaKey && !event.shiftKey)
            {
                Firebug.CommandLine.enter(Firebug.currentContext);
                handled = true;
            }
            else if (event.metaKey && !event.shiftKey)
            {
                Firebug.CommandLine.enterMenu(Firebug.currentContext);
                handled = true;
            }
            else if(event.shiftKey && !event.metaKey)
            {
                Firebug.CommandLine.enterInspect(Firebug.currentContext);
                handled = true;
            }

            if (handled)
            {
                this.commandHistory.hide();
                return true;
            }
        }
        else if (event.keyCode === 38) // Up arrow
        {
            event.preventDefault();
            this.commandHistory.cycleCommands(Firebug.currentContext, -1);
            return true;
        }
        else if (event.keyCode === 40) // Down arrow
        {
            event.preventDefault();
            this.commandHistory.cycleCommands(Firebug.currentContext, 1);
            return true;
        }
        else if (event.keyCode === 27) // Esc
        {
            event.preventDefault();
            if (Firebug.CommandLine.cancel(Firebug.currentContext))
                FBL.cancelEvent(event);
            this.commandHistory.hide();
            return true;
        }
        return false;
    },

    onCommandLineInput: function(event)
    {
        var commandLine = this.getCommandLine(Firebug.currentContext);
        var completionBox = this.getCompletionBox();

        if (!this.autoCompleter.getVerifiedText(commandLine)) // don't complete on empty command line
        {
            this.autoCompleter.reset();
            this.autoCompleter.hide(this.getCompletionBox());
            return;
        }

        if (!this.commandHistory.isShown())
            this.autoCompleter.complete(Firebug.currentContext, commandLine, completionBox, true, false);
        Firebug.currentContext.commandLineText = this.autoCompleter.getVerifiedText(commandLine);
    },

    onCommandLineBlur: function(event)
    {
        if (this.autoCompleter.linuxFocusHack)
            return;

        this.autoCompleter.clear(this.getCompletionBox());
    },

    onCommandLineFocus: function(event)
    {
        // xxxHonza: what about iframes?
        var context = Firebug.currentContext;
        if (context && context.window.document.readyState != "complete")
        {
            // If the readyState is not "complete" the console should not be attached.
            // The logic should wait till the document is fully loaded.
            // For example by overriding document.onreadystatechange
            // https://developer.mozilla.org/en/DOM/document.onreadystatechange
            if (FBTrace.DBG_ERRORS)
                FBTrace.sysout("onCommandLineFocus; Fired too soon, document not yet loaded: " +
                    "(let Honza know if you see this) " + event.target.ownerDocument.readyState);
        }

        if (this.autoCompleter && this.autoCompleter.linuxFocusHack)
            return;

        if (!Firebug.CommandLine.attachConsoleOnFocus())  // then there is no currentContext.
            return;

        if (!Firebug.migrations.commandLineTab)
        {
            var textBox = Firebug.chrome.$('fbCommandLine');
            textBox.value = "";
            textBox.select();
            Firebug.migrations.commandLineTab = true;
        }

        if (!Firebug.CommandLine.isAttached(Firebug.currentContext))
        {
            return Firebug.CommandLine.isReadyElsePreparing(Firebug.currentContext);
        }
        else
        {
            if (FBTrace.DBG_COMMANDLINE)
            {
                try
                {
                    var cmdLine = Firebug.CommandLine.isAttached(Firebug.currentContext);
                    FBTrace.sysout("commandLine.onCommandLineFocus, attachCommandLine "+cmdLine, cmdLine);
                }
                catch (e)
                {
                    FBTrace.sysout("commandLine.onCommandLineFocus, did NOT attachCommandLine ", e);
                }
            }
            return true; // is attached.
        }
    },

    isAttached: function(context)
    {
        // _FirebugCommandLine is evaluated into the page
        return ( context && context.window && context.window.wrappedJSObject ) ?
            context.window.wrappedJSObject._FirebugCommandLine : false;
    },

    attachConsoleOnFocus: function()
    {
        if (!Firebug.currentContext)
        {
            if (FBTrace.DBG_ERRORS || FBTrace.DBG_COMMANDLINE)
                FBTrace.sysout("commandLine.attachConsoleOnFocus no Firebug.currentContext");
            return false;
        }

        if (FBTrace.DBG_COMMANDLINE)
            FBTrace.sysout("commandLine.attachConsoleOnFocus: Firebug.currentContext is "+Firebug.currentContext.getName() +
                " in window "+window.location);

        // User has decided to use the command line, but the web page may not have the console
        // if the page has no javascript
        if (Firebug.Console.isReadyElsePreparing(Firebug.currentContext))
        {
            // the page had _firebug so we know that consoleInjected.js compiled and ran.
            if (FBTrace.DBG_COMMANDLINE)
            {
                if (Firebug.currentContext)
                    FBTrace.sysout("commandLine.attachConsoleOnFocus: "+Firebug.currentContext.getName());
                else
                    FBTrace.sysout("commandLine.attachConsoleOnFocus: No Firebug.currentContext\n");
            }
        }
        else
        {
            Firebug.Console.injector.forceConsoleCompilationInPage(Firebug.currentContext, Firebug.currentContext.window);

            if (FBTrace.DBG_COMMANDLINE)
                FBTrace.sysout("commandLine.attachConsoleOnFocus, attachConsole "+
                    Firebug.currentContext.window.location);
        }
        return true;
    },

    onPanelEnable: function(panelName)
    {
        collapse(Firebug.chrome.$("fbCommandBox"), true);
        collapse(Firebug.chrome.$("fbPanelSplitter"), true);
        collapse(Firebug.chrome.$("fbSidePanelDeck"), true);

        this.setMultiLine(Firebug.largeCommandLine, Firebug.chrome);
    },

    onPanelDisable: function(panelName)
    {
        if (panelName != 'console')  // we don't care about other panels
            return;

        collapse(Firebug.chrome.$("fbCommandBox"), true);
        collapse(Firebug.chrome.$("fbPanelSplitter"), true);
        collapse(Firebug.chrome.$("fbSidePanelDeck"), true);
    },

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    // Firebug.Console listener

    onConsoleInjected: function(context, win)
    {
        // for some reason the console has been injected. If the user had focus in the command
        // line they want it added in the page also. If the user has the cursor in the command
        // line and reloads, the focus will already be there. issue 1339
        var isFocused = (this.getCommandLineLarge().getAttribute("focused") == "true");
        isFocused = isFocused || (this.getCommandLineSmall().getAttribute("focused") == "true");
        if (isFocused)
            setTimeout(this.onCommandLineFocus);
    },

    getCommandLine: function(context)
    {
        // Command line on other panels is never multiline.
        var visible = Firebug.CommandLine.Popup.isVisible();
        if (visible && context.panelName != "console")
            return this.getCommandLineSmall();

        return Firebug.largeCommandLine
            ? this.getCommandLineLarge()
            : this.getCommandLineSmall();
    },

    getCompletionBox: function()
    {
        return Firebug.chrome.$("fbCommandLineCompletion");
    },

    getCommandLineSmall: function()
    {
        return Firebug.chrome.$("fbCommandLine");
    },

    getCommandLineLarge: function()
    {
        return Firebug.chrome.$("fbLargeCommandLine");
    }
});

// ************************************************************************************************
// Shared Helpers

Firebug.CommandLine.CommandHandler = extend(Object,
{
    handle: function(event, api, win)
    {
        var element = event.target;
        var methodName = win.document.getUserData("firebug-methodName");

        // We create this array in the page using JS, so we need to look on the wrappedJSObject for it.
        var hosed_userObjects = (win.wrappedJSObject?win.wrappedJSObject:win)._firebug.userObjects;

        var userObjects = hosed_userObjects ? cloneArray(hosed_userObjects) : [];

        if (FBTrace.DBG_COMMANDLINE)
            FBTrace.sysout("commandLine.CommandHandler: method "+methodName+" userObjects:",  userObjects);

        var subHandler = api[methodName];
        if (!subHandler)
            return false;

        win.document.setUserData("firebug-retValueType", null, null);
        var result = subHandler.apply(api, userObjects);
        if (typeof result != "undefined")
        {
            if (result instanceof Array)
            {
                win.document.setUserData("firebug-retValueType", "array", null);
                for (var item in result)
                    hosed_userObjects.push(result[item]);
            }
            else
            {
                hosed_userObjects.push(result);
            }
        }

        return true;
    }
});

// ************************************************************************************************
// Local Helpers

function getExpressionOffset(command, offset)
{
    // XXXjoe This is kind of a poor-man's JavaScript parser - trying
    // to find the start of the expression that the cursor is inside.
    // Not 100% fool proof, but hey...

    var bracketCount = 0;

    var start = command.length;
    while (start --> 0)
    {
        var c = command[start];
        if (reOpenBracket.test(c))
        {
            if (bracketCount)
                --bracketCount;
            else
                break;
        }
        else if (reCloseBracket.test(c))
        {
            if (bracketCount == 0 && command[start + 1] != '.')
                break;
            else
                ++bracketCount;
        }
        else if (bracketCount == 0)
        {
            if (!/[a-zA-Z0-9$_.]/.test(c))
                break;
        }
    }

    return start + 1;
}

function getDot(expr, offset)
{
    var lastDot = expr.lastIndexOf(".");
    if (lastDot == -1)
        return null;
    else
        return {start: lastDot+1, end: expr.length-1};
}

function autoCompleteEval(preExpr, expr, postExpr, context)
{
    var completions;

    try
    {
        if (preExpr)
        {
            // Remove the trailing dot (if there is one)
            var lastDot = preExpr.lastIndexOf(".");
            if (lastDot != -1)
                preExpr = preExpr.substr(0, lastDot);

            var self = this;
            self.complete = [];
            Firebug.CommandLine.evaluate(preExpr, context, context.thisValue, null,
                function found(result, context)
                {
                    if (FBTrace.DBG_COMMANDLINE)
                        FBTrace.sysout("commandLine.autoCompleteEval \'"+preExpr+"\' found result", result);

                    if (typeof result === 'string')
                        self.complete = [];
                    else if (FirebugReps.Arr.isArray(result))
                        self.complete = nonNumericKeys(result).sort();
                    else
                        self.complete = keys(result).sort();
                },
                function failed(result, context)
                {
                    if (FBTrace.DBG_COMMANDLINE)
                        FBTrace.sysout("commandLine.autoCompleteEval \'"+preExpr+"\' failed result", result);

                    self.complete = [];
                }
            );

            if (lastDot !== -1) // if we had no dot, add a keyword that matches exactly
                addMatchingKeyword(preExpr, self.complete);

            return self.complete;
        }
        else
        {
            if (context.stopped)
                return Firebug.Debugger.getCurrentFrameKeys(context);

            // Cross window type pseudo-comparison
            var innerWindow = context.window.wrappedJSObject;
            if (innerWindow && innerWindow.Window && innerWindow.constructor.toString() === innerWindow.Window.toString())
                completions =  keys(context.window.wrappedJSObject);  // return is safe
            else  // hopefull sandbox in Chromebug
                completions = keys(context.global);

            addMatchingKeyword(expr, completions);

            return completions.sort();
        }
    }
    catch (exc)
    {
        if (FBTrace.DBG_ERRORS || FBTrace.DBG_COMMANDLINE)
            FBTrace.sysout("commandLine.autoCompleteEval FAILED", exc);
        return [];
    }
}

var reValidJSToken = /^[A-Za-z_$][A-Za-z_$0-9]*/;
function isValidProperty(value)
{
    // Use only string props
    if (typeof(value) != "string")
        return false;

    // Use only those props that don't contain unsafe charactes and so need
    // quotation (e.g. object["my prop"] notice the space character).
    // Following expression checks that the name starts with a letter or $_,
    // and there are only letters, numbers or $_ character in the string (no spaces).

    return value.match(reValidJSToken) == value;
}

function addMatchingKeyword(expr, completions)
{
    if (isJavaScriptKeyword(expr))
        completions.push(expr);
}

function injectScript(script, win)
{
    win.location = "javascript: " + script;
}

// ************************************************************************************************
// Command line APIs definition
//
// These functions will be called in the extension like this:
//   subHandler.apply(api, userObjects);
// where subHandler is one of the entries below, api is this object and userObjects are entries in
// an array we created in the web page.

function FirebugCommandLineAPI(context)
{
    this.$ = function(id)  // returns unwrapped elements from the page
    {
        return FBL.unwrapObject(context.baseWindow.document).getElementById(id);
    };

    this.$$ = function(selector) // returns unwrapped elements from the page
    {
        var result = FBL.unwrapObject(context.baseWindow.document).querySelectorAll(selector);
        return cloneArray(result);
    };

    this.$x = function(xpath) // returns unwrapped elements from the page
    {
        return FBL.getElementsByXPath(FBL.unwrapObject(context.baseWindow.document), xpath);
    };

    this.$n = function(index) // values from the extension space
    {
        var htmlPanel = context.getPanel("html", true);
        if (!htmlPanel)
            return null;

        if (index < 0 || index >= htmlPanel.inspectorHistory.length)
            return null;

        var node = htmlPanel.inspectorHistory[index];
        if (!node)
            return node;

        return FBL.unwrapObject(node);
    };

    this.cd = function(object)
    {
        if (!(object instanceof Window))
            throw "Object must be a window.";

        // Make sure the command line is attached into the target iframe.
        var consoleReady = Firebug.Console.isReadyElsePreparing(context, object);
        if (FBTrace.DBG_COMMANDLINE)
            FBTrace.sysout("commandLine.cd; console ready: " + consoleReady);

        // The window object parameter uses XPCSafeJSObjectWrapper, but we need XPCNativeWrapper
        // (and its wrappedJSObject member). So, look within all registered consoleHandlers for
        // the same window (from tabWatcher) that uses uses XPCNativeWrapper (operator "==" works).
        var entry = Firebug.Console.injector.getConsoleHandler(context, object);
        if (entry)
            context.baseWindow = entry.win;

        Firebug.Console.log(["Current window:", context.baseWindow], context, "info");
    };

    this.clear = function()  // no web page interaction
    {
        Firebug.Console.clear(context);
    };

    this.inspect = function(obj, panelName)  // no web page interaction
    {
        Firebug.chrome.select(obj, panelName);
    };

    this.keys = function(o)
    {
        return FBL.keys(o);  // the object is from the page, unwrapped
    };

    this.values = function(o)
    {
        return FBL.values(o); // the object is from the page, unwrapped
    };

    this.debug = function(fn)
    {
        Firebug.Debugger.monitorFunction(fn, "debug");
    };

    this.undebug = function(fn)
    {
        Firebug.Debugger.unmonitorFunction(fn, "debug");
    };

    this.monitor = function(fn)
    {
        Firebug.Debugger.monitorFunction(fn, "monitor");
    };

    this.unmonitor = function(fn)
    {
        Firebug.Debugger.unmonitorFunction(fn, "monitor");
    };

    this.traceAll = function()
    {
        Firebug.Debugger.traceAll(Firebug.currentContext);
    };

    this.untraceAll = function()
    {
        Firebug.Debugger.untraceAll(Firebug.currentContext);
    };

    this.traceCalls = function(fn)
    {
        Firebug.Debugger.traceCalls(Firebug.currentContext, fn);
    };

    this.untraceCalls = function(fn)
    {
        Firebug.Debugger.untraceCalls(Firebug.currentContext, fn);
    };

    this.monitorEvents = function(object, types)
    {
        monitorEvents(object, types, context);
    };

    this.unmonitorEvents = function(object, types)
    {
        unmonitorEvents(object, types, context);
    };

    this.profile = function(title)
    {
        Firebug.Profiler.startProfiling(context, title);
    };

    this.profileEnd = function()
    {
        Firebug.Profiler.stopProfiling(context);
    };

    this.copy = function(x)
    {
        FBL.copyToClipboard(x);
    };
}

// ************************************************************************************************
Firebug.CommandLine.CommandHistory = function() {
    const commandHistoryMax = 1000;

    var commandsPopup = $("fbCommandHistory");
    var commands = [];
    var commandPointer = 0;
    var commandInsertPointer = -1;

    this.appendToHistory = function(command)
    {
        if (commands[commandInsertPointer] == command)
            return;

        commandInsertPointer++;

        if (commandInsertPointer >= commandHistoryMax)
            commandInsertPointer = 0;

        commandPointer = commandInsertPointer + 1;
        commands[commandInsertPointer] = command;

        if ($("fbCommandLineHistoryButton").hasAttribute("disabled"))
        {
            $("fbCommandLineHistoryButton").removeAttribute("disabled");
            $("fbCommandEditorHistoryButton").removeAttribute("disabled");
            commandsPopup.addEventListener("mouseover", this.onMouseOver, true);
            commandsPopup.addEventListener("mouseup", this.onMouseUp, true);
            commandsPopup.addEventListener("popuphidden", this.onPopupHidden, true);
        }
    };

    this.cycleCommands = function(context, dir)
    {
        var command,
            commandLine = Firebug.CommandLine.getCommandLine(context);

        if (dir < 0)
        {
            if (commandPointer > 0)
                commandPointer--;
        }
        else if (commandPointer < commands.length)
            commandPointer++;

        if (commandPointer < commands.length)
        {
            command =  commands[commandPointer];
            if (commandsPopup.state == "open")
            {
                var commandElements = commandsPopup.ownerDocument.getElementsByClassName("commandHistoryItem");
                this.selectCommand(commandElements[commandPointer]);
            }
        }
        else
        {
            command =  "";
            this.removeCommandSelection();
        }

        commandLine.value = context.commandLineText = command;

        Firebug.CommandLine.setCursor(commandLine, command.length);
    };

    this.isShown = function() {
        return commandsPopup.state == "open";
    };

    this.show = function(element) {
        if (this.isShown())
            return this.hide;

        FBL.eraseNode(commandsPopup);

        if(commands.length == 0)
            return;

        var vbox = commandsPopup.ownerDocument.createElement("vbox");

        for (var i = 0; i < commands.length; i++)
        {
            var hbox = commandsPopup.ownerDocument.createElementNS("http://www.w3.org/1999/xhtml", "div");

            hbox.classList.add("commandHistoryItem");
            var shortExpr = cropString(stripNewLines(commands[i]), 50);
            hbox.innerHTML = escapeForTextNode(shortExpr);
            hbox.value = i;
            vbox.appendChild(hbox);

            if (i === commandPointer)
                this.selectCommand(hbox);
        }

        commandsPopup.appendChild(vbox);
        commandsPopup.openPopup(element, "before_start", 0, 0, false, false);

        return true;
    };

    this.hide = function()
    {
        commandsPopup.hidePopup();

        return true;
    };

    this.toggle = function(element)
    {
        this.isShown() ? this.hide() : this.show(element);
    };

    this.removeCommandSelection = function()
    {
        var selected = commandsPopup.ownerDocument.getElementsByClassName("selected")[0];
        removeClass(selected, "selected");
    };

    this.selectCommand = function(element)
    {
        this.removeCommandSelection();

        setClass(element, "selected");
    };

    this.onMouseOver = function(event)
    {
        var hovered = event.target;

        if (hovered.localName == "vbox")
            return;

        Firebug.CommandLine.commandHistory.selectCommand(hovered);
    };

    this.onMouseUp = function(event)
    {
        var commandLine = Firebug.CommandLine.getCommandLine(Firebug.currentContext);

        commandLine.value = commands[event.target.value];
        commandPointer = event.target.value;

        Firebug.CommandLine.commandHistory.hide();
    };

    this.onPopupHidden = function(event)
    {
        Firebug.chrome.setGlobalAttribute("fbCommandLineHistoryButton", "checked", "false");
        Firebug.chrome.setGlobalAttribute("fbCommandEditorHistoryButton", "checked", "false");
    };
};

Firebug.CommandLine.injector = {

    attachCommandLine: function(context, win)
    {
        if (!win)
            return;

        if (win instanceof Window)
        {
            // If the command line is already attached then end.
            if (win.document.getUserData("firebug-CommandLineListener") === "true")
                return;

            var doc = win.document;

            if (context.stopped)
                Firebug.CommandLine.injector.evalCommandLineScript(context);
            else
                Firebug.CommandLine.injector.injectCommandLineScript(doc);

            Firebug.CommandLine.injector.addCommandLineListener(context, win);
        }
        else if (Firebug.CommandLine.isSandbox(context))
        {
            if (FBTrace.DBG_COMMANDLINE)
                FBTrace.sysout("commandLine.injector context.global "+context.global, context.global);
            // no-op
        }
        else
        {
            if (FBTrace.DBG_COMMANDLINE)
                FBTrace.sysout("commandLine.injector not a Window or Sandbox", win);
        }
    },

    evalCommandLineScript: function(context)
    {
        var scriptSource = getResource("chrome://firebug/content/commandLineInjected.js");
        Firebug.Debugger.evaluate(scriptSource, context);
        if (FBTrace.DBG_COMMANDLINE)
            FBTrace.sysout("commandLine.evalCommandLineScript ", scriptSource);
    },

    injectCommandLineScript: function(doc)
    {
        // Inject command line script into the page.
        var scriptSource = getResource("chrome://firebug/content/commandLineInjected.js");
        var addedElement = addScript(doc, "_firebugCommandLineInjector", scriptSource);
        if (FBTrace.DBG_COMMANDLINE)
            FBTrace.sysout("commandLine.injectCommandLineScript ", addedElement);

        // take it right back out, we don't want users to see the things we do ;-)
        if (addedElement)
        {
            setTimeout(function delayRemoveScript()
            {
                if (addedElement.parentNode)
                    addedElement.parentNode.removeChild(addedElement);
            });
        }

    },

    addCommandLineListener: function(context, win)
    {
        // Register listener for command-line execution events.
        var handler = new CommandLineHandler(context, win);

        var boundHandler = bind(handler.handleEvent, handler);

        this.setCommandLineListener(context, win, boundHandler);

        win.document.addEventListener("firebugExecuteCommand", boundHandler, true);
        win.document.setUserData("firebug-CommandLineListener", "true", null);

        if (FBTrace.DBG_COMMANDLINE)
            FBTrace.sysout("commandLine.addCommandLineListener to document in window"+win.location+" with console ", win.console);
    },

    getCommandLineListener: function(context, win)
    {
        if (context.activeCommandLineHandlers)
        {
            var consoleHandler = Firebug.Console.injector.getConsoleHandler(context, win);
            if (consoleHandler)
                return context.activeCommandLineHandlers[consoleHandler.token];

            if (FBTrace.DBG_CONSOLE)
                FBTrace.sysout("getCommandLineListener no consoleHandler for "+context.getName()+" win "+safeGetWindowLocation(win));
        }
    },

    setCommandLineListener: function(context, win, boundHandler)
    {
        if (!context.activeCommandLineHandlers)
            context.activeCommandLineHandlers = {};

        var consoleHandler = Firebug.Console.injector.getConsoleHandler(context, win);
        context.activeCommandLineHandlers[consoleHandler.token] = boundHandler;
    },

    detachCommandLine: function(context, win)
    {
        if (win.document.getUserData("firebug-CommandLineListener") === "true")
        {
            if (FBTrace.DBG_ERRORS)
            {
                function failureCallback(result, context)
                {
                    FBTrace.sysout("Firebug.CommandLine.evaluate FAILS  "+result, result);
                }
            }
            Firebug.CommandLine.evaluate("window._FirebugCommandLine.detachCommandLine()", context, null, win, null, failureCallback );

            var boundHandler = this.getCommandLineListener(context, win);
            if (boundHandler)
                win.document.removeEventListener("firebugExecuteCommand", boundHandler, true);

            win.document.setUserData("firebug-CommandLineListener", null, null);
            if (FBTrace.DBG_COMMANDLINE)
                FBTrace.sysout("commandLine.detachCommandLineListener "+boundHandler+" in window with console "+win.location);
        }
    }
};

function CommandLineHandler(context, win)
{
    this.handleEvent = function(event)  // win is the window the handler is bound into
    {
        context.baseWindow = context.baseWindow || context.window;
        this.api = new FirebugCommandLineAPI(context);

        if (FBTrace.DBG_COMMANDLINE)
            FBTrace.sysout("commandLine.handleEvent('firebugExecuteCommand') event in context.baseWindow "+
                context.baseWindow.location, event);

        // Appends variables into the api.
        var htmlPanel = context.getPanel("html", true);
        var vars = htmlPanel ? htmlPanel.getInspectorVars():null;

        for (var prop in vars)
        {
            function createHandler(p) {
                return function() {
                    if (FBTrace.DBG_COMMANDLINE)
                        FBTrace.sysout("commandLine.getInspectorHistory: " + p, vars);
                    return FBL.unwrapObject(vars[p]);
                }
            }
            this.api[prop] = createHandler(prop);  // XXXjjb should these be removed?
        }

        if (!Firebug.CommandLine.CommandHandler.handle(event, this.api, win))
        {
            var methodName = win.document.getUserData("firebug-methodName");
            Firebug.Console.log($STRF("commandline.MethodNotSupported", [methodName]));
        }

        if (FBTrace.DBG_COMMANDLINE)
            FBTrace.sysout("commandLine.handleEvent() "+win.document.getUserData("firebug-methodName")+
                " context.baseWindow: "+(context.baseWindow?context.baseWindow.location:"no basewindow"),
                context.baseWindow);
    };
}

function getNoScript()
{
    if (!this.noscript)
        this.noscript = Cc["@maone.net/noscript-service;1"] &&
            Cc["@maone.net/noscript-service;1"].getService().wrappedJSObject;
    return this.noscript;
}

// ************************************************************************************************
// Registration

Firebug.registerModule(Firebug.CommandLine);

// ************************************************************************************************
return Firebug.CommandLine;
}});
