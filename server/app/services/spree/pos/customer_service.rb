# frozen_string_literal: true

module Spree
  module Pos
    class CustomerService
      MAX_QUERY_LENGTH = 120
      PAGE_LIMIT = 25

      def self.search(store:, staff:, branch:, query:, page: 1)
        policy = AccessPolicy.new(store: store, staff: staff)
        raise CanCan::AccessDenied unless policy.allows?(branch, Capabilities::OPEN_SHIFT)

        term = query.to_s.strip
        raise Conflict, 'Customer search is invalid.' if term.blank? || term.length > MAX_QUERY_LENGTH

        page = Integer(page)
        raise Conflict, 'Customer search is invalid.' if page < 1

        escaped = ActiveRecord::Base.sanitize_sql_like(term)
        phone = CustomerProfile.normalize_phone(term)
        scope = CustomerProfile.for_store(store).where(
          'name ILIKE :term OR phone ILIKE :term OR normalized_phone = :phone OR email ILIKE :term',
          term: "%#{escaped}%", phone: phone
        ).order(:name, :id)
        count = scope.count
        records = scope.offset((page - 1) * PAGE_LIMIT).limit(PAGE_LIMIT).to_a
        duplicates = term.match?(/\A[+\d][\d\s().-]+\z/) ? records.size : 0
        {
          data: records.map(&:to_pos),
          meta: { page: page, limit: PAGE_LIMIT, count: count, pages: (count + PAGE_LIMIT - 1) / PAGE_LIMIT,
                  duplicate_candidates: duplicates }
        }
      rescue ArgumentError, TypeError
        raise Conflict, 'Customer search is invalid.'
      end

      def self.create(store:, staff:, branch:, name:, phone:, email:)
        policy = AccessPolicy.new(store: store, staff: staff)
        raise CanCan::AccessDenied unless policy.allows?(branch, Capabilities::CUSTOMER)

        normalized_email = email.to_s.strip.downcase.presence
        customer = normalized_email && Spree.customer_class.find_by(email: normalized_email)
        profile = CustomerProfile.new(
          store: store, created_by: staff, customer: customer, name: name.to_s,
          phone: phone.to_s.presence, email: normalized_email
        )
        profile.save!
        profile
      end

      def self.duplicates(store:, phone:)
        normalized = CustomerProfile.normalize_phone(phone)
        return [] if normalized.blank?

        CustomerProfile.for_store(store).where(normalized_phone: normalized).order(:id).map(&:to_pos)
      end
    end
  end
end
