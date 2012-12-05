/* See license.txt for terms of usage */

// ************************************************************************************************
// Module

var rootPath = "";
if (typeof(require) == "undefined") {
    var chrome = typeof(Components) != "undefined";
    require = chrome ? Components.utils["import"] : function(){};
    rootPath = chrome ? "resource://firebug/bti/" : "";
}

require(rootPath + "lib.js");
require(rootPath + "objectreference.js");

var EXPORTED_SYMBOLS = ["Browser"];

// ************************************************************************************************
// Browser

/**
 * Proxy to a debuggable web browser. A browser may be remote and contain one or more
 * JavaScript execution contexts. Each JavaScript execution context may contain one or
 * more compilation units. A browser provides notification to registered listeners describing
 * events that occur in the browser.
 *
 * @constructor
 * @type Browser
 * @return a new Browser
 * @version 1.0
 */
function Browser()
{
    this.contexts = {}; // map of contexts, indexed by context ID
    this.activeContext = null;
    this.handlers = {}; // map of event types to array of handler functions
    this.EVENT_TYPES = ["onBreak", "onConsoleDebug", "onConsoleError", "onConsoleInfo",
        "onConsoleLog", "onConsoleWarn", "onContextCreated", "onContextDestroyed",
        "onContextChanged", "onContextLoaded", "onInspectNode", "onResume", "onScript",
        "onSuspend", "onToggleBreakpoint", "onBreakpointError", "onDisconnect"];
    this.connected = false;
}

// ************************************************************************************************
// API

/**
 * Returns current status of tools 
 *
 * @function
 * @returns  an array of Tools, an object with toolName and enabled boolean
 *
 */
Browser.prototype.getTools = function()
{
    return [];
};

/**
 * Returns the {@link BrowserContext} with the specified id or <code>null</code>
 * if none.
 *
 * @function
 * @param id identifier of an {@link BrowserContext}
 * @returns the {@link BrowserContext} with the specified id or <code>null</code>
 *
 */
Browser.prototype.getBrowserContext = function(id)
{
    var context = this.contexts[id];
    if (context)
        return context;
    return null;
};

/**
 * Returns the root contexts being browsed. A {@link BrowserContext} represents the
 * content that has been served up and is being rendered for a location (URL) that
 * has been navigated to.
 * <p>
 * This function does not require communication with the remote browser.
 * </p>
 * @function
 * @returns an array of {@link BrowserContext}'s
 */
Browser.prototype.getBrowserContexts = function()
{
    var knownContexts = [];
    for (var id in this.contexts)
        knownContexts.push(this.contexts[id]);
    return knownContexts;
};

/**
 * Returns the {@link BrowserContext} that currently has focus in the browser
 * or <code>null</code> if none.
 *
 * @function
 * @returns the {@link BrowserContext} that has focus or <code>null</code>
 */
Browser.prototype.getFocusBrowserContext = function()
{
    return this.activeContext;
};

/**
 * Returns whether this proxy is currently connected to the underlying browser it
 * represents.
 *
 *  @function
 *  @returns whether connected to the underlying browser
 */
Browser.prototype.isConnected = function()
{
    return this.connected;
};

/**
 * Registers a listener (function) for a specific type of event. Listener
 * call back functions are specified in {@link BrowserEventListener}.
 * <p>
 * The supported event types are:
 * <ul>
 *   <li>onBreak</li>
 *   <li>onConsoleDebug</li>
 *   <li>onConsoleError</li>
 *   <li>onConsoleInfo</li>
 *   <li>onConsoleLog</li>
 *   <li>onConsoleWarn</li>
 *   <li>onContextCreated</li>
 *   <li>onContextChanged</li>
 *   <li>onContextDestroyed</li>
 *   <li>onDisconnect</li>
 *   <li>onInspectNode</li>
 *   <li>onResume</li>
 *   <li>onScript</li>
 *   <li>onToggleBreakpoint</li>
 * </ul>
 * <ul>
 * <li>TODO: how can clients remove (deregister) listeners?</li>
 * </ul>
 * </p>
 * @function
 * @param eventType an event type ({@link String}) listed above
 * @param listener a listener (function) that handles the event as specified
 *   by {@link BrowserEventListener}
 * @exception Error if an unsupported event type is specified
 */
