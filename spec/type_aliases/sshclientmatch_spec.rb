# frozen_string_literal: true

require 'spec_helper'

describe 'Ssh::ClientMatch' do
  known_criteria = %w[
    !all
    all
    !canonical
    canonical
    !exec
    exec
    !final
    final
    !host
    host
    !localuser
    localuser
    !originalhost
    originalhost
    !user
    user
  ]
  it { is_expected.to allow_values(*known_criteria) }
  it { is_expected.not_to allow_value(nil) }
  it { is_expected.not_to allow_value('foo') }
end
