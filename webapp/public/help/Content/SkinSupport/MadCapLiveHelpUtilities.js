/// <reference path="MadCapUtilities.js" />

// {{MadCap}} //////////////////////////////////////////////////////////////////
// Copyright: MadCap Software, Inc - www.madcapsoftware.com ////////////////////
////////////////////////////////////////////////////////////////////////////////
// <version>4.2.0.0</version>
////////////////////////////////////////////////////////////////////////////////

var gEmptyIcon				= null;
var gHalfFullIcon			= null;
var gFullIcon				= null;
var gIconWidth				= 16;
var gTopicRatingIconsInit	= false;

function TopicRatingIconsInit()
{
	if ( gTopicRatingIconsInit )
	{
		return;
	}
	
	//
	
	var value	= CMCFlareStylesheet.LookupValue( "ToolbarItem", "TopicRatings", "EmptyIcon", null );

	if ( value == null )
	{
		gEmptyIcon = MCGlobals.RootFolder + MCGlobals.SkinTemplateFolder + "Images/Rating0.gif";
		gIconWidth = 16;
	}
	else
	{
		value = FMCStripCssUrl( value );
		value = decodeURIComponent( value );
		value = escape( value );
		gEmptyIcon = FMCGetSkinFolderAbsolute() + value;
	}

	value = CMCFlareStylesheet.LookupValue( "ToolbarItem", "TopicRatings", "HalfFullIcon", null );

	if ( value == null )
	{
		gHalfFullIcon = MCGlobals.RootFolder + MCGlobals.SkinTemplateFolder + "Images/RatingGold50.gif";
	}
	else
	{
		value = FMCStripCssUrl( value );
		value = decodeURIComponent( value );
		value = escape( value );
		gHalfFullIcon = FMCGetSkinFolderAbsolute() + value;
	}

	value = CMCFlareStylesheet.LookupValue( "ToolbarItem", "TopicRatings", "FullIcon", null );

	if ( value == null )
	{
		gFullIcon = MCGlobals.RootFolder + MCGlobals.SkinTemplateFolder + "Images/RatingGold100.gif";
	}
	else
	{
		value = FMCStripCssUrl( value );
		value = decodeURIComponent( value );
		value = escape( value );
		gFullIcon = FMCGetSkinFolderAbsolute() + value;
	}
	
	//
	
	gTopicRatingIconsInit = true;
}

function FMCRatingIconsCalculateRating( e, iconContainer )
{
	if ( !e ) { e = window.event; }

	var x			= FMCGetMouseXRelativeTo( window, e, iconContainer );
	var imgNodes	= iconContainer.getElementsByTagName( "img" );
	var numImgNodes	= imgNodes.length;
	var iconWidth	= gIconWidth;
	var numIcons	= Math.ceil( x / iconWidth );
	var rating		= numIcons * 100 / numImgNodes;
	
	return rating;
}

function FMCRatingIconsOnmousemove( e, iconContainer )
{
	TopicRatingIconsInit();
	
	//
	
	if ( !e ) { e = window.event; }

	var rating	= FMCRatingIconsCalculateRating( e, iconContainer );
	
	FMCDrawRatingIcons( rating, iconContainer );
}

function FMCClearRatingIcons( rating, iconContainer )
{
	FMCDrawRatingIcons( rating, iconContainer );
}

function FMCDrawRatingIcons( rating, iconContainer )
{
	TopicRatingIconsInit();
	
	//

	var imgNodes	= iconContainer.getElementsByTagName( "img" );
	var numImgNodes	= imgNodes.length;
	var numIcons	= Math.ceil( rating * numImgNodes / 100 );

	for ( var i = 0; i < numImgNodes; i++ )
	{
		var node	= imgNodes[i];
		
		if ( i <= numIcons - 1 )
		{
			node.src = gFullIcon;
		}
		else
		{
			node.src = gEmptyIcon;
		}
	}
}

//
//    Class CMCLiveHelpServiceClient
//

var gLiveHelpServerUrl	= null;	// Set by compiler
gLiveHelpServerUrl = FMCGetFeedbackServerUrl( gLiveHelpServerUrl );

