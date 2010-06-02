module EventsSpecHelper

  def given_a_contact_for_morb(morb, options={})
    returning Factory.create(:contact_event, options) do |contact|
      contact.update_attributes!(:parent_event => morb)
    end
  end

end
