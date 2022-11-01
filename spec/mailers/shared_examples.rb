# frozen_string_literal: true

RSpec.shared_examples "both parts contain" do |content|
  it "text & html part contain '#{content.truncate(80)}'" do
    expect(mail.text_part.decoded).to be_present
    expect(mail.html_part.decoded).to be_present
    expect(mail.text_part.decoded).to include content
    # end
    # it "text part contains" do
    expect(mail.html_part.decoded).to include content
  end
end
