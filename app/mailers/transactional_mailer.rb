# Stands in for Loops when a product has no Loops API key: the product's transactional ID
# fields then hold one of these template names instead of a Loops ID. Each email goes out as
# plain text and as HTML in the product's colors.
class TransactionalMailer < ApplicationMailer
  TEMPLATES = %w[portal_access purchase redemption seats_added refund expiry_reminder
                 checkout_recovery gift student_discount unlock].freeze

  helper :email

  def notification(template:, email:, data:, product: nil)
    raise ArgumentError, "Unknown email template #{template.inspect}" unless TEMPLATES.include?(template)

    @data = data.to_h.symbolize_keys
    @product = product
    mail to: email,
         from: @data[:sender_email].presence || ENV["MAILER_FROM"],
         subject: t(template, scope: "transactional_mailer.subjects", product_name: @data[:product_name]),
         template_name: template
  end
end
