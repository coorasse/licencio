require "test_helper"

class TransactionalMailerTest < ActionMailer::TestCase
  test "renders the named template with the job's data" do
    mail = TransactionalMailer.notification(template: "purchase", email: "buyer@example.com",
      data: { product_name: "my-app", amount: "49.00 USD", license_keys: "MYAPP-KEY",
              magic_link_url: "https://licences.example.com/portal/x", sender_email: "licences@example.com" })

    assert_equal [ "buyer@example.com" ], mail.to
    assert_equal [ "licences@example.com" ], mail.from
    assert_equal "Your my-app licence key", mail.subject
    assert_includes mail.text_part.body.to_s, "MYAPP-KEY"
    assert_includes mail.text_part.body.to_s, "49.00 USD"
  end

  test "every template renders" do
    TransactionalMailer::TEMPLATES.each do |template|
      mail = TransactionalMailer.notification(template:, email: "a@example.com",
        data: { product_name: "my-app", sender_email: "licences@example.com" })
      assert_includes mail.subject, "my-app", template
      assert mail.text_part.body.to_s.present?, template
      assert mail.html_part.body.to_s.present?, template
    end
  end

  test "sends HTML in the product's colors next to the plain text" do
    product = products(:picmal)
    product.update_columns(accent_color: "#ffc94a", background_color: "#fbf6ea", logo_url: "https://example.com/logo.png")
    mail = TransactionalMailer.notification(template: "purchase", email: "buyer@example.com", product:,
      data: { product_name: "Picmal", amount: "49.00 USD", license_keys: "PICM-KEY",
              magic_link_url: "https://licences.example.com/portal/x" })

    html = mail.html_part.body.to_s
    assert_includes mail.text_part.body.to_s, "PICM-KEY"
    assert_includes html, "PICM-KEY"
    assert_includes html, "background: #fbf6ea"
    assert_includes html, "background: #ffc94a; color: #{EmailHelper::INK}", "dark text on a light accent"
    assert_includes html, %(src="https://example.com/logo.png")
    assert_includes html, %(href="https://licences.example.com/portal/x")
  end

  test "HTML falls back to neutral colors and the product name" do
    product = products(:picmal)
    product.update_columns(accent_color: "#1d4ed8", background_color: "red; x: y", logo_url: nil)
    html = TransactionalMailer.notification(template: "purchase", email: "a@example.com", product:,
      data: { product_name: "Picmal", license_keys: "123456", magic_link_url: "https://example.com/p" })
      .html_part.body.to_s

    assert_includes html, "background: #1d4ed8; color: #ffffff", "white text on a dark accent"
    assert_includes html, "background: #{EmailHelper::DEFAULT_BACKGROUND}"
    assert_not_includes html, "red; x: y"
    assert_not_includes html, "<img"
    assert_includes html, "123456"
  end

  test "rejects a template it doesn't know" do
    assert_raises(ArgumentError) do
      TransactionalMailer.notification(template: "../../secrets", email: "a@example.com", data: {}).message
    end
  end
end
