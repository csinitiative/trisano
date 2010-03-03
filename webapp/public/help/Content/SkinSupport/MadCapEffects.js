// {{MadCap}} //////////////////////////////////////////////////////////////////
// Copyright: MadCap Software, Inc - www.madcapsoftware.com ////////////////////
////////////////////////////////////////////////////////////////////////////////
// <version>4.2.0.0</version>
////////////////////////////////////////////////////////////////////////////////

var gPopupObj           = null;
var gPopupBGObj         = null;
var gJustPopped         = false;

var gFadeID             = 0;

var gTextPopupBody      = null;
var gTextPopupBodyBG    = null;

var gImgNode            = null;

function FMCImageSwap( img, swapType )
{
	var state	= FMCGetMCAttribute( img, "MadCap:state" );
	
    switch ( swapType )
    {
        case "swap":
            var src		= img.src;
            var altsrc2	= FMCGetMCAttribute( img, "MadCap:altsrc2" );
            
            if ( !altsrc2 )
            {
				altsrc2 = FMCGetMCAttribute( img, "MadCap:altsrc" );
            }
            
            img.src = altsrc2;
            img.setAttribute( "MadCap:altsrc2", src );
            img.setAttribute( "MadCap:state", (state == null || state == "close") ? "open" : "close" );
            
            break;
            
        case "open":
            if ( state != swapType )
            {
                FMCImageSwap( img, "swap" );
            }
            
            break;
            
        case "close":
            if ( state == "open" )
            {
                FMCImageSwap( img, "swap" );
            }
            
            break;
    }
}

function FMCExpandAll( swapType )
{
    var nodes   = FMCGetElementsByAttribute( document.body, "MadCap:targetName", "*" );
    
    for ( var i = 0; i < nodes.length; i++ )
    {
        nodes[i].style.display = (swapType == "open") ? "" : "none";
    }
    
    nodes = FMCGetElementsByClassRoot( document.body, "MCTogglerIcon" );
    
    for ( var i = 0; i < nodes.length; i++ )
    {
        FMCImageSwap( nodes[i], swapType );
    }
    
    nodes = FMCGetElementsByClassRoot( document.body, "MCExpandingBody" );
    
    for ( var i = 0; i < nodes.length; i++ )
    {
        nodes[i].style.display = (swapType == "open") ? "" : "none";
    }
    
    nodes = FMCGetElementsByClassRoot( document.body, "MCExpandingIcon" );
    
    for ( var i = 0; i < nodes.length; i++ )
    {
        FMCImageSwap( nodes[i], swapType );
    }
    
    nodes = FMCGetElementsByClassRoot( document.body, "MCDropDownBody" );
    
    for ( var i = 0; i < nodes.length; i++ )
    {
        nodes[i].style.display = (swapType == "open") ? "" : "none";
    }
    
    nodes = FMCGetElementsByClassRoot( document.body, "MCDropDownIcon" );
    
    for ( var i = 0; i < nodes.length; i++ )
    {
        FMCImageSwap( nodes[i], swapType );
    }
}

function FMCDropDown( node )
{
    // Find head node
    
    var headNode    = node;
    
    while ( !FMCContainsClassRoot( headNode.className, "MCDropDown", "GlossaryPageEntry" ) )
    {
        headNode = headNode.parentNode;
    }
    
    // Toggle the icon
    
    var imgNodes    = node.getElementsByTagName( "img" );
    
    for ( var i = 0; i < imgNodes.length; i++ )
    {
        var imgNode = imgNodes[i];
        
        if ( FMCContainsClassRoot( imgNode.className, "MCDropDownIcon" ) )
        {
            FMCImageSwap( imgNode, "swap" );
            
            break;
        }
    }
    
    // Hide/unhide the body
    
    var id              = node.id.substring( "MCDropDownHotSpot_".length, node.id.length );
    var dropDownBody    = document.getElementById( "MCDropDownBody_" + id );
    
    dropDownBody.style.display = (dropDownBody.style.display == "none") ? "" : "none";
}

