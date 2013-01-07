Trisano.FormBuilder = {
  showRelevantQuestionDataTypeFields: function(e) {
    if($j(e).val() == "numeric") {
      $j(e).closest("form.new_question_element").find("div.numeric-questions").show();
    } else {
      $j(e).closest("form.new_question_element").find("div.numeric-questions").hide();
    }
  }
}
