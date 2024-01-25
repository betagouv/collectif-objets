# frozen_string_literal: true

shared_examples "an accessible page" do
  it "should be axe clean" do
    expect(page).not_to have_text(/erreur 500/i)
    expect(page).not_to have_text(/error 500/i)
    expect(page).to be_axe_clean
  end
end

shared_examples "an accessible page except iframes" do
  it "should be axe clean except iframes" do
    expect(page).not_to have_text(/erreur 500/i)
    expect(page).not_to have_text(/error 500/i)
    expect(page).to be_axe_clean.excluding "iframe"
  end
end
