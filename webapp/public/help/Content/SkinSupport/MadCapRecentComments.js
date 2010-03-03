/// <reference path="MadCapUtilities.js" />

// {{MadCap}} //////////////////////////////////////////////////////////////////
// Copyright: MadCap Software, Inc - www.madcapsoftware.com ////////////////////
////////////////////////////////////////////////////////////////////////////////
// <version>4.2.0.0</version>
////////////////////////////////////////////////////////////////////////////////

var gInit	= false;

gOnloadFuncs.push( WindowOnload );

function WindowOnload()
{
	if ( MCGlobals.NavigationFrame != null )
	{
		WaitForPaneActive();
	}
	else
	{
		Init( null );
	}
}

function WaitForPaneActive()
{
	if ( MCGlobals.NavigationFrame.gActivePane == window.name )
	{
		MCGlobals.NavigationFrame.SetIFrameHeight();
		
		Init( null );
	}
	else
	{
		window.setTimeout( WaitForPaneActive, 1 );
	}
}

if ( FMCIsHtmlHelp() )
{
	window.name = "recentcomments";
}

function Init( OnCompleteFunc )
{
	if ( gInit )
	{
		if ( OnCompleteFunc )
		{
			OnCompleteFunc();
		}
		
		return;
	}

	//
	
	if ( !FMCIsHtmlHelp() )
	{
		StartLoading( window, document.body, MCGlobals.RootFrame.gLoadingLabel, MCGlobals.RootFrame.gLoadingAlternateText, null );
	}

	window.setTimeout( Init2, 0 );

	function Init2()
	{
		if ( FMCIsHtmlHelp() )
		{
			GetRecentComments();
		}

		var buttonTable	= document.getElementById( "Buttons" );
		var tr			= buttonTable.getElementsByTagName( "tr" )[0];
		
		//
		
		if ( FMCIsHtmlHelp() )
		{
			FMCSetupButtonFromStylesheet( tr, "ToolbarItem", "Back", "Images/Back.gif", "Images/Back_over.gif", "Images/Back_selected.gif", 23, 22, "Back", "", BackOnclick );
			
			//
			
			var labelTD	= document.createElement( "td" );
			var label	= CMCFlareStylesheet.LookupValue( "AccordionItem", "RecentComments", "Label", "Recent Comments" );
			
			labelTD.appendChild( document.createTextNode( label ) );
			labelTD.style.fontFamily = CMCFlareStylesheet.LookupValue( "Frame", "RecentComments", "FontFamily", "Arial, Sans-Serif" );
			labelTD.style.fontSize = CMCFlareStylesheet.LookupValue( "Frame", "RecentComments", "FontSize", "16px" );
			labelTD.style.fontWeight = CMCFlareStylesheet.LookupValue( "Frame", "RecentComments", "FontWeight", "bold" );
			labelTD.style.fontStyle = CMCFlareStylesheet.LookupValue( "Frame", "RecentComments", "FontStyle", "normal" );
			labelTD.style.color = CMCFlareStylesheet.LookupValue( "Frame", "RecentComments", "Color", "#000000" );
			labelTD.style.whiteSpace = "nowrap";
			
			tr.replaceChild( labelTD, tr.firstChild );
			
			//
			
			buttonTable.style.borderTop = CMCFlareStylesheet.LookupValue( "Frame", "RecentComments", "BorderTop", "none" );
			buttonTable.style.borderBottom = CMCFlareStylesheet.LookupValue( "Frame", "RecentComments", "BorderBottom", "solid 1px #5EC9FF" );
			buttonTable.style.borderLeft = CMCFlareStylesheet.LookupValue( "Frame", "RecentComments", "BorderLeft", "none" );
			buttonTable.style.borderRight = CMCFlareStylesheet.LookupValue( "Frame", "RecentComments", "BorderRight", "none" );
		}
		
		FMCSetupButtonFromStylesheet( tr, "Control", "CommentsRefreshButton", "Images/RefreshTopicComments.gif", "Images/RefreshTopicComments_over.gif", "Images/RefreshTopicComments_selected.gif", 23, 22, "Refresh comments", "", RefreshComments );
		
		//
		
		LoadSkin();
			
		//

		gInit = true;
		
		if ( !FMCIsHtmlHelp() )
		{
			EndLoading( window, null );
		}
		
		if ( OnCompleteFunc )
		{
			OnCompleteFunc();
		}
	}
}

function LoadSkin()
{
	document.body.style.backgroundColor = CMCFlareStylesheet.LookupValue( "Frame", "AccordionRecentComments", "BackgroundColor", "#fafafa" );
}