function FMCExpand( node )
{
    // Find top node
    
    while ( !FMCContainsClassRoot( node.className, "MCExpanding" ) )
    {
        node = node.parentNode;
    }
    
    var nodes       = node.childNodes;
    var imgNodes    = node.getElementsByTagName( "img" );
    
    // Toggle the icon
    
    for ( var i = 0; i < imgNodes.length; i++ )
    {
        var imgNode = imgNodes[i];
        
        if ( FMCContainsClassRoot( imgNode.className, "MCExpandingIcon" ) )
        {
            FMCImageSwap( imgNode, "swap" );
            
            break;
        }
    }
    
    // Hide/unhide the body
    
    var expandingBody;
    
    for ( i = 0; i < nodes.length; i++ )
    {
        var node = nodes[i];
        
        if ( FMCContainsClassRoot( node.className, "MCExpandingBody" ) )
        {
            expandingBody = node;
            break;
        }
    }
    
    expandingBody.style.display = (expandingBody.style.display == "none") ? "" : "none";
}

var gPopupNumber	= 0;

function FMCPopup( e, node )
{
	// Don't continue if something is already popped up

	if ( gPopupObj )
	{
		return;
	}

	if ( !e )
	{
		e = window.event;
	}

	if ( FMCInPreviewMode() && document.documentElement.innerHTML.indexOf( "<!-- saved from url" ) != -1 )
	{
		var span	= document.getElementById( "MCTopicPopupWarning" );
		
		if ( !span )
		{
			span = document.createElement( "span" );
			span.id = "MCTopicPopupWarning";
			span.className = "MCTextPopupBody";
			span.style.display = "none";
			span.appendChild( document.createTextNode( "Topic popups can not be displayed when Insert Mark of the Web is enabled in the target." ) );
			
			document.body.appendChild( span );
		}
		
		gTextPopupBody = span;
		
		FMCShowTextPopup( e );
		
		return;
	}

	// Toggle the icon

	var imgNodes    = node.getElementsByTagName( "img" );

	for ( var i = 0; i < imgNodes.length; i++ )
	{
		var imgNode = imgNodes[i];
	    
		if ( FMCContainsClassRoot( imgNode.className, "MCExpandingIcon" ) )
		{
			FMCImageSwap( imgNode, "swap" );
			gImgNode = imgNode;
	        
			break;
		}
	}

	// Create iframe node

	var name			= FMCGetAttribute( node, "MadCap:iframeName" );
	var iframeExists	= name != null;
	var iframe			= null;
	
	if ( iframeExists )
	{
		iframe = document.getElementById( name );
	}
	else
	{
		var src		= FMCGetAttribute( node, "MadCap:src" );
		var path	= null;

		if ( src.StartsWith( "http" ) || FMCInPreviewMode() )
		{
			path = src;
		}
		else
		{
			var currentUrl	= document.location.href;
			
			path = currentUrl.substring( 0, currentUrl.lastIndexOf( "/" ) + 1 )
			path = path + src;
		}

		try
		{
			// For IE
			
			iframe = document.createElement( "<iframe onload='FMCIFrameOnloadInline( this );'>" );
		}
		catch ( ex )
		{
			// For non-IE
			
			iframe = document.createElement( "iframe" );
			iframe.onload = FMCIFrameOnload;
		}

		var name	= "MCPopup_" + (gPopupNumber++);
		
		node.setAttribute( "MadCap:iframeName", name );
		
		iframe.name = name;
		iframe.id = name;
		iframe.className = "MCPopupBody";
		iframe.setAttribute( "title", "Popup" );
		iframe.setAttribute( "scrolling", "auto" );
		iframe.setAttribute( "frameBorder", "0" );

		var width	= FMCGetAttribute( node, "MadCap:width" );
		var height	= FMCGetAttribute( node, "MadCap:height" );
		iframe.setAttribute( "MadCap:width", width );
		iframe.setAttribute( "MadCap:height", height );

		document.body.appendChild( iframe );
		
		iframe.src = path;
	}
	
	iframe.style.display = "none";
	
	//
	
	gJustPopped = true;
		
	iframe.MCClientX = e.clientX;
	iframe.MCClientY = e.clientY;
	
	if ( iframeExists )
	{
		FMCShowIFrame( iframe );
	}
}

