// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


function sendConditionalRequest(element) {
    pos = element.name.indexOf("_") + 1;
    question_id = element.name.substring(pos);
    auth_token = document.forms[0].authenticity_token.value;
  new Ajax.Request('/forms/process_conditional?question_id=' + question_id +'&response=' + element.value, {asynchronous:true, evalScripts:true, parameters:'authenticity_token=' + encodeURIComponent(auth_token)})
}