function GetRecentComments()
{
	var loadingImg = document.getElementById( "MCLoadingImage" );
	
	if ( loadingImg == null )
	{
		loadingImg = document.createElement( "img" );
		loadingImg.id = "MCLoadingImage";
		loadingImg.src = "Images/LoadingAnimated.gif";
		loadingImg.style.width = "16px";
		loadingImg.style.height = "16px";
		loadingImg.style.position = "absolute";
		loadingImg.style.top = "5px";
		loadingImg.style.left = "5px";
		document.body.insertBefore( loadingImg, document.body.childNodes[0] );
	}
	
	//
	
	if ( FMCIsHtmlHelp() )
	{
		var xmlDoc		= CMCXmlParser.GetXmlDoc( MCGlobals.RootFolder + MCGlobals.SubsystemFile, false, null, null );
		var projectID	= xmlDoc.documentElement.getAttribute( "LiveHelpOutputId" );
		
		FMCRegisterCallback( "Persistence", MCEventType.OnInit, FMCPersistenceInitialized, { ProjectID: projectID, RefreshCount: gRefreshCount } );
	}
	else
	{
		var helpSystem	= MCGlobals.BodyFrame.FMCGetHelpSystem();
		
		if ( helpSystem.LiveHelpEnabled )
		{
			var projectID	= helpSystem.LiveHelpOutputId;
			var userGuid	= FMCReadCookie( "LiveHelpUserGuid" );
			var now			= new Date();
			
			now.setHours( now.getHours() - 24 );

			MCGlobals.BodyFrame.gServiceClient.GetRecentComments( projectID, userGuid, null /* -FIX- */, now.toUTCString(), GetRecentCommentsOnComplete, gRefreshCount );
		}
		else
		{
			loadingImg.parentNode.removeChild( loadingImg );
		}
	}
}

function FMCPersistenceInitialized( args )
{
	var projectID		= args.ProjectID;
	var refreshCount	= args.RefreshCount;
	var userGuid		= FMCLoadUserData( "LiveHelpUserGuid" );
	var now				= new Date();
	
	now.setHours( now.getHours() - 24 );
	
	gServiceClient.GetRecentComments( projectID, userGuid, null /* -FIX- */, now.toUTCString(), GetRecentCommentsOnComplete, refreshCount );
}

function GetRecentCommentsOnComplete( commentsXml, refreshCount )
{
	if ( refreshCount != gRefreshCount )
	{
		return;
	}
	
	var commentsDiv	= document.getElementById( "LiveHelpComments" );
	
	if ( commentsDiv )
	{
		var newCommentsDiv	= commentsDiv.cloneNode( false );
		
		commentsDiv.parentNode.replaceChild( newCommentsDiv, commentsDiv );
		
		commentsDiv = newCommentsDiv;
	}
	else
	{
		commentsDiv = document.createElement( "div" );
		commentsDiv.id = "LiveHelpComments";
		
		document.body.appendChild( commentsDiv );
	}
	
	var xmlDoc	= CMCXmlParser.LoadXmlString( commentsXml );

	Build( xmlDoc.documentElement, commentsDiv, 0 );
	
	//
	
	var loadingImg	= document.getElementById( "MCLoadingImage" );
	
	loadingImg.parentNode.removeChild( loadingImg );
}

