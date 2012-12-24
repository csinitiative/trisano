/* See license.txt for terms of usage */

// ************************************************************************************************
// Constants

const EXTENSIONS = "extensions";
const DBG_ = "DBG_";

const Cc = Components.classes;
const Ci = Components.interfaces;
const Cr = Components.results;

var EXPORTED_SYMBOLS = ["traceConsoleService"];

const PrefService = Cc["@mozilla.org/preferences-service;1"];
const prefs = PrefService.getService(Ci.nsIPrefBranch2);
const prefService = PrefService.getService(Ci.nsIPrefService);
const consoleService = Cc["@mozilla.org/consoleservice;1"].getService(Ci.nsIConsoleService);

const appShellService = Components.classes["@mozilla.org/appshell/appShellService;1"].getService(Components.interfaces.nsIAppShellService);

// ************************************************************************************************
// Service implementation


var toOSConsole = false;

var traceConsoleService =
{
    initialize: function() {
        this.observers = [];
        this.optionMaps = {};

        // Listen for preferences changes. Trace Options can be changed at run time.
        prefs.addObserver("extensions", this, false);

        return this;
    },

    osOut: function(str)
    {
        if (!this.outChannel)
        {
            try
            {
                var appShellService = Components.classes["@mozilla.org/appshell/appShellService;1"].
                    getService(Components.interfaces.nsIAppShellService);
                this.hiddenWindow = appShellService.hiddenDOMWindow;
                this.outChannel = "hidden";
            }
            catch(exc)
            {
                var consoleService = Cc["@mozilla.org/consoleservice;1"].getService(Ci.nsIConsoleService);
                this.outChannel = "service"
                this.outChannel("Using consoleService because nsIAppShellService.hiddenDOMWindow not available "+exc);
            }
        }
        if (this.outChannel === "hidden")  // apparently can't call via JS function
            this.hiddenWindow.dump(str);
        else
            consoleService.logStringMessage(str);
    },

    getTracer: function(prefDomain)
    {
        if (this.getPref("extensions.firebug-tracing-service.DBG_toOSConsole"))
        {
             toOSConsole = true;  // also need browser.dom.window.dump.enabled true
             traceConsoleService.osOut("traceConsoleService.getTracer, prefDomain: "+prefDomain+"\n");
        }

        if (!this.optionMaps[prefDomain])
            this.optionMaps[prefDomain] = this.createManagedOptionMap(prefDomain);

        return this.optionMaps[prefDomain];
    },

    createManagedOptionMap: function(prefDomain)
    {
        var optionMap = new TraceBase(prefDomain);

        var branch = prefService.getBranch ( prefDomain );
        var arrayDesc = {};
        var children = branch.getChildList("", arrayDesc);
        for (var i = 0; i < children.length; i++)
        {
            var p = children[i];
            var m = p.indexOf("DBG_");
            if (m != -1)
            {
                var optionName = p.substr(1); // drop leading .
                optionMap[optionName] = this.getPref(prefDomain+p);
                if (toOSConsole)
                    this.osOut("traceConsoleService.createManagedOptionMap "+optionName+"="+optionMap[optionName]+"\n");
            }
        }

        return optionMap;
    },

    /* nsIObserve */
    observe: function(subject, topic, data)
    {
        if (data.substr(0,EXTENSIONS.length) == EXTENSIONS)
        {
            for (var prefDomain in traceConsoleService.optionMaps)
            {
                if (data.substr(0, prefDomain.length) == prefDomain)
                {
                    var optionName = data.substr(prefDomain.length+1); // skip dot
                    if (optionName.substr(0, DBG_.length) == DBG_)
                        traceConsoleService.optionMaps[prefDomain][optionName] = this.getPref(data);
                    if (toOSConsole)
                        traceConsoleService.osOut("traceConsoleService.observe, prefDomain: "+prefDomain+" optionName "+optionName+"\n");
                }
            }
        }
    },

    getPref: function(prefName)
    {
        var type = prefs.getPrefType(prefName);
        if (type == Ci.nsIPrefBranch.PREF_STRING)
            return prefs.getCharPref(prefName);
        else if (type == Ci.nsIPrefBranch.PREF_INT)
            return prefs.getIntPref(prefName);
        else if (type == Ci.nsIPrefBranch.PREF_BOOL)
            return prefs.getBoolPref(prefName);
    },

    // Prepare trace-object and dispatch to all observers.
    dispatch: function(messageType, message, obj, scope)
    {
        // Translate string object.
        if (typeof(obj) == "string") {
            var string = Cc["@mozilla.org/supports-cstring;1"].createInstance(Ci.nsISupportsCString);
            string.data = obj;
            obj = string;
        }

        // Create wrapper with message type info.
        var messageInfo = {
            obj: obj,
            type: messageType,
            scope: scope,
            time: (new Date()).getTime()
        };
        if (toOSConsole)
            traceConsoleService.osOut(messageType+": "+message+"\n");
        // Pass JS object properly through XPConnect.
        var wrappedSubject = {wrappedJSObject: messageInfo};
        traceConsoleService.notifyObservers(wrappedSubject, "firebug-trace-on-message", message);
    },

    /* nsIObserverService */
    addObserver: function(observer, topic, weak)
    {
        if (topic != "firebug-trace-on-message")
            throw Cr.NS_ERROR_INVALID_ARG;

        if (this.observers.length == 0) // mark where trace begins.
            lastResort(this.observers, topic, "addObserver");

        this.observers.push(observer);
    },

    removeObserver: function(observer, topic)
    {
        if (topic != "firebug-trace-on-message")
            throw Cr.NS_ERROR_INVALID_ARG;

        for (var i=0; i < this.observers.length; i++) {
            if (this.observers[i] == observer) {
                this.observers.splice(i, 1);
                break;
            }
        }
    },

    notifyObservers: function(subject, topic, someData)
    {
        if (this.observers.length > 0)
        {
            for (var i=0; i < this.observers.length; i++)
            {
                try
                {
                    this.observers[i].observe(subject, topic, someData);
                }
                catch (err)
                {
                    // If it's not possible to distribute the log through registered observers,
                    // use Firefox ErrorConsole. Ultimately the trace-console listens for it
                    // too and so, will display that.
                    var scriptError = Cc["@mozilla.org/scripterror;1"].createInstance(Ci.nsIScriptError);
                    scriptError.init("[JavaScript Error: Failed to notify firebug-trace observers!] " +
                        err.toString(), err.sourceName,
                        err.sourceLine, err.lineNumber, err.columnNumber, err.flags, err.category);
                    consoleService.logMessage(scriptError);
                }
            }
        }
        else
        {
            lastResort(this.observers, subject, someData);
        }
    },

    enumerateObservers: function(topic)
    {
        return null;
    },

    /* nsISupports */
    QueryInterface: function(iid)
    {
        if (iid.equals(Ci.nsISupports) ||
            iid.equals(Ci.nsIObserverService))
             return this;

        throw Cr.NS_ERROR_NO_INTERFACE;
    }
};

