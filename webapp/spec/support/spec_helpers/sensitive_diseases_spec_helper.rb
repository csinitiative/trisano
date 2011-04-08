module SensitiveDiseasesSpecHelper

  # Cretes a basic set of test data to get started with tests around access to sensitive diseases
  def create_starter_sensitive_disease_test_scenario
    @bear_cub_river = create_jurisdiction_entity(:place => Factory.create(:place, :name => 'Bear Cub River'))
    @central_state = create_jurisdiction_entity(:place => Factory.create(:place, :name => 'Central State'))

    # Create two users, one with sensitive disease permissions
    @sensitive_disease_role = create_role_with_privileges!('sensitive_disease_role', :access_sensitive_diseases)
    @sensitive_disease_user = create_user_in_role!(@sensitive_disease_role.role_name, 'Bobby Johanssenson')
    @sensitive_disease_user.reload
    @not_sensitive_disease_user = Factory.create(:user)

    # Add another jurisdiction that no one will have permissions in
    @david_county = create_jurisdiction_entity(:place => Factory.create(:place, :name => 'David County'))

    # Give both users an email address
    @sensitive_disease_user_email = Factory.create(:email_address, :email_address => 'sensitive-disease-person@trisano.org')
    @sensitive_disease_user.email_addresses << @sensitive_disease_user_email
    @not_sensitive_disease_user_email = Factory.create(:email_address, :email_address => 'not-very-sensitive@trisano.org')
    @not_sensitive_disease_user.email_addresses << @not_sensitive_disease_user_email

    # Create a sensitive disease and some events
    @sensitive_disease = Factory.create(:disease, :disease_name => 'AIDS', :sensitive => true)

    # Sensitive event in Bear Cub River
    @sensitive_event = create_morbidity_event(
      :disease => @sensitive_disease,
      :jurisdiction => @bear_cub_river
    )

    # Sensitive event where Bear Cub River is the secondary jurisdiction
    @sensitive_event_secondary = create_morbidity_event(
      :disease => @sensitive_disease,
      :jurisdiction => @central_state
    )
    @sensitive_event_secondary.associated_jurisdictions.create(:secondary_entity => @bear_cub_river)

    # Sensitive event off in another jurisdiction
    @sensitive_event_out_of_jurisdiction = create_morbidity_event(
      :disease => @sensitive_disease,
      :jurisdiction => @david_county
    )

    # Regular event
    @not_sensitive_event = create_morbidity_event
  end

end