function FMCGetFeedbackServerUrl( serverUrl )
{
	if ( serverUrl == null )
	{
		return null;
	}
	
	var url			= serverUrl;
	var pos			= url.indexOf( ":" );
	var urlProtocol	= url.substring( 0, pos + 1 );
	var docProtocol	= document.location.protocol;
	
	if ( window.name != "bridge" )
	{
		if ( urlProtocol.Equals( "https:", false ) && docProtocol.Equals( "http:", false ) )
		{
			url = url.substring( pos + 1 );
			url = "http:" + url;
		}
	}
	
	if ( url.Contains( "madcapsoftware.com", false ) )
	{
		url = url + "LiveHelp/Service.LiveHelp/LiveHelpService.asmx/";
	}
	else
	{
		url = url + "Service.FeedbackExplorer/FeedbackJsonService.asmx/";
	}
	
	return url;
}

var gServiceClient	= new function()
{
	// Private member variables and functions
	
	var mCallbackMap						= new CMCDictionary();
	
	var mLiveHelpScriptIndex				= 0;
	var mLiveHelpService					= gLiveHelpServerUrl;
	var mGetAverageRatingOnCompleteFunc		= null;
	var mGetAverageRatingOnCompleteArgs		= null;
	var mGetRecentCommentsOnCompleteFunc	= null;
	var mGetRecentCommentsOnCompleteArgs	= null;
	var mGetAnonymousEnabledOnCompleteFunc	= null;
	var mGetAnonymousEnabledOnCompleteArgs	= null;
	var mStartActivateUserOnCompleteFunc	= null;
	var mStartActivateUserOnCompleteArgs	= null;
	var mCheckUserStatusOnCompleteFunc		= null;
	var mCheckUserStatusOnCompleteArgs		= null;
	var mGetSynonymsFileOnCompleteFunc		= null;
	var mGetSynonymsFileOnCompleteArgs		= null;
	
	var mVersion	= -1;
	
	function AddScriptTag( webMethodName, onCompleteFunc, nameValuePairs )
	{
		var script		= document.createElement( "script" );
		var head		= document.getElementsByTagName( "head" )[0];
		var scriptID	= "MCLiveHelpScript_" + mLiveHelpScriptIndex++;
		var src			= mLiveHelpService + webMethodName + "?";
		
		src += "OnComplete=" + onCompleteFunc + "&ScriptID=" + scriptID + "&UniqueID=" + (new Date()).getTime();
		
		if ( nameValuePairs != null )
		{
			for ( var i = 0, length = nameValuePairs.length; i < length; i++ )
			{
				var pair = nameValuePairs[i];
				var name = pair[0];
				var value = encodeURIComponent( pair[1] );
				
				src += ("&" + name + "=" + value);
			}
		}

		if ( document.body.currentStyle != null )
		{
			var ieUrlLimit = 2083;
			
			if ( src.length > ieUrlLimit )
			{
				var diff = src.length - ieUrlLimit;
				var data = { ExceedAmount: diff };
				var ex = new CMCFeedbackException( -1, "URL limit exceeded.", data );
				
				throw ex;
			}
		}
		
		var qsLimit = 2048;
		var qsPos = src.indexOf( "?" )
		var qsChars = src.substring( qsPos + 1 ).length;
		
		if ( qsChars > qsLimit )
		{
			var diff = qsChars - qsLimit;
			var data = { ExceedAmount: diff };
			var ex = new CMCFeedbackException( -1, "Query string limit exceeded.", data );
			
			throw ex;
		}

		script.id = scriptID;
		script.setAttribute( "type", "text/javascript" );
		script.setAttribute( "src", src );

		head.appendChild( script );
		
		return scriptID;
	}

    // Public member functions

	this.RemoveScriptTag	= function( scriptID )
	{
		function RemoveScriptTag2()
		{
			var	script	= document.getElementById( scriptID );

			script.parentNode.removeChild( script );
		}
		
		// IE bug: Need this setTimeout() or else IE will crash. This happens when removing the <script> tag after re-navigating to the same page.
		
		window.setTimeout( RemoveScriptTag2, 10 );
	}
	
	this.LogTopic	= function( topicID )
	{
		AddScriptTag( "LogTopic", "gServiceClient.LogTopicOnComplete", [	[ "TopicID", topicID] ] );
	}
	
	this.LogTopicOnComplete	= function( scriptID )
	{
		this.RemoveScriptTag( scriptID );
	}
	
	this.LogTopic2	= function( topicID, cshID, onCompleteFunc, onCompleteArgs, thisObj )
	{
		this.LogTopic2OnComplete	= function( scriptID )
		{
			if ( onCompleteFunc != null )
			{
				if ( thisObj != null )
				{
					onCompleteFunc.call( thisObj, onCompleteArgs );
				}
				else
				{
					onCompleteFunc( onCompleteArgs );
				}
			}
			
			//
			
			this.RemoveScriptTag( scriptID );
			
			this.LogTopic2OnComplete = null;
		}

		AddScriptTag( "LogTopic2", "gServiceClient.LogTopic2OnComplete", [	[ "TopicID", topicID],
																			[ "CSHID", cshID ] ] );
	}
	
	this.LogSearch	= function( projectID, userGuid, resultCount, language, query )
	{
		AddScriptTag( "LogSearch", "gServiceClient.LogSearchOnComplete", [	[ "ProjectID", projectID],
																			[ "UserGuid", userGuid],
																			[ "ResultCount", resultCount],
																			[ "Language", language],
																			[ "Query", query] ] );
	}
	
	this.LogSearchOnComplete	= function( scriptID )
	{
		this.RemoveScriptTag( scriptID );
	}
	
	this.AddComment	= function( topicID, userGuid, userName, subject, comment, parentCommentID )
	{
		AddScriptTag( "AddComment", "gServiceClient.AddCommentOnComplete", [	[ "TopicID", topicID],
																				[ "UserGuid", userGuid],
																				[ "Username", userName],
																				[ "Subject", subject],
																				[ "Comment", comment],
																				[ "ParentCommentID", parentCommentID ] ] );
	}
	
	this.AddCommentOnComplete	= function( scriptID )
	{
		this.RemoveScriptTag( scriptID );
	}
	
	this.GetAverageRating	= function( topicID, onCompleteFunc, onCompleteArgs )
	{
		mGetAverageRatingOnCompleteFunc = onCompleteFunc;
		mGetAverageRatingOnCompleteArgs = onCompleteArgs;

		AddScriptTag( "GetAverageRating", "gServiceClient.GetAverageRatingOnComplete", [	[ "TopicID", topicID] ] );
	}

	this.GetAverageRatingOnComplete	= function( scriptID, averageRating, ratingCount )
	{
		if ( mGetAverageRatingOnCompleteFunc != null )
		{
			mGetAverageRatingOnCompleteFunc( averageRating, ratingCount, mGetAverageRatingOnCompleteArgs );
			mGetAverageRatingOnCompleteFunc = null;
			mGetAverageRatingOnCompleteArgs = null;
		}
		
		//
		
		this.RemoveScriptTag( scriptID );
	}
	
	this.SubmitRating	= function( topicID, rating, comment )
	{
		AddScriptTag( "SubmitRating", "gServiceClient.SubmitRatingOnComplete", [	[ "TopicID", topicID],
																					[ "Rating", rating],
																					[ "Comment", comment] ] );
	}
	
	this.SubmitRatingOnComplete	= function( scriptID )
	{
		this.RemoveScriptTag( scriptID );
	}
	
	this.GetTopicComments	= function( topicID, userGuid, userName, onCompleteFunc, onCompleteArgs )
	{
		var scriptID = AddScriptTag( "GetTopicComments", "gServiceClient.GetTopicCommentsOnComplete", [	[ "TopicID", topicID],
																										[ "UserGuid", userGuid],
																										[ "Username", userName] ] );

		var callbackData = { OnCompleteFunc: onCompleteFunc, OnCompleteArgs: onCompleteArgs };
		
		mCallbackMap.Add( scriptID, callbackData );
	}
	
	this.GetTopicCommentsOnComplete	= function( scriptID, commentsXml )
	{
		var callbackData = mCallbackMap.GetItem( scriptID );
		var callbackFunc = callbackData.OnCompleteFunc;
		var callbackArgs = callbackData.OnCompleteArgs;
		
		if ( callbackFunc != null )
		{
			callbackFunc( commentsXml, callbackArgs );
			
			mCallbackMap.Remove( scriptID );
		}
		
		//
		
		this.RemoveScriptTag( scriptID );
	}
	
	this.GetRecentComments	= function( projectID, userGuid, userName, oldestComment, onCompleteFunc, onCompleteArgs )
	{
		mGetRecentCommentsOnCompleteFunc = onCompleteFunc;
		mGetRecentCommentsOnCompleteArgs = onCompleteArgs;
		
		AddScriptTag( "GetRecentComments", "gServiceClient.GetRecentCommentsOnComplete", [	[ "ProjectID", projectID],
																							[ "UserGuid", userGuid],
																							[ "Username", userName],
																							[ "Oldest", oldestComment] ] );
	}

	this.GetRecentCommentsOnComplete	= function( scriptID, commentsXml )
	{
		if ( mGetRecentCommentsOnCompleteFunc != null )
		{
			mGetRecentCommentsOnCompleteFunc( commentsXml, mGetRecentCommentsOnCompleteArgs );
			mGetRecentCommentsOnCompleteFunc = null;
			mGetRecentCommentsOnCompleteArgs = null;
		}
		
		//
		
		this.RemoveScriptTag( scriptID );
	}
	
	this.GetAnonymousEnabled	= function( projectID, onCompleteFunc, onCompleteArgs )
	{
		mGetAnonymousEnabledOnCompleteFunc = onCompleteFunc;
		mGetAnonymousEnabledOnCompleteArgs = onCompleteArgs;
		
		var src	= mLiveHelpService +	"GetAnonymousEnabled?ProjectID=" + encodeURIComponent( projectID );
		
		AddScriptTag( "GetAnonymousEnabled", "gServiceClient.GetAnonymousEnabledOnComplete", [	[ "ProjectID", projectID] ] );
	}

	this.GetAnonymousEnabledOnComplete	= function( scriptID, enabled )
	{
		if ( mGetAnonymousEnabledOnCompleteFunc != null )
		{
			mGetAnonymousEnabledOnCompleteFunc( enabled, mGetAnonymousEnabledOnCompleteArgs );
			mGetAnonymousEnabledOnCompleteFunc = null;
			mGetAnonymousEnabledOnCompleteArgs = null;
		}
		
		//
		
		this.RemoveScriptTag( scriptID );
	}
	
	this.StartActivateUser	= function( xmlDoc, onCompleteFunc, onCompleteArgs )
	{
		mStartActivateUserOnCompleteFunc = onCompleteFunc;
		mStartActivateUserOnCompleteArgs = onCompleteArgs;

		var usernameNode		= FMCGetChildNodeByAttribute( xmlDoc.documentElement, "Name", "Username" );
		var username			= FMCGetAttribute( usernameNode, "Value" );
		var emailAddressNode	= FMCGetChildNodeByAttribute( xmlDoc.documentElement, "Name", "EmailAddress" );
		var emailAddress		= FMCGetAttribute( emailAddressNode, "Value" );
		var firstNameNode		= FMCGetChildNodeByAttribute( xmlDoc.documentElement, "Name", "FirstName" );
		var firstName			= FMCGetAttribute( firstNameNode, "Value" );
		var lastNameNode		= FMCGetChildNodeByAttribute( xmlDoc.documentElement, "Name", "LastName" );
		var lastName			= FMCGetAttribute( lastNameNode, "Value" );
		var countryNode			= FMCGetChildNodeByAttribute( xmlDoc.documentElement, "Name", "Country" );
		var country				= FMCGetAttribute( countryNode, "Value" );
		var postalCodeNode		= FMCGetChildNodeByAttribute( xmlDoc.documentElement, "Name", "PostalCode" );
		var postalCode			= FMCGetAttribute( postalCodeNode, "Value" );
		var genderNode			= FMCGetChildNodeByAttribute( xmlDoc.documentElement, "Name", "Gender" );
		var gender				= FMCGetAttribute( genderNode, "Value" );
		var uiLanguageOrder		= "";
		
		AddScriptTag( "StartActivateUser", "gServiceClient.StartActivateUserOnComplete", [	[ "Username", username],
																							[ "EmailAddress", emailAddress],
																							[ "FirstName", firstName],
																							[ "LastName", lastName],
																							[ "Country", country],
																							[ "Zip", postalCode],
																							[ "Gender", gender],
																							[ "UILanguageOrder", uiLanguageOrder] ] );
	}

	this.StartActivateUserOnComplete	= function( scriptID, pendingGuid )
	{
		if ( mStartActivateUserOnCompleteFunc != null )
		{
			mStartActivateUserOnCompleteFunc( pendingGuid, mStartActivateUserOnCompleteArgs );
			mStartActivateUserOnCompleteFunc = null;
			mStartActivateUserOnCompleteArgs = null;
		}
		
		//
		
		this.RemoveScriptTag( scriptID );
	}
	
	this.StartActivateUser2	= function( xmlDoc, onCompleteFunc, onCompleteArgs, thisObj )
	{
		var xml	= CMCXmlParser.GetOuterXml( xmlDoc );
		
		this.StartActivateUser2OnComplete	= function( scriptID, pendingGuid )
		{
			if ( onCompleteFunc != null )
			{
				if ( thisObj != null )
				{
					onCompleteFunc.call( thisObj, pendingGuid, onCompleteArgs );
				}
				else
				{
					onCompleteFunc( pendingGuid, onCompleteArgs );
				}
			}
			
			//
			
			this.RemoveScriptTag( scriptID );
			
			this.StartActivateUser2OnComplete = null;
		}

		AddScriptTag( "StartActivateUser2", "gServiceClient.StartActivateUser2OnComplete", [	[ "Xml", xml] ] );
	}
	
	this.UpdateUserProfile	= function( guid, xmlDoc, onCompleteFunc, onCompleteArgs, thisObj )
	{
		var xml	= CMCXmlParser.GetOuterXml( xmlDoc );
		
		this.UpdateUserProfileOnComplete	= function( scriptID, pendingGuid )
		{
			if ( onCompleteFunc != null )
			{
				if ( thisObj != null )
				{
					onCompleteFunc.call( thisObj, pendingGuid, onCompleteArgs );
				}
				else
				{
					onCompleteFunc( pendingGuid, onCompleteArgs );
				}
			}
			
			//
			
			this.RemoveScriptTag( scriptID );
			
			this.UpdateUserProfileOnComplete = null;
		}

		AddScriptTag( "UpdateUserProfile", "gServiceClient.UpdateUserProfileOnComplete", [	[ "Guid", guid],
																							[ "Xml", xml] ] );
	}
	
	this.CheckUserStatus	= function( pendingGuid, onCompleteFunc, onCompleteArgs )
	{
		mCheckUserStatusOnCompleteFunc = onCompleteFunc;
		mCheckUserStatusOnCompleteArgs = onCompleteArgs;

		AddScriptTag( "CheckUserStatus", "gServiceClient.CheckUserStatusOnComplete", [	[ "PendingGuid", pendingGuid] ] );
	}

	this.CheckUserStatusOnComplete	= function( scriptID, status )
	{
		if ( mCheckUserStatusOnCompleteFunc != null )
		{
			var func	= mCheckUserStatusOnCompleteFunc;
			var args	= mCheckUserStatusOnCompleteArgs;
			mCheckUserStatusOnCompleteFunc = null;
			mCheckUserStatusOnCompleteArgs = null;
			
			func( status, args );
		}
		
		//
		
		this.RemoveScriptTag( scriptID );
	}
	
	this.GetSynonymsFile	= function( projectID, updatedSince, onCompleteFunc, onCompleteArgs )
	{
		mGetSynonymsFileOnCompleteFunc = onCompleteFunc;
		mGetSynonymsFileOnCompleteArgs = onCompleteArgs;

		AddScriptTag( "GetSynonymsFile", "gServiceClient.GetSynonymsFileOnComplete", [	[ "ProjectID", projectID],
																						[ "UpdatedSince", updatedSince] ] );
	}

	this.GetSynonymsFileOnComplete	= function( scriptID, synonymsXml )
	{
		if ( mGetSynonymsFileOnCompleteFunc != null )
		{
			mGetSynonymsFileOnCompleteFunc( synonymsXml, mGetSynonymsFileOnCompleteArgs );
			mGetSynonymsFileOnCompleteFunc = null;
			mGetSynonymsFileOnCompleteArgs = null;
		}
		
		//
		
		this.RemoveScriptTag( scriptID );
	}
	
	this.GetVersion	= function( onCompleteFunc, onCompleteArgs, thisObj )
	{
		this.GetVersionOnComplete	= function( scriptID, version )
		{
			if ( version == null )
			{
				mVersion = 1;
			}
			else
			{
				mVersion = version;
			}
			
			if ( onCompleteFunc != null )
			{
				if ( thisObj != null )
				{
					onCompleteFunc.call( thisObj, mVersion, onCompleteArgs );
				}
				else
				{
					onCompleteFunc( mVersion, onCompleteArgs );
				}
			}
			
			//
			
			if ( scriptID != null )
			{
				this.RemoveScriptTag( scriptID );
			}
			
			this.GetVersionOnComplete = null;
		}
		
		if ( mVersion == -1 )
		{
			AddScriptTag( "GetVersion", "gServiceClient.GetVersionOnComplete" );
		}
		else
		{
			this.GetVersionOnComplete( null, mVersion );
		}
	}
}

//
//    End class CMCLiveHelpServiceClient
//

//
//    Class CMCFeedbackException
//

function CMCFeedbackException( number, message, data )
{
	CMCException.call( this, number, message );

	// Public properties

	this.Data = data;
}

CMCFeedbackException.prototype = new CMCException();
CMCFeedbackException.prototype.constructor = CMCFeedbackException;
CMCFeedbackException.prototype.base = CMCException.prototype;

//
//    End class CMCFeedbackException
//
