class NoHtmlTagsValidator < ActiveModel::EachValidator
  HTML_TAG_PATTERN = /<[^>]*>/

  def validate_each(record, attribute, value)
    return if value.blank?

    if HTML_TAG_PATTERN.match?(value)
      record.errors.add(attribute, :no_html_tags, message: "にHTMLタグは使用できません")
    end
  end
end