Browser.prototype.addEventListener = function(eventType, listener)
{
    var i = this.EVENT_TYPES.indexOf(eventType);
    if (i < 0)
    {
        // unsupported event type
        throw new Error("eventType '" + eventType + "' is not supported");
    }
    var list = this.handlers[eventType];
    if (!list)
    {
        list = [];
        this.handlers[eventType] = list;
    }
    list.push(listener);
};

/**
 * Disconnects this client from the browser it is associated with.
 *
 * @function
 */
Browser.prototype.disconnect = function()
{
};

//TODO: support to remove a listener

// ************************************************************************************************
// Private, subclasses may call these functions

/**
 * Notification the given context has been added to this browser.
 * Adds the context to the list of active contexts and notifies context
 * listeners.
 * <p>
 * Has no effect if the context has already been created. For example,
 * it's possible for a race condition to occur when a remote browser
 * sends notification of a context being created before the initial set
 * of contexts have been retrieved. In such a case, it would possible for
 * a client to add the context twice (once for the create event, and again
 * when retrieving the initial list of contexts).
 * </p>
 * @function
 * @param context the {@link BrowserContext} that has been added
 */
Browser.prototype._contextCreated = function(context)
{
    // if already present, don't add it again
    var id = context.getId();
    if (this.contexts[id])
        return;

    this.contexts[id] = context;
    this._dispatch("onContextCreated", [context]);
};

/**
 * Notification the given context has been destroyed.
 * Removes the context from the list of active contexts and notifies context
 * listeners.
 * <p>
 * Has no effect if the context has already been destroyed or has not yet
 * been retrieved from the browser. For example, it's possible for a race
 * condition to occur when a remote browser sends notification of a context
 * being destroyed before the initial list of contexts is retrieved from the
 * browser. In this case an implementation could ask to destroy a context that
 * that has not yet been reported as created.
 * </p>
 *
 * @function
 * @param id the identifier of the {@link BrowserContext} that has been destroyed
 */
Browser.prototype._contextDestroyed = function(id)
{
    var destroyed = this.contexts[id];
    if (destroyed)
    {
        destroyed._destroyed();
        delete this.contexts[id];
        this._dispatch("onContextDestroyed", [destroyed]);
    }
};

/**
 * Notification the given context has been loaded. Notifies context listeners.
 *
 * @function
 * @param id the identifier of the {@link BrowserContext} that has been loaded
 */
Browser.prototype._contextLoaded = function(id)
{
    var loaded = this.contexts[id];
    if (loaded)
    {
        loaded._loaded();
        this._dispatch("onContextLoaded", [loaded]);
    }
};

/**
 * Dispatches an event notification to all registered functions for
 * the specified event type.
 *
 * @param eventType event type
 * @param arguments arguments to be applied to handler functions
 */
Browser.prototype._dispatch = function(eventType, args)
{
    var functions = this.handlers[eventType];
    if (functions)
    {
        for ( var i = 0; i < functions.length; i++)
            functions[i].apply(null, args);
    }
};

/**
 * Sets the browser context that has focus, possibly <code>null</code>.
 *
 * @function
 * @param context a {@link BrowserContext} or <code>null</code>
 */
Browser.prototype._setFocusContext = function(context)
{
    var prev = this.activeContext;
    this.activeContext = context;
    if (prev !== context)
        this._dispatch("onContextChanged", [prev, this.activeContext]);
};

/**
 * Sets whether this proxy is connected to its underlying browser.
 * Sends 'onDisconnect' notification when the browser becomes disconnected.
 *
 * @function
 * @param connected whether this proxy is connected to its underlying browser
 */
