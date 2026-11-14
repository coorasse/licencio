require "test_helper"

class TransactionalMailerTest < ActionMailer::TestCase
  test "renders the named template with the job's data" do
    mail = TransactionalMailer.notification(template: "purchase", email: "buyer@example.com",
      data: { product_name: "gitto", amount: "49.00 USD", license_keys: "GITTO-KEY",
              magic_link_url: "https://licences.example.com/portal/x", sender_email: "licences@example.com" })

    assert_equal [ "buyer@example.com" ], mail.to
    assert_equal [ "licences@example.com" ], mail.from
    assert_equal "Your gitto licence key", mail.subject
    assert_includes mail.body.to_s, "GITTO-KEY"
    assert_includes mail.body.to_s, "49.00 USD"
  end

  test "every template renders" do
    TransactionalMailer::TEMPLATES.each do |template|
      mail = TransactionalMailer.notification(template:, email: "a@example.com",
        data: { product_name: "gitto", sender_email: "licences@example.com" })
      assert_includes mail.subject, "gitto", template
      assert mail.body.to_s.present?, template
    end
  end

  test "rejects a template it doesn't know" do
    assert_raises(ArgumentError) do
      TransactionalMailer.notification(template: "../../secrets", email: "a@example.com", data: {}).message
    end
  end
end
