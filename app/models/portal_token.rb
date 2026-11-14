class PortalToken < ApplicationRecord
  belongs_to :customer
  belongs_to :product

  # Product-scoped magic-link token, reusable within its 30-minute window. One live token per
  # (customer, product), so requesting a link for product B never invalidates A's.
  #
  # Reusable (not single-use) on purpose: mail scanners and browser link-preloaders GET the URL
  # before the human clicks, so a one-shot token would be consumed by the prefetch and the real
  # click would fail. The 30-minute expiry bounds a leaked link instead.
  def self.issue!(customer:, product:)
    attributes = { token: SecureRandom.urlsafe_base64(32), expires_at: 30.minutes.from_now }
    # create_or_find_by!, not first_or_initialize: two concurrent redemptions for one new
    # customer would both try to insert the row and one would hit the unique index.
    record = create_or_find_by!(customer:, product:) { it.assign_attributes(attributes) }
    record.update!(attributes) unless record.previously_new_record?
    record
  end

  def self.authenticate(token)
    where(expires_at: Time.current..).find_by(token:) if token.present?
  end
end