Browser.prototype._setConnected = function(connected)
{
    var wasConnected = this.connected;
    this.connected = connected;
    if (wasConnected && !connected)
        this._dispatch("onDisconnect", [this]);
};

// ************************************************************************************************
// Event Listener

/**
 * Describes the event listener functions supported by a {@link Browser}.
 *
 * @constructor
 * @type BrowserEventListener
 * @return a new {@link BrowserEventListener}
 * @version 1.0
 */
Browser.EventListener = {

    /**
     * Notification that execution has suspended in the specified
     * compilation unit.
     *
     * @function
     * @param compilationUnit the {@link CompilationUnit} execution has suspended in
     * @param lineNumber the line number execution has suspended at
     */
    onBreak: function(compilationUnit, lineNumber) {},

    /**
     * TODO:
     */
    onConsoleDebug: function() {},

    /**
     * TODO:
     */
    onConsoleError: function() {},

    /**
     * Notification the specified information messages have been logged.
     *
     * @function
     * @param browserContext the {@link BrowserContext} the messages were logged from
     * @param messages array of messages as {@link String}'s
     */
    onConsoleInfo: function(browserContext, messages) {},

    /**
     * Notification the specified messages have been logged.
     *
     * @function
     * @param browserContext the {@link BrowserContext} the messages were logged from
     * @param messages array of messages as {@link String}'s
     */
    onConsoleLog: function(browserContext, messages) {},

    /**
     * Notification the specified warning messages have been logged.
     *
     * @function
     * @param browserContext the {@link BrowserContext} the messages were logged from
     * @param messages array of messages as {@link String}'s
     */
    onConsoleWarn: function(browserContext, messages) {},

    /**
     * Notification the specified browser context has been created. This notification
     * is sent when a new context is created and before any scripts are compiled in
     * the new context.
     *
     * @function
     * @param browserContext the {@link BrowserContext} that was created
     */
    onContextCreated: function(browserContext) {},

    /**
     * Notification the focus browser context has been changed.
     *
     * @function
     * @param fromContext the previous {@link BrowserContext} that had focus or <code>null</code>
     * @param toContext the {@link BrowserContext} that now has focus or <code>null</code>
     */
    onContextChanged: function(fromContext, toContext) {},

    /**
     * Notification the specified browser context has been destroyed.
     *
     * @function
     * @param browserContext the {@link BrowserContext} that was destroyed
     */
    onContextDestroyed: function(browserContext) {},

    /**
     * Notification the specified browser context has completed loading.
     *
     * @function
     * @param browserContext the {@link BrowserContext} that has completed loading
     */
    onContextLoaded: function(browserContext) {},

    /**
     * Notification the connection to the remote browser has been closed.
     *
     * @function
     * @param browser the {@link Browser} that has been disconnected
     */
    onDisconnect: function(browser) {},

    /**
     * TODO:
     */
    onInspectNode: function() {},

    /**
     * Notification the specified execution context has resumed execution.
     *
     * @function
     * @param stack the {@link JavaScriptStack} that has resumed
     */
    onResume: function(stack) {},

    /**
     * Notification the specified compilation unit has been compiled (loaded)
     * in its browser context.
     *
     * @function
     * @param compilationUnit the {@link CompilationUnit} that has been compiled
     */
    onScript: function(compilationUnit) {},

    /**
     * Notification the specified breakpoint has been installed or cleared.
     * State can be retrieved from the breakpoint to determine whether the
     * breakpoint is installed or cleared.
     *
     * @function
     * @param breakpoint the {@link Breakpoint} that has been toggled
     */
    onToggleBreakpoint: function(breakpoint) {},

    /**
     * Notification the specified breakpoint has failed to install or clear.
     * State can be retrieved from the breakpoint to determine what failed.
     *
     * @function
     * @param breakpoint the {@link Breakpoint} that failed to install or clear
     */
    onBreakpointError: function(breakpoint) {}
};

// ************************************************************************************************
// CommonJS

exports = Browser;

