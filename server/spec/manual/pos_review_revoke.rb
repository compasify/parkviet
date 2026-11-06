# frozen_string_literal: true

# Revoke only the explicitly provisioned, compromised synthetic review account.
require 'json'
require 'securerandom'

abort 'Development environment required' unless Rails.env.development?
credentials = JSON.parse(File.read(Rails.root.join('pos-live-review-credentials.json')))
tag = credentials.fetch('tag')
abort 'Unexpected fixture identifier' unless tag.match?(/\A[0-9a-f]{10}\z/)
email = "pos-review-#{tag}@example.test"
abort 'Unexpected fixture email' unless credentials.fetch('email') == email
register = Spree::Pos::Register.find_by_prefix_id!(credentials.fetch('register_id'))
abort 'Unexpected fixture register' unless register.name == "POS Review #{tag}" && register.branch.name == "POS Review #{tag}"
staff = Spree.admin_user_class.find_by!(email: email)
abort 'Missing fixture membership' unless Spree::Pos::StaffMembership.exists?(staff: staff, branch: register.branch)
staff.update!(deactivated_at: Time.current, password: SecureRandom.hex(32))
puts 'Synthetic review account deactivated and password rotated; fixture records retained.'
