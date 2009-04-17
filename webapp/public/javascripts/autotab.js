/* 
 * autotab.js
 * 
 *  - Author: Michael J. Sepcot (michael.sepcot@gmail.com)
 * 
 *  - Use: include this file (autotab.js) in the head of your document. You will need to 
 *    update the init() function to suit your autotabbing needs, by default the function 
 *    sets up Numeric Autotabbing on all form input fields that have the class 'autotab'.
 * 
 *  - Version: 0.2.0
 *    - Generic Autotab - Simulate a tab when the user has entered the maximum allowable
 *      characters in a form input field.
 *    - Changes:
 *        + Refactored code to make a generic autotab function that accepts an element and
 *          a regular expression formatted string. Attempts autotab if String.Match( RegEx )
 *          succeeds.
 *        + Added keyup_specialKey to check the keyCode value against known special keys,
 *          we only want to attempt an autotab if the user makes a change to the form 
 *          field's value.
 *  - Version: 0.1.0
 *     - Numeric Autotab - Simulate a tab when the user has entered the maximum allowable 
 *       numeric characters in a form input field.
 */

/* 
 * doNumericAutotab( e )
 * 
 * This function changes form focus from the current form element to the next form element 
 * when the value of the form field is a string of integers matching in length to the form 
 * field's maxLength value.
 * 
 * Requirements: form field must have the maxLength attribute set.
 */
function doNumericAutotab( e )
{
	var elm = getElementFromEvent( e );
	var keyCode = e.keyCode;
	var numeric = "^\\d{" + elm.maxLength + "}$";

	// Return if we don't find the target element or non-numeric key is pressed.
	if ( !elm || !keyup_numericKey( keyCode ) ) return;
	
	autotab( elm, numeric );
}

/* 
 * doGenericAutotab( e )
 * 
 * This function changes form focus from the current form element to the next form element 
 * when the value of the form field length matches the form field's maxLength value.
 * 
 * Requirements: form field must have the maxLength attribute set.
 */
function doGenericAutotab( e )
{
	var elm = getElementFromEvent( e );
	var keyCode = e.keyCode;
	var all = "^.{" + elm.maxLength + "}$";

	// Return if we don't find the target element or a special key is pressed.
	if ( !elm || keyup_specialKey( keyCode ) ) return;
	
	autotab( elm, all );	
}

/*
 * autotab( elm, valid )
 * 
 * This function takes and element (elm) and a regular expression string (valid) and 
 * performs a match on the element's value. If the match passes, we pass focus to the 
 * next form field.
 */
function autotab( elm, valid )
{
	var test = RegExp(valid);
	
	if ( elm.value.match(test) != null )
	{
		focusOn( nextFormElement( elm ) );
	}
}

/*
 * keyup_specialKey( code )
 * 
 * Given a keyCode value, this function checks against the known keyCodes for Special 
 * Keys as described in the Quirksmode article Javascript - Detecting keystrokes 
 * http://www.quirksmode.org/js/keys.html (as of 19 September 2007).
 */
function keyup_specialKey( code )
{
	if ( 0 == code )				return true; // f1 - f12 (Opera Mac)
	if ( 5 == code || 6 == code )	return true; // help (Mac only. Firefox/Safari give different values.)
	if ( 8 == code )				return true; // backspace
	if ( 9 == code )				return true; // tab
	if ( 12 == code )				return true; // num lock (Mac)
	if ( 13 == code )				return true; // enter
	if ( 16 <= code && code <= 18 )	return true; // shift, ctrl (also cmd on Opera Mac), alt
	if ( 20 == code )				return true; // caps lock
	if ( 27 == code )				return true; // escape (also num lock on Opera Mac)
	if ( 33 <= code && code <= 40 )	return true; // page up, page down, end, home, arrow keys
	if ( 45 == code )				return true; // insert (also help on Opera Mac)
	if ( 46 == code )				return true; // delete
	if ( 91 == code )				return true; // start
	if ( 112 <= code && code <= 123 ) return true; // f1 - f12
	if ( 144 == code )				return true; // num lock

	return false;
}

/*
 * keyup_numericKey( code )
 * 
 * Given a keyCode value, this function checks against the known keyCodes for Numeric 
 * Keys on both the keyboard and key pad.
 */
function keyup_numericKey( code )
{
	if ( 48 <= code && code <= 57 ) return true; // number keys (top of keyboard)
	else if ( 96 <= code && code <= 105 ) return true; // number keys (on key pad)
	else return false;
}

/*
 * getElementFromEvent( e )
 * 
 * Given an event has fired, this function returns the Source Element or Target of the event.
 */
function getElementFromEvent( e )
{
	if ( window.event && window.event.srcElement )
	{
		return window.event.srcElement;
	}
	else if ( e && e.target )
	{
		return e.target;
	}
	else
	{
		return null;
	}
}

/* 
 * nextFormElement( current )
 * 
 * Parse the active form and return the next form element.
 */
function nextFormElement( current )
{
	var f = current.form;
	
	for ( var i = 0; i < f.length; i++ )
	{
		if ( f[i] == current )
		{
			next = f[i+1]
			return next == null ? null : next;
		}
	}
}

/*
 * focusOn( elm )
 * 
 * Given an element, this function attempts to give that element the browser's focus.
 */
function focusOn( elm )
{
	if ( elm == null ) return;

	try
	{
		elm.focus();
	}
	catch ( ex )
	{
		// Catch Mozilla exception when new focus field has autocomplete data.
	}
}

/*
 * getElementsByClassName( oElm, strTagName, strClassName )
 * 
 * From: http://www.robertnyman.com/index.php?p=256
 *  Written by Jonathan Snook, http://www.snook.ca/jonathan
 *  Add-ons by Robert Nyman, http://www.robertnyman.com
 */
function getElementsByClassName( oElm, strTagName, strClassName )
{
	var arrElements = ( strTagName == "*" && oElm.all ) ? oElm.all : oElm.getElementsByTagName( strTagName );
	var arrReturnElements = new Array();
	strClassName = strClassName.replace( /-/g, "\-" );
	var oRegExp = new RegExp( "(^|\s)" + strClassName + "(\s|$)" );
	var oElement;
	for( var i = 0; i < arrElements.length; i++ )
	{
		oElement = arrElements[i];
		if( oRegExp.test( oElement.className ) )
		{
			arrReturnElements.push( oElement );
		}
	}
	return ( arrReturnElements )
}

/*
 * addEvent( obj, evType, fn, useCapture )
 * 
 * From: DHTML Utopia: Modern Web Design Using JavaScript & DOM, published by Sitepoint
 *  Scott Andrew's addEvent function, used to register events to an element through addEventListener 
 *  or attachEvent.
 */
function addEvent( elm, evType, fn, useCapture )
{
	if ( elm.addEventListener )
	{
		elm.addEventListener( evType, fn, useCapture );
		return true;
	}
	else if ( elm.attachEvent )
	{
		var r = elm.attachEvent( 'on' + evType, fn );
		return r;
	}
	else
	{
		elm['on' + evType] = fn;
	}
}

/*
 * init()
 * 
 * Parse through all of the input fields and attach the numeric autotab 
 * function on fields that have the class 'autotab'.
 */
function init()
{
	var elms = getElementsByClassName( document, 'input', 'autotab' );
	for ( var i = 0; i < elms.length; i++ )
	{
		addEvent( elms[i], 'keyup', doNumericAutotab, false );
	}
}

// Add the init() function to the window's load event.
addEvent( window, 'load', init, false );