# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.
module SensitiveDiseasesSpecHelper

  # Cretes a basic set of test data to get started with tests around access to sensitive diseases
  def create_starter_sensitive_disease_test_scenario

    # Create a sensitive disease user in a jurisdiction where he has sensitive disease privileges
    @bear_cub_river = create_jurisdiction_entity(:place => Factory.create(:place, :name => 'Bear Cub River'))
    @sensitive_disease_role = create_role_with_privileges!('sensitive_disease_role', :access_sensitive_diseases)
    @sensitive_disease_user = create_user_in_role!(@sensitive_disease_role.role_name, 'Bobby Johanssenson')
    @sensitive_disease_user.reload

    # Create another user and jurisdiction, but without any sensitive disease ties
    @central_state = create_jurisdiction_entity(:place => Factory.create(:place, :name => 'Central State'))
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
      :patient => 'James',
      :disease => @sensitive_disease,
      :jurisdiction => @bear_cub_river
    )

    # Sensitive event where Bear Cub River is the secondary jurisdiction
    @sensitive_event_secondary = create_morbidity_event(
      :patient => 'James',
      :disease => @sensitive_disease,
      :jurisdiction => @central_state
    )
    @sensitive_event_secondary.associated_jurisdictions.create(:secondary_entity => @bear_cub_river)

    # Sensitive event off in another jurisdiction
    @sensitive_event_out_of_jurisdiction = create_morbidity_event(
      :patient => 'James',
      :disease => @sensitive_disease,
      :jurisdiction => @david_county
    )

    # Regular event
    @not_sensitive_event = create_morbidity_event(
      :patient => 'James',
      :disease => Factory.create(:disease)
    )

    # Regular event without a disease
    @event_without_a_disease = create_morbidity_event(
      :patient => 'James'
    )

  end

end
