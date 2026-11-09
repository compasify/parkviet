# frozen_string_literal: true

module Spree
  module Pos
    # POS contact profile. Spree customers remain the identity for email
    # accounts; no fake email is ever synthesized for phone-only contacts.
    class CustomerProfile < Record
      self.table_name = 'spree_pos_customers'
      has_prefix_id :poscustomer

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :customer, class_name: 'Spree::Customer', optional: true
      belongs_to :created_by, class_name: staff_class_name

      before_validation :normalize_contacts

      validates :name, presence: true, length: { maximum: 120 }
      validates :phone, length: { maximum: 32 }
      validates :email, length: { maximum: 254 }, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
      # Free text, written the way the seller says it: "1205 S1.02, treo cửa".
      validates :address, length: { maximum: 255 }
      validate :contact_present
      validate :email_matches_customer

      scope :for_store, ->(store) { where(store_id: store.id) }

      def self.normalize_phone(value)
        value.to_s.gsub(/[\s().-]/, '').sub(/\A\+?84/, '0')
      end

      def to_pos
        {
          id: prefixed_id,
          name: name,
          phone: phone,
          email: email,
          address: address,
          customer_id: customer&.prefixed_id,
          has_account: customer.present?
        }
      end

      private

      def normalize_contacts
        self.name = name.to_s.strip.presence
        self.phone = phone.to_s.strip.presence
        self.email = email.to_s.strip.downcase.presence
        self.normalized_phone = phone.present? ? self.class.normalize_phone(phone) : nil
        self.address = address.to_s.squish.presence
      end

      def contact_present
        errors.add(:phone, :blank) if phone.blank? && email.blank?
      end

      def email_matches_customer
        errors.add(:customer, :invalid) if customer && customer.email.to_s.downcase != email.to_s
        errors.add(:email, :invalid) if customer.nil? && email.present? && Spree.customer_class.exists?(email: email)
      end
    end
  end
end
