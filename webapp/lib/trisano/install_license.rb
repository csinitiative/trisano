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

require 'active_support/core_ext'
module Trisano::License
  class LicenseChecker

    TRISANO_LICENSE = <<eos
/*
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
*/
eos

    TRISANO_LICENSE_INVALID = <<eos
# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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
eos

    def initialize(options)
      raise "Specify :root option with absolute path to source root" if options[:root].blank?
      raise "Specify :file_types option with extensions only (e.g. rb,js)" if options[:file_types].blank?
      @root = options[:root]
      @file_types = options[:file_types]
      @exclusions = %w(firefox-36-profile firefox-36 vendor/plugins javascripts/vendor javascripts/ext javascripts/calendar_date_select trisano/install_license.rb)
      @license_snippet = options[:license_snippet]
      @valid_license = TRISANO_LICENSE.freeze
      @invalid_license = TRISANO_LICENSE_INVALID.freeze
      index
    end

    def to_s
      "Indexed: #{index.count}, Licensed: #{license_present}"
    end

    def files_to_check
      return @files if @files
      files = Dir.glob(@root + "/**/*.{#{@file_types}}")
      files.delete_if do |file| 
        @exclusions.any? { |exclusion| file.include?(exclusion) }
      end
      @files = files
    end

    def index
      return @index if @index
      
      @index = []
      files_to_check.each do |file_path|
        source = File.open(file_path).read
        if source.present?
          @index << Trisano::License::LicensedFile.new(:source => source,
                                                       :new_license => @valid_license,
                                                       :license => @valid_license,
                                                       :old_license => @invalid_license,
                                                       :license_snippet => @license_snippet,
                                                       :path => file_path)
        else
          puts "empty source file: #{file_path}"
        end
      end
      @index
    end

    def rebuild_index
      @index = nil
      @files = nil
      @license_present = nil
      @license_absent = nil
      @likely_licensed = nil
      @needs_replacement = nil
      index
    end

    def license_present
      @license_present ||= index.select { |file| file.license_present? }
    end
    def license_absent
      @license_absent ||= index.select { |file| !file.license_present? }
    end
    def likely_licensed
      @likely_licensed ||= index.select { |file| file.likely_licensed? }
    end
    def needs_replacement
      @needs_replacement ||= index.select { |file| file.needs_replacement? }
    end
    def likely_invalid
      likely_licensed - license_present
    end
  end


  class LicensedFile
    attr_reader :path

    def initialize(options)
      raise "Specify :license option with license text" if options[:license].blank?
      raise "Specify :source options with source text" if options[:source].blank?
      @source = options[:source]
      @license = options[:license]
      @license_snippet = options[:license_snippet]
      @old_license = options[:old_license]
      @new_license = options[:new_license]
      @position = options[:position] || "top"
      @path = options[:path]
    end

    def needs_replacement?
      raise "Specify :old_license options with license text" if @old_license.blank?
      @source.include?(@old_license)
    end

    def replace_license
      raise "Specify :new_license options with license text" if @new_license.blank?
      @source.sub(@old_license, @new_license)
    end

    def replace_license!
      raise "Specify :path option with file path" if @path.blank?
      File.open(@path, 'w') { |f| f.write(replace_license) }
    end

    def license_present?
      @source.include?(@license) 
    end
    
    def license_in_position?
      starting_point = case @position.to_s
        when "top" then 0
        else raise "Unsupported position specified. 'top' is only supported option"
      end
      @source[0...@license.length] == @license
    end

    def likely_licensed?
      raise "Include :license_snippet option" if @license_snippet.blank?
      @source.include?(@license_snippet)
    end

    def license_installed?
      license_present? and license_in_position?
    end

    def update_source!
      raise "Specify :path option with file path" if @path.blank?
      File.open(@path, 'w') { |f| f.write(update_source) }
    end

    def update_source
      return @source if license_installed?
      if license_present? and !license_in_position?
        source_with_license_removed = @source.sub(@license, "") 
        @license.to_s + source_with_license_removed.to_s
      else
        @license.to_s + @source.to_s
      end
    end
  end
end
