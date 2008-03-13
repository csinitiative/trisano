// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function setUpSearchFields() {
  if (document.getElementById("name").value.length > 0) {
    document.getElementById("sw_first_name").disabled = true;
    document.getElementById("sw_last_name").disabled = true;
  }
  
  if (document.getElementById("sw_first_name").value.length > 0 || document.getElementById("sw_last_name").value.length > 0) {
    document.getElementById("name").disabled = true;
  }
}

function checkNameSearchFields(field) {
  if (field.id == "name") {
    if (field.value.length > 0) {
      document.getElementById("sw_first_name").disabled = true;
      document.getElementById("sw_last_name").disabled = true;
    }
    else {
      document.getElementById("sw_first_name").disabled = false;
      document.getElementById("sw_last_name").disabled = false;
    }
  }
  else if (field.id == "sw_first_name" || field.id == "sw_last_name") {
     first = document.getElementById("sw_first_name");
     last = document.getElementById("sw_last_name");
     
    if (first.value.length > 0 || last.value.length > 0) {
      document.getElementById("name").disabled = true;
    }
    else {
      document.getElementById("name").disabled = false;
    }
  }
}
