// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


function doIt(element) {
    pos = element.name.indexOf("_") + 1;
    question_id = element.name.substring(pos)
  
  new Ajax.Request('/forms/process_conditional?question_id=' + question_id +'&response=' + element.value, {asynchronous:true, evalScripts:true, parameters:'authenticity_token=' + encodeURIComponent('0bbc6499a7db1359f27d7ea0bc4051c2265d5bca')})
}

