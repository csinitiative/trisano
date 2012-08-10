/* See license.txt for terms of usage */

FBL.ns(function() { with (FBL) {

// ************************************************************************************************
// Constants

const Cc = Components.classes;
const Ci = Components.interfaces;

const prefs = Cc["@mozilla.org/preferences-service;1"].getService(Ci.nsIPrefBranch2);

// The service doesn't have to be available if Firefox is built with privatebrowsing disabled so,
// don't foreget to check it before access (issue 2923).
const privateBrowsingEnabled = ("@mozilla.org/privatebrowsing;1" in Cc) &&
    Cc["@mozilla.org/privatebrowsing;1"].getService(Ci.nsIPrivateBrowsingService).privateBrowsingEnabled;

// ************************************************************************************************

/**
 * @module Implements Firebug activation logic.
 *
 * 1) Part of the logic is based on annotation service (see components/firebug-annotations.js)
 *    in order to remember whether Firebug is activated for given site or not.
 *    If there is "firebugged.showFirebug" annotation for a given site Firbug is activated.
 *    If there is "firebugged.closed" annotation for a given site Firbug is not activated.
 *
 * 2) Other part is based on extensions.firebug.allPagesActivation option. This option
 *    can be set to the following values:
 *    none: The option isn't used (default value)
 *    on:   Firebug is activated for all URLs.
 *    off:  Firebug is never activated.
 *
 *    This logic has higher priority over the URL annotations.
 *    If "off" options is selected, all existing URL annotations are removed.
 */
Firebug.Activation = extend(Firebug.Module,
{
    dispatchName: "activation",

    initializeUI: function()  // called once
    {
        Firebug.Module.initializeUI.apply(this, arguments);

        Firebug.TabWatcher.addListener(this.TabWatcherListener);

        // The "off" option is removed so make sure to convert previsous prev value
        // into "none" if necessary.
        if (Firebug.allPagesActivation == "off")
            Firebug.allPagesActivation = "none";

        // Update option menu item.
        this.updateAllPagesActivation();
    },

    getAnnotationService: function()
    {
        if (!this.annotationSvc)
        {
            // Import annotation service.
            Components.utils.import("resource://firebug/firebug-annotations.js");
            this.annotationSvc = annotationService;
        }
        return this.annotationSvc;
    },

    shutdown: function()
    {
        Firebug.Module.shutdown.apply(this, arguments);

        Firebug.TabWatcher.removeListener(this.TabWatcherListener);

        this.getAnnotationService().flush();
    },

    convertToURIKey: function(url, sameOrigin)  // process the URL to canonicalize it. Need not be reversible.
    {
        // Remove fragment, it shouldn't have any impact on the activation.
        url = url.replace(/#.*/, "");

        var uri = makeURI(normalizeURL(url));

        if (Firebug.filterSystemURLs && isSystemURL(url))
            return uri;

        if (url == "about:blank")  // avoid exceptions.
            return uri;

        if (uri && sameOrigin)
        {
            try
            {
                var prePath = uri.prePath; // returns the string before the path (such as "scheme://user:password@host:port").
                var shortURI = makeURI(prePath);
                if (!shortURI)
                    return uri;

                // annoying "about" URIs throw if you access .host
                if (shortURI.scheme === "about")
                    return shortURI;

                if (shortURI.scheme === "file")
                    return shortURI;

                var host = shortURI.host;
                if (host)
                {
                    // Slice the subdomain (if any) from the URL so, activateSameOrigin works for
                    // domains (including TLD domains). So we want:
                    // 1) www.google.com -> google.com
                    // 2) www.stuff.co.nz -> stuff.co.nz
                    // 3) getfirebug.com -> getfirebug.com
                    // 4) xxxHonza: what about: mail.cn.mozilla.com -> mozilla.com ?
                    var levels = host.split('.');
                    if (levels.length > 2)
                        levels = levels.slice(1);
                    shortURI.host = levels.join('.');
                    return shortURI;
                }
            }
            catch (exc)
            {
                if (FBTrace.DBG_ERRORS)
                    FBTrace.sysout("activation.convertToURIKey returning full URI, activateSameOrigin FAILS for shortURI "+shortURI+" because: "+exc, exc);
                return uri;
            }
        }
        return uri;
    },

    shouldCreateContext: function(browser, url, userCommands)  // true if the Places annotation the URI "firebugged"
    {
        if (FBTrace.DBG_ACTIVATION)
            FBTrace.sysout("shouldCreateContext allPagesActivation " + Firebug.allPagesActivation);

        if (Firebug.allPagesActivation == "on")
            return true;

        if (Firebug.filterSystemURLs && isSystemURL(url)) // if about:blank gets thru, 1483 fails
            return false;

        if (userCommands)
            return true;

        if (browser.showFirebug && url.substr(0, 8) === "wyciwyg:")  // document.open on a firebugged page
            return true;

        try
        {
            var uri = this.convertToURIKey(url, Firebug.activateSameOrigin);
            if (!uri)
                return false;

            var hasAnnotation = this.getAnnotationService().pageHasAnnotation(uri);

            if (FBTrace.DBG_ACTIVATION)
                FBTrace.sysout("shouldCreateContext hasAnnotation "+hasAnnotation +
                    " for "+uri.spec+" in "+browser.contentWindow.location +
                    " using activateSameOrigin: "+Firebug.activateSameOrigin);

            // Annotated so, return the value.
            if (hasAnnotation)
                return this.checkAnnotation(browser, uri);

            if (browser.FirebugLink) // then Firebug.TabWatcher found a connection
            {
                var dst = browser.FirebugLink.dst;
                var dstURI = this.convertToURIKey(dst.spec, Firebug.activateSameOrigin);
                if (FBTrace.DBG_ACTIVATION)
                    FBTrace.sysout("shouldCreateContext found FirebugLink pointing to " +
                        dstURI.spec, browser.FirebugLink);

                if (dstURI && dstURI.equals(uri)) // and it matches us now
                {
                    var srcURI = this.convertToURIKey(browser.FirebugLink.src.spec, Firebug.activateSameOrigin);
                    if (srcURI)
                    {
                        if (FBTrace.DBG_ACTIVATION)
                            FBTrace.sysout("shouldCreateContext found FirebugLink pointing from " +
                                srcURI.spec, browser.FirebugLink);

                        if (srcURI.schemeIs("file") || (dstURI.host == srcURI.host) ) // and it's on the same domain
                        {
                            hasAnnotation = this.getAnnotationService().pageHasAnnotation(srcURI);
                            if (hasAnnotation) // and the source page was annotated.
                            {
                                var srcShow = this.checkAnnotation(browser, srcURI);
                                if (srcShow)  // and the source annotation said show it
                                    this.watchBrowser(browser);  // so we show dst as well.
                                return srcShow;
                            }
                        }
                    }
                }
                else
                {
                    if (FBTrace.DBG_ACTIVATION)
                        FBTrace.sysout("shouldCreateContext FirebugLink does not match "+uri.spec, browser.FirebugLink);
                }
            }
            else if (browser.contentWindow.opener)
            {
                var openerContext = Firebug.TabWatcher.getContextByWindow(browser.contentWindow.opener);

                if (FBTrace.DBG_ACTIVATION)
                    FBTrace.sysout("shouldCreateContext opener found, has "+
                        (openerContext?"a ":"no ")+" context: "+
                        browser.contentWindow.opener.location);

                if (openerContext)
                    return true;  // popup windows of Firebugged windows are Firebugged
            }

            return false;   // don't createContext
        }
        catch (exc)
        {
            if (FBTrace.DBG_ERRORS)
                FBTrace.sysout("pageHasAnnoation FAILS for url: "+url+" which gave uri "+(uri?uri.spec:"null"), exc);
        }
    },

    checkAnnotation: function(browser, uri)
    {
        var annotation = this.getAnnotationService().getPageAnnotation(uri);

        if (FBTrace.DBG_ACTIVATION)
            FBTrace.sysout("shouldCreateContext read back annotation "+annotation+" for uri "+uri.spec);

        // then the user closed Firebug on this page last time
        if ((Firebug.allPagesActivation != "on") && (annotation.indexOf("closed") > 0))
            return false; // annotated as 'closed', don't create
        else
            return true;    // annotated, createContext
    },

    shouldShowContext: function(context)
    {
        return this.shouldCreateContext(context.browser, context.getWindowLocation().toString());
    },

    watchBrowser: function(browser)  // Firebug is opened in browser
    {
        var annotation = "firebugged.showFirebug";
        this.setPageAnnotation(browser.currentURI.spec, annotation);
    },

    unwatchBrowser: function(browser, userCommands)  // Firebug closes in browser
    {
        var uri = browser.currentURI.spec;
        if (userCommands)  // then mark to not open virally.
            this.setPageAnnotation(uri, "firebugged.closed");
        else
            this.removePageAnnotation(uri); // unmark this URI
    },

    clearAnnotations: function()
    {
        this.getAnnotationService().clear();
        this.getAnnotationService().flush();
    },

    setPageAnnotation: function(currentURI, annotation)
    {
        if (privateBrowsingEnabled)
        {
            Firebug.Console.logFormatted(
                [$STR("firebug.activation.privateBrowsingMode")],
                Firebug.currentContext, "info");
            Firebug.chrome.selectPanel('console');
            return;
        }

        var uri = this.convertToURIKey(currentURI, Firebug.activateSameOrigin);
        if (uri)
            this.getAnnotationService().setPageAnnotation(uri, annotation);

        if (FBTrace.DBG_ACTIVATION || FBTrace.DBG_ANNOTATION)
            FBTrace.sysout("setPageAnnotation currentURI "+currentURI+" becomes URI key "+
                (uri?uri.spec:"ERROR"));

        if (Firebug.activateSameOrigin)
        {
            uri = this.convertToURIKey(currentURI, false);
            if (uri)
                this.getAnnotationService().setPageAnnotation(uri, annotation);

            if (FBTrace.DBG_ACTIVATION || FBTrace.DBG_ANNOTATION)
                FBTrace.sysout("setPageAnnotation with activeSameOrigin currentURI "+
                    currentURI.spec+" becomes URI key "+(uri?uri.spec:"ERROR"));
        }
    },

    removePageAnnotation: function(currentURI)
    {
        var uri = this.convertToURIKey(currentURI, Firebug.activateSameOrigin);
        if (uri)
            this.getAnnotationService().removePageAnnotation(uri);

        if (Firebug.activateSameOrigin)
        {
            uri = this.convertToURIKey(currentURI, false);
            if (uri)
                this.getAnnotationService().removePageAnnotation(uri);
        }

        if (FBTrace.DBG_ACTIVATION)
            FBTrace.sysout("Firebug.Activation.unwatchBrowser untagged "+uri.spec);
    },

    iterateAnnotations: function(fn)  // stops at the first fn(uri) that returns a true value
    {
        var annotations = this.getAnnotationService().getAnnotations(this.annotationName);
        for (var uri in annotations)
        {
            var rc = fn(uri, annotations[uri]);
            if (rc)
                return rc;
        }
    },

    toggleAll: function(state)
    {
        if (FBTrace.DBG_ACTIVATION)
            FBTrace.sysout("Firebug.toggleAll("+state+") with allPagesActivation: " +
                Firebug.allPagesActivation);

        if (state == "on")
        {
            if (Firebug.allPagesActivation == state) // then we were armed
                Firebug.allPagesActivation = "none";
            else
                this.allOn();
        }
        else
        {
            Firebug.allPagesActivation = "none";
        }

        Firebug.setPref(Firebug.prefDomain, "allPagesActivation", Firebug.allPagesActivation);
        this.updateAllPagesActivation();
    },

    updateOption: function(name, value)
    {
        if (name = "allPagesActivation")
            this.updateAllPagesActivation();
    },

    updateAllPagesActivation: function()
    {
        var allOn = Firebug.allPagesActivation == "on";

        var menu = $('menu_AllOn');
        if (menu)
            menu.setAttribute("checked", allOn);

        // don't show Off button if we are always on
        Firebug.chrome.disableOff(allOn);
    },

    allOn: function()
    {
        Firebug.allPagesActivation = "on";  // In future we always create contexts,
        Firebug.toggleBar(true);  // and we turn on for the current page
    }
});

// ************************************************************************************************

Firebug.Activation.TabWatcherListener =
{
    watchBrowser: function(browser)
    {
        Firebug.Activation.watchBrowser(browser);
    },

    unwatchBrowser: function(browser, userCommands)
    {
        Firebug.Activation.unwatchBrowser(browser, userCommands);
    }
};

// ************************************************************************************************

/**
 * @module Implements Panel activation logic. A Firebug panel can support activation in order
 * to avoid performance penalties in cases when panel's features are not necessary at the moment.
 * Such panel must be derived from {@link Firebug.ActivablePanel} and appropriate activable
 * module from {@link Firebug.ActivableModule}
 */
Firebug.PanelActivation = extend(Firebug.Module,
/** @lends Firebug.PanelActivation */
{
    initialize: function()
    {
        prefs.addObserver(Firebug.prefDomain, this, false);
    },

    shutdown: function()
    {
        prefs.removeObserver(Firebug.prefDomain, this, false);
    },

    showPanel: function(browser, panel)
    {
        if (FBTrace.DBG_ACTIVATION)
            FBTrace.sysout("PanelActivation.showPanel; " + (panel ? panel.name : "null panel"));

        // Panel toolbar is not displayed for disabled panels.
        var chrome = Firebug.chrome;
        collapse(chrome.$("fbToolbar"), !panel);
    },

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    activatePanelTypes: function(panelTypes)
    {
        for (var p in panelTypes)
        {
            var panelType = panelTypes[p];
            if (!this.isPanelActivable(panelType))
                continue;

            if (this.isPanelEnabled(panelType))
                panelType.prototype.onActivationChanged(true);
        }
    },

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    isPanelActivable: function(panelType)
    {
        return panelType.prototype.activable ? true : false;
    },

    isPanelEnabled: function(panelType)
    {
        if (!this.isPanelActivable(panelType))
            return true;

        // Panel "class" object is used to decide whether a panel is disabled
        // or not (i.e.: isEnabled is a static method of Firebug.Panel)
        return panelType ? panelType.prototype.isEnabled() : false;
    },

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    // Enable & disable methods.

    enablePanel: function(panelType)
    {
        this.setPanelState(panelType, true);
    },

    disablePanel: function(panelType)
    {
        this.setPanelState(panelType, false);
    },

    enableAllPanels: function()
    {
        for (var i = 0; i < Firebug.panelTypes.length; ++i)
        {
            var panelType = Firebug.panelTypes[i];
            this.setPanelState(panelType, true);
        }
    },

    disableAllPanels: function()
    {
        for (var i = 0; i < Firebug.panelTypes.length; ++i)
        {
            var panelType = Firebug.panelTypes[i];
            this.setPanelState(panelType, false);
        }
    },

    setPanelState: function(panelType, enable)
    {
        if (panelType && panelType.prototype.setEnabled)
            panelType.prototype.setEnabled(enable);

        this.updateTab(panelType);
    },

    updateTab: function(panelType)
    {
        var panelName = panelType.prototype.name;
        var panelBar = Firebug.chrome.$("fbPanelBar1");
        var tab = panelBar.updateTab(panelType);
    },

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    // Observer activation changes (preference)

    /**
     * Observer for activation preferences changes.
     */
    observe: function(subject, topic, data)
    {
        if (topic != "nsPref:changed")
            return;

        if (data.indexOf(".enableSites") == -1)
            return;

        var parts = data.split(".");
        if (parts.length != 4)
            return;

        try
        {
            var panelName = parts[2];
            var enable = Firebug.getPref(Firebug.prefDomain, panelName + ".enableSites");

            var panelType = Firebug.getPanelType(panelName, enable);
            if (panelType)
                this.onActivationChanged(panelType, enable);
        }
        catch (e)
        {
            if (FBTrace.DBG_ACTIVATION || FBTrace.DBG_ERRORS)
                FBTrace.sysout("PanelActivation.observe; EXCEPTION " + e, e);
        }
    },

    onActivationChanged: function(panelType, enable)
    {
        if (!enable)
        {
            // Iterate all contexts and destroy all instances of the specified panel.
            var self = this;
            Firebug.TabWatcher.iterateContexts(function(context) {
                context.destroyPanel(panelType, context.persistedState);
            });
        }

        panelType.prototype.onActivationChanged(enable);

        Firebug.chrome.syncPanel();
    },
});

// ************************************************************************************************

/**
 * @domplate This template renders default content for disabled panels.
 */
Firebug.DisabledPanelBox = domplate(Firebug.Rep,
/** @lends Firebug.DisabledPanelBox */
{
    tag:
        DIV({"class": "disabledPanelBox"},
            H1({"class": "disabledPanelHead"},
                SPAN("$pageTitle")
            ),
            P({"class": "disabledPanelDescription", style: "margin-top: 15px;"},
                $STR("moduleManager.desc3"),
                SPAN("&nbsp;"),
                SPAN({"class": "descImage descImage-$panelName"})
            ),
            A({"class": "objectLink", onclick: "$onEnable"},
                $STR("moduleManager.Enable")
            )
            /* need something here that pushes down any thing appended to the panel */
        ),

    onEnable: function(event)
    {
        var panelBar = Firebug.chrome.$("fbPanelBar1");
        var panelType = panelBar.selectedTab.panelType;
        panelType.prototype.setEnabled(true);
        panelBar.updateTab(panelType);
    },

    /**
     * Show default content saying that this panel type (specified by name) is disabled.
     * The parent node is specified in panel.html file.
     */
    show: function(browser, panelName)
    {
        if (!panelName)
            return;

        var panel = Firebug.getPanelType(panelName);
        var panelTitle = Firebug.getPanelTitle(panel);
        var args = {
            pageTitle: $STRF("moduleManager.title", [panelTitle]),
            panelName: panelName
        };

        var parentNode = this.getParentNode(browser);
        this.tag.replace(args, parentNode, this);
        parentNode.removeAttribute("collapsed");
    },

    /**
     * Hide currently displayed default content.
     */
    hide: function(browser)
    {
        var parentNode = this.getParentNode(browser);
        clearNode(parentNode);
        parentNode.setAttribute("collapsed", true);
    },

    getParentNode: function(browser)
    {
        var doc = browser.contentDocument;
        return doc.documentElement.querySelector(".disabledPanelNode");
    },
});

// ************************************************************************************************

Firebug.registerModule(Firebug.Activation);
Firebug.registerModule(Firebug.PanelActivation);

// ************************************************************************************************
return Firebug.Activation;
}});
