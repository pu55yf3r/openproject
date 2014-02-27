#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

# Mocks out OpenID
#
# http://www.northpub.com/articles/2007/04/02/testing-openid-support
module OpenIdAuthentication

  EXTENSION_FIELDS = {'email' => 'user@somedomain.com',
                      'nickname' => 'cool_user',
                      'country' => 'US',
                      'postcode' => '12345',
                      'fullname' => 'Cool User',
                      'dob' => '1970-04-01',
                      'language' => 'en',
                      'timezone' => 'America/New_York'}

  protected

    def authenticate_with_open_id(identity_url = params[:openid_url], options = {}) #:doc:
      if User.find_by_identity_url(identity_url) || identity_url.include?('good')
        # Don't process registration fields unless it is requested.
        unless identity_url.include?('blank') || (options[:required].nil? && options[:optional].nil?)
          extension_response_fields = {}

          options[:required].each do |field|
            extension_response_fields[field.to_s] = EXTENSION_FIELDS[field.to_s]
          end unless options[:required].nil?

          options[:optional].each do |field|
            extension_response_fields[field.to_s] = EXTENSION_FIELDS[field.to_s]
          end unless options[:optional].nil?
        end

        yield Result[:successful], identity_url , extension_response_fields
      else
        logger.info "OpenID authentication failed: #{identity_url}"
        yield Result[:failed], identity_url, nil
      end
    end

  private

    def add_simple_registration_fields(open_id_response, fields)
      open_id_response.add_extension_arg('sreg', 'required', [ fields[:required] ].flatten * ',') if fields[:required]
      open_id_response.add_extension_arg('sreg', 'optional', [ fields[:optional] ].flatten * ',') if fields[:optional]
    end
end