function Build( xmlNode, htmlNode, indent )
{
	for ( var i = 0; i < xmlNode.childNodes.length; i++ )
	{
		var node	= xmlNode.childNodes[i];
	    
		if ( node.nodeName != "Comment" )
		{
			continue;
		}
		
		//
		
		var isReply			= false;
		var styleClass		= "CommentNode";
		var commentsNode	= FMCGetChildNodeByTagName( node, "Comments", 0 );
		
		if ( commentsNode != null && commentsNode.childNodes.length > 0 )
		{
			isReply = true;
			styleClass = "CommentReplyNode";
		}
		
		//
	    
		var subject		= node.getAttribute( "Subject" );
		var username	= node.getAttribute( "User" );
		var date		= node.getAttribute( "DateUTC" );
		var topicPath	= node.getAttribute( "TopicPath" );
		var topicTitle	= node.getAttribute( "TopicTitle" );

		var outerDiv	= document.createElement( "div" );
		var innerDiv	= document.createElement( "div" );
		var subjectDiv	= document.createElement( "div" );
		var subjectSpan	= document.createElement( "span" );
		var infoDiv		= document.createElement( "div" );
		var img			= document.createElement( "img" );
		
		outerDiv.appendChild( innerDiv );
		
		outerDiv.style.marginLeft = indent + "px";
		
		innerDiv.setAttribute( "MadCap:bgColor", "Transparent" );
//		innerDiv.setAttribute( "MadCap:bgColorOver", "#CEE3FF" );
//		innerDiv.setAttribute( "MadCap:bgColorSelected", "#5EC9FF" );
		innerDiv.setAttribute( "MadCap:bgColorSelected", CMCFlareStylesheet.LookupValue( "Control", styleClass, "BackgroundColor", "CEE3FF" ) );

		innerDiv.style.cursor = "default";
//		innerDiv.onmouseover = CommentOnmouseover;
//		innerDiv.onmouseout = CommentOnmouseout;
		innerDiv.onclick = CommentOnclick;
		
		var a	= document.createElement( "a" );
		
		a.href = "javascript:void( 0 );";
		a.onclick = CommentANodeOnclick;
		
		innerDiv.appendChild( a );

	    subjectDiv.style.fontFamily = CMCFlareStylesheet.LookupValue( "Control", styleClass, "SubjectFontFamily", "Arial" );
	    subjectDiv.style.fontSize = CMCFlareStylesheet.LookupValue( "Control", styleClass, "SubjectFontSize", "12px" );
	    subjectDiv.style.fontWeight = CMCFlareStylesheet.LookupValue( "Control", styleClass, "SubjectFontWeight", "bold" );
	    subjectDiv.style.fontStyle = CMCFlareStylesheet.LookupValue( "Control", styleClass, "SubjectFontStyle", "normal" );
	    subjectDiv.style.color = CMCFlareStylesheet.LookupValue( "Control", styleClass, "SubjectColor", "#000000" );
	    subjectDiv.appendChild( img );
		subjectDiv.appendChild( subjectSpan );
		
		if ( FMCIsSafari() )
	    {
			subjectSpan.innerHTML = subject;
	    }
	    else
	    {
			subjectSpan.appendChild( document.createTextNode( subject ) );
		}
		
		a.appendChild( subjectDiv );
		
		if ( username )
		{
			var userSpan	= document.createElement( "span" );
			userSpan.style.fontFamily = CMCFlareStylesheet.LookupValue( "Control", styleClass, "UserInfoFontFamily", "Arial" );
			userSpan.style.fontSize = CMCFlareStylesheet.LookupValue( "Control", styleClass, "UserInfoFontSize", "10px" );
			userSpan.style.fontWeight = CMCFlareStylesheet.LookupValue( "Control", styleClass, "UserInfoFontWeight", "normal" );
			userSpan.style.fontStyle = CMCFlareStylesheet.LookupValue( "Control", styleClass, "UserInfoFontStyle", "normal" );
			userSpan.style.color = CMCFlareStylesheet.LookupValue( "Control", styleClass, "UserInfoColor", "#000000" );
			
			if ( FMCIsSafari() )
			{
				userSpan.innerHTML = username;
			}
			else
			{
				userSpan.appendChild( document.createTextNode( username ) );
			}
			
			infoDiv.appendChild( userSpan );
		}
		
		if ( date )
		{
			if ( username )
			{
				infoDiv.appendChild( document.createTextNode( " " ) );
			}
			
			var dateObj		= CMCDateTimeHelpers.GetDateFromUTCString( date );
			var dateSpan	= document.createElement( "span" );
			dateSpan.appendChild( document.createTextNode( CMCDateTimeHelpers.ToUIString( dateObj ) ) );
			dateSpan.style.fontFamily = CMCFlareStylesheet.LookupValue( "Control", styleClass, "TimestampFontFamily", "Arial" );
			dateSpan.style.fontSize = CMCFlareStylesheet.LookupValue( "Control", styleClass, "TimestampFontSize", "10px" );
			dateSpan.style.fontWeight = CMCFlareStylesheet.LookupValue( "Control", styleClass, "TimestampFontWeight", "normal" );
			dateSpan.style.fontStyle = CMCFlareStylesheet.LookupValue( "Control", styleClass, "TimestampFontStyle", "italic" );
			dateSpan.style.color = CMCFlareStylesheet.LookupValue( "Control", styleClass, "TimestampColor", "#000000" );
			
			infoDiv.appendChild( dateSpan );
		}
		
		infoDiv.style.marginLeft = "16px";
		a.appendChild( infoDiv );

		if ( topicTitle == null )
		{
			topicTitle = topicPath;
		}
		
		if ( topicTitle != null )
		{
			var topicA	= document.createElement( "a" );
			topicA.appendChild( document.createTextNode( topicTitle ) );
			topicA.style.fontFamily = CMCFlareStylesheet.LookupValue( "Control", styleClass, "TopicLinkFontFamily", "Arial" );
			topicA.style.fontSize = CMCFlareStylesheet.LookupValue( "Control", styleClass, "TopicLinkFontSize", "10px" );
			topicA.style.fontWeight = CMCFlareStylesheet.LookupValue( "Control", styleClass, "TopicLinkFontWeight", "normal" );
			topicA.style.fontStyle = CMCFlareStylesheet.LookupValue( "Control", styleClass, "TopicLinkFontStyle", "italic" );
			topicA.style.color = CMCFlareStylesheet.LookupValue( "Control", styleClass, "TopicLinkColor", "#000000" );

			if ( topicPath != null )
			{
				if ( FMCIsHtmlHelp() )
				{
					topicPath = "/" + topicPath;
				}
				else
				{
					var helpSystem	= MCGlobals.BodyFrame.FMCGetHelpSystem();

					var path = new CMCUrl( helpSystem.GetPath() + helpSystem.ContentFolder + topicPath );
					
					if ( helpSystem.UseCustomTopicFileExtension )
					{
						path = path.ToExtension( helpSystem.CustomTopicFileExtension );
					}
				
					topicPath = path.FullPath;
					
					topicA.setAttribute( "target", "body" );
				}
				
				topicA.setAttribute( "href", topicPath );
			}

			var topicDiv = document.createElement( "div" );
			topicDiv.style.marginLeft = "16px";
			topicDiv.appendChild( topicA );
			
			a.appendChild( topicDiv );
		}
		
		var bodyNode	= FMCGetChildNodeByTagName( node, "Body", 0 );
		
		if ( bodyNode )
		{
			var commentNode	= bodyNode.childNodes[0];
			
			if ( commentNode )
			{
				var comment		= commentNode.nodeValue;
				var commentDiv	= document.createElement( "div" );

				commentDiv.appendChild( document.createTextNode( comment ) );
				commentDiv.style.marginLeft = "16px";
				commentDiv.style.display = "none";
				commentDiv.style.fontFamily = CMCFlareStylesheet.LookupValue( "Control", styleClass, "BodyFontFamily", "Arial" );
				commentDiv.style.fontSize = CMCFlareStylesheet.LookupValue( "Control", styleClass, "BodyFontSize", "10px" );
				commentDiv.style.fontWeight = CMCFlareStylesheet.LookupValue( "Control", styleClass, "BodyFontWeight", "normal" );
				commentDiv.style.fontStyle = CMCFlareStylesheet.LookupValue( "Control", styleClass, "BodyFontStyle", "normal" );
				commentDiv.style.color = CMCFlareStylesheet.LookupValue( "Control", styleClass, "BodyColor", "#000000" );
				
				innerDiv.appendChild( commentDiv );
			}
		}

		outerDiv.appendChild( document.createElement( "br" ) );
		
		var commentsNode	= FMCGetChildNodeByTagName( node, "Comments", 0 );
		
		if ( isReply )
		{
			CMCFlareStylesheet.SetImageFromStylesheet( img, "Control", styleClass, "Icon", "Images/CommentReply.gif", 16, 16 );
			
			Build( commentsNode, outerDiv, indent + 16 );
		}
		else
		{
			CMCFlareStylesheet.SetImageFromStylesheet( img, "Control", styleClass, "Icon", "Images/Comment.gif", 16, 16 );
		}
	    
		htmlNode.appendChild( outerDiv );
	}
}