function FMCIFrameOnload( e )
{
	// Safari will fire the onload event twice. Once for creating the iframe (about:blank). The second time for setting the src of the iframe.

	if ( this.contentWindow.document.location.href == "about:blank" )
	{
		return;
	}

	// Navigating to a link in the popup will fire onload again.

	if ( FMCGetAttributeBool( this, "MadCap:loaded", false ) )
	{
		return;
	}

	FMCShowIFrame( this );

	this.setAttribute( "MadCap:loaded", "true" );
}

function FMCIFrameOnloadInline( popupBody )
{
	// Navigating to a link in the popup will fire onload again.
	
	if ( FMCGetAttributeBool( popupBody, "MadCap:loaded", false ) )
	{
		return;
	}
	
	FMCShowIFrame( popupBody );
	
	popupBody.setAttribute( "MadCap:loaded", "true" );
}

function FMCShowIFrame( popupBody )
{
	try
	{
		// Access denied on document when linking to external website
		
		if ( popupBody.contentWindow.document.location.href == "about:blank" )
		{
			return;
		}
	}
	catch ( ex )
	{
	}
	
	popupBody.style.display = "";
	FMCSetPopupSize( popupBody );
	
	var clientX				= popupBody.MCClientX;
	var clientY				= popupBody.MCClientY;
	var absolutePosition	= FMCGetPosition( popupBody.offsetParent );
	var absoluteTop			= absolutePosition[0];
	var absoluteLeft		= absolutePosition[1];
	var newTop				= 0;
	var newLeft				= 0;
    
    // "+ 5" is to account for width of popup shadow.
    
    if ( clientY + parseInt( popupBody.style.height ) + 5 > FMCGetClientHeight( window, false ) )
    {
        newTop = FMCGetScrollTop( window ) + FMCGetClientHeight( window, false ) - parseInt( popupBody.style.height ) - 5;
    }
    else
    {
        newTop = clientY + FMCGetScrollTop( window );
    }
    
    newTop -= absoluteTop;
    popupBody.style.top = newTop + "px";
    
    if ( clientX + parseInt( popupBody.style.width ) + 5 > FMCGetClientWidth( window, false ) )
    {
        newLeft = FMCGetScrollLeft( window ) + FMCGetClientWidth( window, false ) - parseInt( popupBody.style.width ) - 5;
    }
    else
    {
        newLeft = clientX + FMCGetScrollLeft( window );
    }
    
    newLeft -= absoluteLeft;
    popupBody.style.left = newLeft + "px";
    
    // Set up background
    
    var popupBodyBG = document.createElement( "span" );
    
    popupBodyBG.className = "MCPopupBodyBG";
    popupBodyBG.style.top = newTop + 5 + "px";
    popupBodyBG.style.left = newLeft + 5 + "px";
    popupBodyBG.style.width = parseInt( popupBody.offsetWidth ) + "px";
    popupBodyBG.style.height = parseInt( popupBody.offsetHeight ) + "px";
    
    popupBody.parentNode.appendChild( popupBodyBG );
    gPopupObj = popupBody;
    gPopupBGObj = popupBodyBG;
    
    //
    
    gFadeID = setInterval( FMCFade, 10 );
}

