# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition.

class AddFormPrivileges < ActiveRecord::Migration
  def self.up

    if RAILS_ENV =~ /production/
      transaction do

        say "Adding new form privileges"

        form_add_priv = Privilege.new({ :priv_name => 'add_form_to_event' })
        form_add_priv.save!
        
        form_remove_priv = Privilege.new({ :priv_name => 'remove_form_from_event' })
        form_remove_priv.save!

        say "Associating the add and remove form privileges with all roles except the data entry tech"

        data_entry_role = Role.find_by_role_name("Data Entry Technician")

        raise "Data entry technician role could not be found." if data_entry_role.nil?

        say data_entry_role.id

        Role.all.each do |role|
          unless role.id == data_entry_role.id
            say role.id
            say "Adding to #{role.role_name}"
            PrivilegesRole.create({ :role => role, :privilege =>  form_add_priv })
            PrivilegesRole.create({ :role => role, :privilege =>  form_remove_priv })
          end
        end

      end
    end

  end

  def self.down
  end
end
