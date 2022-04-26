# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker

Dir['./spec/support/acceptance/**/*.rb'].sort.each { |f| require f }