function FMCSetPopupSize( popupNode )
{
	var popupWidth	= FMCGetAttribute( popupNode, "MadCap:width" );
	var popupHeight	= FMCGetAttribute( popupNode, "MadCap:height" );
	
	if ( (popupWidth != "auto" && !String.IsNullOrEmpty( popupWidth )) || (popupHeight != "auto" && !String.IsNullOrEmpty( popupHeight )) )
	{
		popupNode.style.width = popupWidth;
		popupNode.style.height = popupHeight;
		
		return;
	}
	
	//
	
    var clientWidth     = FMCGetClientWidth( window, false );
    var clientHeight    = FMCGetClientHeight( window, false );
    var stepSize        = 10;
    var hwRatio         = clientHeight / clientWidth;
    var popupFrame      = frames[popupNode.name];
    var maxX            = clientWidth * 0.618034;
    var i               = 0;
    
    // Debug
    //window.status += document.body.clientHeight + ", " + document.body.offsetHeight + ", " + document.body.scrollHeight + ", " + document.body.scrollTop;
    //window.status += " : " + document.documentElement.clientHeight + ", " + document.documentElement.offsetHeight + ", " + document.documentElement.scrollHeight + ", " + document.documentElement.scrollTop;
    
    // Safari
    
    if ( FMCIsSafari() )
    {
        popupNode.style.width = maxX + "px";
        popupNode.style.height = (maxX * hwRatio) + "px";
        
        return;
    }
    
    //
    
    try
    {
        var popupDocument   = popupFrame.document; // This will throw an exception in IE.
        
        FMCGetScrollHeight( popupFrame.window );   // This will throw an exception in Mozilla.
    }
    catch ( err )
    {
        popupNode.style.width = maxX + "px";
        popupNode.style.height = (maxX * hwRatio) + "px";
        
        return;
    }
    
    while ( true )
    {
        popupNode.style.width = maxX - (i * stepSize) + "px";
        popupNode.style.height = (maxX - (i * stepSize)) * hwRatio + "px";
        
        if ( FMCGetScrollHeight( popupFrame.window ) > FMCGetClientHeight( popupFrame.window, false ) ||
             FMCGetScrollWidth( popupFrame.window ) > FMCGetClientWidth( popupFrame.window, false ) )
        {
            popupNode.style.width = maxX - ((i - 1) * stepSize) + "px";
            popupNode.style.height = (maxX - ((i - 1) * stepSize)) * hwRatio + "px";
            
            break;
        }
        
        i++;
    }
}

function GetHelpControlLinks( node, callbackFunc, callbackArgs )
{
	var linkMap			= new Array();
	var inPreviewMode	= FMCInPreviewMode();
	var rootFrame		= FMCGetRootFrame();

	if ( !inPreviewMode && rootFrame.gHelpSystem.IsMerged() && FMCGetMCAttribute( node, "MadCap:indexKeywords" ) != null )
	{
		function OnInit()
		{
			var indexKeywords   = FMCGetMCAttribute( node, "MadCap:indexKeywords" ).replace( "\\;", "%%%%%" );
		    
			if ( indexKeywords == "" )
			{
				callbackFunc( linkMap, callbackArgs );
			}
		    
			var keywords        = indexKeywords.split( ";" );
		    
			for ( var i = 0; i < keywords.length; i++ )
			{
				keywords[i] = keywords[i].replace( "%%%%%", ";" );
		        
				var currKeyword = keywords[i].replace( "\\:", "%%%%%" );
				var keywordPath = currKeyword.split( ":" );
				var level       = keywordPath.length - 1;
				var indexKey    = level + "_" + keywordPath[level].replace( "%%%%%", ":" );
		        
				var currLinkMap = indexFrame.gLinkMap.GetItem( indexKey.toLowerCase() );
		        
				// currLinkMap may be blank if keywords[i] isn't found in index XML file (user may have deleted keyword after associating it with a K-Link)
		        
				if ( currLinkMap )
				{
					currLinkMap.ForEach( function( key, value )
					{
						linkMap[linkMap.length] = key + "|" + value;
						
						return true;
					} );
				}
			}

			callbackFunc( linkMap, callbackArgs );
		}

		var indexFrame  = rootFrame.frames["navigation"].frames["index"];
	    
		indexFrame.Init( OnInit );

		return;
	}
	else if ( !inPreviewMode && rootFrame.gHelpSystem.IsMerged() && FMCGetMCAttribute( node, "MadCap:concepts" ) != null )
	{
		var concepts	= FMCGetMCAttribute( node, "MadCap:concepts" );
		var args		= { callbackFunc: callbackFunc, callbackArgs: callbackArgs };
		
		rootFrame.gHelpSystem.GetConceptsLinks( concepts, OnGetConceptsLinks, args );
		
		return;
	}
	else if ( FMCGetMCAttribute( node, "MadCap:topics" ) != null )
	{
		var topics  = FMCGetMCAttribute( node, "MadCap:topics" ).split( "||" );
	    
		if ( topics == "" )
		{
			callbackFunc( linkMap, callbackArgs );
		}
	    
		for ( var i = 0; i < topics.length; i++ )
		{
			linkMap[linkMap.length] = topics[i];
		}
	}

	callbackFunc( linkMap, callbackArgs );
}

