# Branded HTML email, styled inline because many mail clients drop <style> blocks. Colors come
# from the product (the same accent and background the portal uses) and fall back to neutral
# defaults; they are re-checked against the format because they are interpolated into styles.
module EmailHelper
  DEFAULT_ACCENT = "#2563eb"
  DEFAULT_BACKGROUND = "#f4f4f5"
  INK = "#18181b"
  MUTED = "#52525b"

  def email_accent = email_color(@product&.accent_color, DEFAULT_ACCENT)
  def email_background = email_color(@product&.background_color, DEFAULT_BACKGROUND)

  # Dark text on a light accent such as yellow, white on a dark one.
  def email_on_accent
    hex = email_accent.delete("#")
    hex = hex.chars.map { |c| c * 2 }.join if hex.size == 3
    r, g, b = hex.scan(/../).map { |pair| pair.to_i(16) }
    (0.299 * r) + (0.587 * g) + (0.114 * b) > 160 ? INK : "#ffffff"
  end

  def email_paragraph(text = nil, &)
    tag.p(text, style: "margin: 0 0 16px; font-size: 16px; line-height: 1.55; color: #{INK};", &)
  end

  def email_button(label, url)
    return if url.blank?

    tag.p(style: "margin: 8px 0 24px;") do
      link_to label, url, style: "display: inline-block; padding: 12px 22px; border-radius: 10px; " \
        "background: #{email_accent}; color: #{email_on_accent}; font-size: 16px; font-weight: 600; " \
        "text-decoration: none;"
    end
  end

  # A license key, gift code or unlock code: the thing the reader copies.
  def email_code(label, value)
    safe_join([
      tag.p(label, style: "margin: 0 0 6px; font-size: 13px; font-weight: 600; text-transform: uppercase; " \
        "letter-spacing: 0.04em; color: #{MUTED};"),
      tag.div(value, style: "margin: 0 0 24px; padding: 14px 16px; border-left: 4px solid #{email_accent}; " \
        "border-radius: 6px; background: #f4f4f5; font-family: ui-monospace, SFMono-Regular, Menlo, monospace; " \
        "font-size: 15px; line-height: 1.6; color: #{INK}; white-space: pre-line; word-break: break-all;")
    ])
  end

  def email_link(label, url)
    return label if url.blank?

    link_to label, url, style: "color: #{INK}; text-decoration: underline;"
  end

  private
    def email_color(value, default) = value.to_s.match?(Product::HEX_COLOR) ? value : default
end
