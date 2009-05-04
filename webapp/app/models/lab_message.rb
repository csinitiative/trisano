class LabMessage < ActiveRecord::Base
  validates_presence_of :hl7_message
  validates_length_of :hl7_message, :maximum => 10485760
  
  def sending_facility
    hl7[:MSH].sending_facility.split('^').join(' - ')
  end

  def patient_name
    hl7.sequence_segments.select{|s| s.to_s =~ /^PID/}.first.e5.split('^').join(' ')
  end

  def lab
    hl7.sequence_segments.select{|s| s.to_s =~ /^OBR/}.first.e4.split('^').join(' ')
  end

  def lab_result
    hl7.sequence_segments.select{|s| s.to_s =~ /^OBX/}.first.e5
  end

  def hl7_version
    hl7[:MSH].version_id
  end

  def hl7
    @hl7 ||= HL7::Message.new(self.hl7_message)
  end
end