function OnGetConceptsLinks( links, args )
{
	var callbackFunc	= args.callbackFunc;
	var callbackArgs	= args.callbackArgs;
	
	callbackFunc( links, callbackArgs );
}

function FMCTextPopup( e, node )
{
    // Don't continue if something is already popped up
    
    if ( gPopupObj )
    {
        return;
    }
    
    if ( !e )
    {
        e = window.event;
    }
    
    // Find top node
    
    while ( !FMCContainsClassRoot( node.className, "MCTextPopup" ) )
    {
        node = node.parentNode;
    }
    
    // Toggle the icon
    
    var imgNodes    = node.getElementsByTagName( "img" );
    
    for ( var i = 0; i < imgNodes.length; i++ )
    {
        var imgNode = imgNodes[i];
        
        if ( FMCContainsClassRoot( imgNode.className, "MCExpandingIcon" ) )
        {
            FMCImageSwap( imgNode, "swap" );
            gImgNode = imgNode;
            
            break;
        }
    }
    
    // Hide/unhide the body
    
    var nodes   = node.childNodes;
    
    for ( i = 0; i < nodes.length; i++ )
    {
        var node = nodes[i];
        
        if ( FMCContainsClassRoot( node.className, "MCTextPopupBody" ) )
        {
            gTextPopupBody = node;
            break;
        }
    }
    
    FMCShowTextPopup( e );
}

function FMCShowTextPopup( e )
{
    if ( gTextPopupBody.style.display == "none" )
    {
        if ( gTextPopupBody.childNodes.length == 0 )
        {
            gTextPopupBody.appendChild( document.createTextNode( "(No data to display)") );
        }
        
        gTextPopupBody.style.display = "";
        
        FMCSetTextPopupSize( gTextPopupBody );
        
        // "+ 5" is to account for width of popup shadow.
        
        if ( FMCGetClientY( window, e ) + gTextPopupBody.offsetHeight + 5 > FMCGetClientHeight( window, false ) )
        {
            gTextPopupBody.style.top = FMCGetScrollTop( window ) + FMCGetClientHeight( window, false ) - gTextPopupBody.offsetHeight - 5 + "px";
        }
        else
        {
            gTextPopupBody.style.top = FMCGetPageY( window, e ) + "px";
        }
        
        if ( FMCGetClientX( window, e ) + gTextPopupBody.offsetWidth + 5 > FMCGetClientWidth( window, false ) )
        {
            gTextPopupBody.style.left = FMCGetScrollLeft( window ) + FMCGetClientWidth( window, false ) - gTextPopupBody.offsetWidth - 5 + "px";
        }
        else
        {
            gTextPopupBody.style.left = FMCGetPageX( window, e ) + "px";
        }
        
        // Set up background
        
        gTextPopupBodyBG = document.createElement( "span" );
        gTextPopupBodyBG.className = "MCTextPopupBodyBG";
        gTextPopupBodyBG.style.top = parseInt( gTextPopupBody.style.top ) + 5 + "px";
        gTextPopupBodyBG.style.left = parseInt( gTextPopupBody.style.left ) + 5 + "px";
        
        FMCSetTextPopupDimensions();
        
        gTextPopupBody.parentNode.appendChild( gTextPopupBodyBG );
        window.onresize = FMCSetTextPopupDimensions;
        gPopupObj = gTextPopupBody;
        gPopupBGObj = gTextPopupBodyBG;
        gJustPopped = true;
        
        //
        
        gFadeID = setInterval( FMCFade, 10 );
    }
}

