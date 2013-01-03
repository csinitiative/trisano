/* See license.txt for terms of usage */

// ************************************************************************************************
// Globals

var item;
var FBL;
var internalFilefieldTextbox;
var browseButton;
// browsing for a new file modifies image and label only if they are autogenereted from filename
var origLabel = '';
var origImage = null;

function onLoad()
{
    var args = window.arguments[0];
    item = args.item;
    FBL = args.FBL;

    browseButton = document.getElementById("browse-button");

    document.getElementById("name").value = item.label;
    if (item.executable)
    {
        origImage = FBL.getIconURLForFile(item.executable);
        try
        {
            var file = fbXPCOMUtils.CCIN("@mozilla.org/file/local;1", "nsILocalFile");
            file.initWithPath(item.executable);
            document.getElementById("executable").file = file;
            origLabel = file.leafName.replace(".exe","");
        }
        catch(exc) {}
    }

    if (item.cmdline)
        document.getElementById("cmdline").value = item.cmdline;

    onChange();

    // Localization
    internationalizeUI(document);

    window.sizeToContent();

    if (document.getAnonymousElementByAttribute && !document.getElementById("executable").file)
    {
        setTimeout(function()
        {
            internalFilefieldTextbox = document.getAnonymousElementByAttribute(
                document.getElementById("executable"), "class", "fileFieldLabel");

            if (internalFilefieldTextbox)
            {
                internalFilefieldTextbox.readOnly = false;
                internalFilefieldTextbox.addEventListener("input", function(e) {
                    browseButton.disabled = (this.value != "");
                    onChange();
                }, false);
            }
        }, 100);
    }
}

function internationalizeUI(doc)
{
    var elements = doc.getElementsByClassName("fbInternational");
    var attributes = ["title", "label", "value"];
    for (var i=0; i<elements.length; i++)
    {
        if (elements[i].nodeName == "description")
        {
            var localized = FBL.$STR(elements[i].textContent);
            var parser = fbXPCOMUtils.CCIN("@mozilla.org/xmlextras/domparser;1", "nsIDOMParser");
            var doc = parser.parseFromString("<vbox>" + localized + "</vbox>", "text/xml");
            var root = doc.documentElement;

            while(elements[i].firstChild)
                elements[i].removeChild(elements[i].firstChild);

            for(var j=0; j<root.childNodes.length; j++)
            {
                // ToDo: Show labels correctly
                // Namespaces are not inherited from doc, so labels 
                // are not shown as links
                node = doc.importNode(root.childNodes[j], true);
                elements[i].appendChild(node);
            }
        }
        else
        {
            for(var j=0; j<attributes.length; j++)
            {
                if (elements[i].hasAttribute(attributes[j]))
                    FBL.internationalize(elements[i], attributes[j]);
            }
        }
    }
}

function onAccept()
{
    item.label = document.getElementById("name").value;
    if (!browseButton.disabled)
    {
        var file = document.getElementById("executable").file;
        item.executable = "";
        if (file)
            item.executable = file.path;
    }
    else
    {
        item.executable = internalFilefieldTextbox.value.replace(/^\s+|\s+$/g, '');
    }

    item.cmdline = document.getElementById("cmdline").value;
    if (item.image == origImage)
        item.image = FBL.getIconURLForFile(item.executable);

    try
    {
        var file = fbXPCOMUtils.CCIN("@mozilla.org/file/local;1", "nsILocalFile");
        file.initWithPath(item.executable);
        if (!file.isExecutable())
           throw "NotAnExecutable";

        window.arguments[1].saveChanges = true;
        return true;
    }
    catch (exc)
    {
        const Ci = Components.interfaces;
        const nsIPromptService = nsIPromptService;
        var promptService = fbXPCOMUtils.CCIN("@mozilla.org/embedcomp/prompt-service;1",
            "nsIPromptService");

        if (exc == "NotAnExecutable")
        {
            promptService.alert(null, FBL.$STR("changeEditor.Invalid_Application_Path"),
                FBL.$STR("changeEditor.Path_is_not_an_executable"));
        }
        else
        {
            promptService.alert(null, FBL.$STR("changeEditor.Invalid_Application_Path"),
                FBL.$STR("changeEditor.Application_does_not_exist"));
        }

        return false;
    }
}

function onChange()
{
    document.documentElement.getButton("accept").disabled = !(
        document.getElementById("name").value && (
            (browseButton.disabled && internalFilefieldTextbox &&
                internalFilefieldTextbox.value &&
                internalFilefieldTextbox.value.replace(/^\s+|\s+$/g, '')) ||
            (!browseButton.disabled && document.getElementById("executable").file)
        )
    );
}

function onBrowse()
{
    const Ci = Components.interfaces;
    const nsIFilePicker = Ci.nsIFilePicker;
    var picker = fbXPCOMUtils.CCIN("@mozilla.org/filepicker;1", "nsIFilePicker");
    picker.init(window, "", nsIFilePicker.modeOpen);
    picker.appendFilters(nsIFilePicker.filterApps);

    if (picker.show() == nsIFilePicker.returnOK && picker.file)
    {
        var nameField = document.getElementById("name");
        var execField = document.getElementById("executable");
        execField.file = picker.file;

        if (internalFilefieldTextbox)
            internalFilefieldTextbox.readOnly = true;

        if (nameField.value == origLabel || nameField.value == "")
            origLabel = nameField.value = execField.file.leafName.replace(".exe","");

        onChange();
        return true;
    }

    return false;
}

function insertText(text, whole)
{
    var textbox = document.getElementById("cmdline")
    if(whole)
        textbox.select();

    textbox.editor.QueryInterface(Components.interfaces.nsIPlaintextEditor).insertText(text);
    textbox.focus()
}

// ************************************************************************************************

// would be good to have autosuggest for popular editors
var defaultCommandLines =
{
    "sublimetext": "%file:%line",
    "notepad++":   "-n%line %file",
    "emeditor":    "/l %line %file",
    "browser":     "%url",
    "explorer":    "/select,%file"
}

function suggestionPopupShowing(popup)
{
    FBL.eraseNode(popup);

    for (var i in defaultCommandLines)
    {
        var box = document.createElement('hbox');
        var label = document.createElement('label');
        label.setAttribute('value', i + ': ');
        box.appendChild(label);

        var spacer = document.createElement('spacer');
        spacer.setAttribute('flex', 1);
        box.appendChild(spacer);

        label = document.createElement('label');
        label.setAttribute('value', defaultCommandLines[i]);
        label.className = 'text-link'
        box.appendChild(label);

        popup.appendChild(box)
    }
}

// ************************************************************************************************