function lastResort(listeners, subject, someData)
{
    var unwrapped = subject.wrappedJSObject;
    if (unwrapped)
        var objPart = unwrapped.obj ? (" obj: "+unwrapped.obj) : "";
    else
        var objPart = subject;

    traceConsoleService.osOut("FTS"+listeners.length+": "+someData+" "+objPart+"\n");
}
// ************************************************************************************************
// Public TraceService API

var TraceAPI = {
    dump: function(messageType, message, obj) {
        if (this.noTrace)
            return;

        this.noTrace = true;
        try
        {
            traceConsoleService.dispatch(messageType, message, obj);
        }
        catch(exc)
        {
        }
        finally
        {
            this.noTrace = false;
        }
    },

    sysout: function(message, obj) {
        this.dump("no-message-type", message, obj);
    },

    setScope: function(scope)
    {
        this.scopeOfFBTrace = scope;
    },

    matchesNode: function(node)
    {
        return (node.getAttribute('anonid')=="title-box");
    },

    time: function(name, reset)
    {
        if (!name)
            return;

        var time = new Date().getTime();

        if (!this.timeCounters)
            this.timeCounters = {};

        var key = "KEY"+name.toString();

        if (!reset && this.timeCounters[key])
            return;

        this.timeCounters[key] = time;
    },

    timeEnd: function(name)
    {
        var time = new Date().getTime();

        if (!this.timeCounters)
            return;

        var key = "KEY"+name.toString();

        var timeCounter = this.timeCounters[key];
        if (timeCounter)
        {
            var diff = time - timeCounter;
            var label = name + ": " + diff + "ms";

            this.sysout(label);

            delete this.timeCounters[key];
        }

        return diff;
    }
};

var TraceBase = function(prefDomain) {
    this.prefDomain = prefDomain;
}
//Derive all properties from TraceAPI
for (var p in TraceAPI)
    TraceBase.prototype[p] = TraceAPI[p];

TraceBase.prototype.sysout = function(message, obj) {
        if (this.noTrace)
            return;

        this.noTrace = true;

        try
        {
            traceConsoleService.dispatch(this.prefDomain, message, obj, this.scopeOfFBTrace);
        }
        catch(exc)
        {
            if (toOSConsole)
                traceConsoleService.osOut("traceConsoleService.dispatch FAILS "+exc+"\n");
        }
        finally
        {
            this.noTrace = false;
        }
}

traceConsoleService.initialize();