class CsvFieldsController < ApplicationController
  def index
    @morbidity_event_fields = CsvField.morbidity_event_fields
    @assessment_event_fields = CsvField.assessment_event_fields
    @place_event_fields     = CsvField.place_event_fields
    @contact_event_fields   = CsvField.contact_event_fields
    @lab_fields             = CsvField.lab_fields
    @treatment_fields       = CsvField.treatment_fields
  end

  def set_csv_field_short_name
    @csv_field = CsvField.find(params[:id])
    @csv_field.short_name = params[:value]
    if @csv_field.save
      render :text => @csv_field.short_name
    else
      render :text => @csv_field.errors.full_messages.join("\n"), :status => 500
    end
  end
end