var gRefreshCount	= 0;

function RefreshComments( e )
{
	if ( !e ) { e = window.event; }
	
	gRefreshCount++;
	
	GetRecentComments();
}

var gSelectedComment	= null;

function CommentOnclick( e )
{
	if ( !e ) { e = window.event; }
	
	if ( gSelectedComment )
	{
		var c1	= FMCGetMCAttribute( gSelectedComment, "MadCap:bgColor" );
		var c2	= FMCGetMCAttribute( gSelectedComment, "MadCap:bgColorSelected" );
		
		gSelectedComment.setAttribute( "MadCap:bgColor", c2 );
		gSelectedComment.setAttribute( "MadCap:bgColorSelected", c1 );
		gSelectedComment.style.backgroundColor = c2;
	}
	
	var bgColor			= FMCGetMCAttribute( this, "MadCap:bgColor" );
	var bgColorSelected	= FMCGetMCAttribute( this, "MadCap:bgColorSelected" );
	
	this.setAttribute( "MadCap:bgColor", bgColorSelected );
	this.setAttribute( "MadCap:bgColorSelected", bgColor );
	this.style.backgroundColor = bgColorSelected;
	
	gSelectedComment = this;
}

function CommentANodeOnclick()
{
	var commentDiv	= FMCGetChildNodeByTagName( this.parentNode, "DIV", 0 );
	
	FMCToggleDisplay( commentDiv );
}

//function CommentOnmouseover( e )
//{
//	if ( !e ) { e = window.event; }
//	
//	var bgColor	= FMCGetMCAttribute( this, "MadCap:bgColorOver" );
//	
//	this.style.backgroundColor = bgColor;
//}

//function CommentOnmouseout( e )
//{
//	if ( !e ) { e = window.event; }
//	
//	var bgColor	= FMCGetMCAttribute( this, "MadCap:bgColor" );
//	
//	this.style.backgroundColor = bgColor;
//}

function BackOnclick()
{
	window.history.go( -1 );
}
