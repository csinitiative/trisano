require 'spec_helper'

describe "events/_disease_info_form.html.haml" do
  before :all do
    @active_disease = Factory(:disease, :active => true)
    @inactive_disease = Factory(:disease, :active => false)
    @sensitive_disease = Factory(:disease, :active => true, :sensitive => true)
    @sensitive_inactive = Factory(:disease, :active => false, :sensitive => true)
  end

  before do
    @user = Factory.build(:user)
    @event = Factory.build(:morbidity_event)
    assigns[:event] = @event
  end

  it "only renders active diseases" do
    render "events/_disease_info_form.html.haml",
      :locals => { :f => ExtendedFormBuilder.new('morbidity_event', @event, template, {}, nil) }
    response.should have_tag('#morbidity_event_disease_event_attributes_disease_id') do
      with_tag('option', "")
      with_tag('option', @active_disease.disease_name)
      without_tag('option', @inactive_disease.disease_name)
      without_tag('option', @sensitive_disease.disease_name)
      without_tag('option', @sensitive_inactive.disease_name)
    end
  end

  it "renders active diseases *and* sensitive disease, if current user has the privilege" do
    @user.stubs(:can_access_sensitive_diseases?).returns(true)
    render "events/_disease_info_form.html.haml",
      :locals => { :f => ExtendedFormBuilder.new('morbidity_event', @event, template, {}, nil) }
    response.should have_tag('#morbidity_event_disease_event_attributes_disease_id') do
      with_tag('option', "")
      with_tag('option', @active_disease.disease_name)
      without_tag('option', @inactive_disease.disease_name)
      with_tag('option', @sensitive_disease.disease_name)
      without_tag('option', @sensitive_inactive.disease_name)
    end
  end
end
