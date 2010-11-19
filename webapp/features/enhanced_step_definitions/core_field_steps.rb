Given /^I go to the core fields admin page$/ do
  @browser.open "/trisano/core_fields"
end

When /^I hide a core field$/ do
  @browser.run_script(<<-JS)
    var testField = $j('.button a.hide').first();
    var testFieldHref = testField.attr('href');
    testField.click();
  JS
end

Then /^its hide button should change to a display button$/ do
  @browser.wait_for_condition(<<-JS)
    var appWindow = selenium.browserbot.getCurrentWindow();
    appWindow.$j('.button a[href="' + appWindow.testFieldHref + '"]').first().hasClass('display');
  JS
end

When /^I re\-display the core field$/ do
  @browser.run_script(<<-JS)
    $j('.button a[href="' + testFieldHref + '"]').first().click();
  JS
end

Then /^its display button should change to a hide button$/ do
  @browser.wait_for_condition(<<-JS)
    var appWindow = selenium.browserbot.getCurrentWindow();
    appWindow.$j('.button a[href="' + appWindow.testFieldHref + '"]').first().hasClass('hide');
  JS
end