function FMCSetTextPopupSize( popupNode )
{
    var clientWidth     = FMCGetClientWidth( window, false );
    var clientHeight    = FMCGetClientHeight( window, false );
    var stepSize        = 10;
    var hwRatio         = clientHeight / clientWidth;
    var maxX            = clientWidth * 0.618034;
    var i               = 0;
    
    while ( true )
    {
        popupNode.style.width = maxX - (i * stepSize) + "px";
        popupNode.style.height = (maxX - (i * stepSize)) * hwRatio + "px";
        
        // "- 2" is to account for borderLeft + borderRight.
        
        if ( popupNode.scrollHeight > popupNode.offsetHeight - 2 || popupNode.scrollWidth > popupNode.offsetWidth - 2 )
        {
            popupNode.style.overflow = "hidden";    // Since scrollbars are now present, remove them before enlarging the node or else they'll still be present in Firefox and Safari
            
            popupNode.style.width = maxX - ((i - 1) * stepSize) + "px";
            popupNode.style.height = (maxX - ((i - 1) * stepSize)) * hwRatio + "px";
            
            break;
        }
        
        i++;
    }
    
    // Debug
    //window.status = popupNode.offsetWidth + ", " + popupNode.scrollWidth + ", " + popupNode.offsetHeight + ", " + popupNode.scrollHeight;
}

function FMCToggler( node )
{
    // Don't continue if something is already popped up
    
    if ( gPopupObj )
    {
        return;
    }
    
    // Toggle the icon
    
    var imgNodes    = node.getElementsByTagName( "img" );
    
    for ( var i = 0; i < imgNodes.length; i++ )
    {
        var imgNode = imgNodes[i];
        
        if ( FMCContainsClassRoot( imgNode.className, "MCTogglerIcon" ) )
        {
            FMCImageSwap( imgNode, "swap" );
            
            break;
        }
    }
    
    // Toggle all toggler items
    
    var targets = FMCGetMCAttribute( node, "MadCap:targets" ).split( ";" );
    
    for ( var i = 0; i < targets.length; i++ )
    {
        var nodes   = FMCGetElementsByAttribute( document.body, "MadCap:targetName", targets[i] );
        
        for ( var j = 0; j < nodes.length; j++ )
        {
			if ( nodes[j].style.display == "none" )
			{
				nodes[j].style.display = "";
				
				FMCUnhide( window, nodes[j] );
			}
			else
			{
				nodes[j].style.display = "none";
			}
        }
    }
}

function FMCSetTextPopupDimensions()
{
    gTextPopupBodyBG.style.width = gTextPopupBody.offsetWidth + "px";
    gTextPopupBodyBG.style.height = gTextPopupBody.offsetHeight + "px";
}

function FMCFade()
{
    var finished    = false;
    
    if ( gPopupObj.filters )
    {
        var opacity	= gPopupObj.style.filter;
        
        if ( opacity == "" )
        {
			opacity = "alpha( opacity = 0 )";
        }
        
        gPopupObj.style.filter = "alpha( opacity = " + (parseInt( opacity.substring( 17, opacity.length - 2 ) ) + 10) + " )";
        
        if ( gPopupBGObj )
        {
			opacity = gPopupBGObj.style.filter;
			
			if ( opacity == "" )
			{
				opacity = "alpha( opacity = 0 )";
			}
			
			gPopupBGObj.style.filter = "alpha( opacity = " + (parseInt( opacity.substring( 17, opacity.length - 2 ) ) + 5) + " )";
        }
        
        if ( gPopupObj.style.filter == "alpha( opacity = 100 )" )
        {
            finished = true;
        }
    }
    else if ( gPopupObj.style.MozOpacity != null )
    {
		var opacity	= gPopupObj.style.MozOpacity;
		
		if ( opacity == "" )
		{
			opacity = "0.0";
		}
		
        gPopupObj.style.MozOpacity = parseFloat( opacity ) + 0.11;
        
        if ( gPopupBGObj )
        {
			opacity = gPopupBGObj.style.MozOpacity;
			
			if ( opacity == "" )
			{
				opacity = "0.0";
			}
			
			gPopupBGObj.style.MozOpacity = parseFloat( opacity ) + 0.05;
		}
        
        if ( parseFloat( gPopupObj.style.MozOpacity ) == 0.99 )
        {
            finished = true;
        }
    }
    
    if ( finished )
    {
        clearInterval( gFadeID );
        gFadeID = 0;
    }
}
