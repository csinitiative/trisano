# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

module I18nLogger

  # The I18nLogger accepts the standard logging messages with a translation
  # key. It will constuct an error message containing the key and the
  # message corresponding to the key in the default system locale.
  #
  # Examples:
  #   I18nLogger.debug("event_created_for_jurisdiction")
  #     # Logs "DEBUG: event_created_for_jurisdiction: Event created for jurisdiction
  #
  def self.method_missing(log_level, message_key, options={})
    options[:locale] = I18n.default_locale
    translation = I18n.translate(message_key, options)
    message = "#{message_key}: #{translation}"
    DEFAULT_LOGGER.send(log_level.to_sym, message)
  end
end

