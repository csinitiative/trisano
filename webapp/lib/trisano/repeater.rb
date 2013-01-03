module Trisano::Repeater
  def self.included(base)
    base.class_eval do
      has_many :answers, :include => [:question], :as => :repeater_form_object, :autosave => true
    end
  end

  def repeater_answers=(attributes)
    if answers.empty?
      answers.build(attributes.values)
    else
      answers.each { |answer| answer.attributes = attributes[answer.id.to_s] }
    end
  end

  def new_repeater_answers=(attributes)
    attributes = [attributes] unless attributes.is_a?(Array)
    answers = self.answers.build(attributes)
    answers.each { |answer| answer.repeater_form_object = self }
  end


  def new_repeater_checkboxes=(attributes)
    attributes = [attributes] unless attributes.is_a?(Array)
    attributes.each do |attribute_hash|
      attribute_hash.each do |question_id, answer_attributes|
        answer = self.answers.build(
          :question_id => question_id,
          :check_box_answer => answer_attributes[:check_box_answer],
          :code => answer_attributes[:code],
          :event_id => answer_attributes[:event_id]
        )
        answer.repeater_form_object = self
      end
    end
  end

  def new_repeater_radio_buttons=(attributes)
    attributes = [attributes] unless attributes.is_a?(Array)
    attributes.each do |attribute_hash|
      attribute_hash.each do |question_id, answer_attributes|
        answer = self.answers.build(
          :question_id => question_id,
          :radio_button_answer => answer_attributes[:radio_button_answer],
          :export_conversion_value_id => answer_attributes[:export_conversion_value_id],
          :code => answer_attributes[:code],
          :event_id => answer_attributes[:event_id]
        )
        answer.repeater_form_object = self
      end
    end
  end
end
