# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Layout/LineLength
describe Api::V1::InboundEmailsController, type: :controller do
  describe "permitted items" do
    let(:raw_params) do
      {
        "items" => [
          {
            "Uuid" => ["7c4642e5-4351-4fa7-b284-1ea1b06c89a6"],
            "MessageId" => "<167F5862-BB98-447E-8B8E-C5D8B29A66A8@dipasquale.fr>",
            "InReplyTo" => nil,
            "From" => { "Name" => "Adrien Di Pasquale", "Address" => "adrien@dipasquale.fr" },
            "To" => [{ "Name" => nil,
                       "Address" => "mairie-51662-417966acb8cd5e98748e@reponse-loophole.collectifobjets.org" }],
            "Cc" => [],
            "ReplyTo" => nil,
            "SentAtDate" => "Tue, 17 Jan 2023 15:09:31 +0100",
            "Subject" => "bonjour",
            "Attachments" => [],
            "Headers" => {
              "DKIM-Signature" => "v=1; a=rsa-sha256; c=relaxed/relaxed; d=dipasquale.fr; s=key1; t=1673964632;",
              "From" => "Adrien Di Pasquale <adrien@dipasquale.fr>",
              "To" => "mairie-51662-417966acb8cd5e98748e@reponse-loophole.collectifobjets.org",
              "Subject" => "bonjour",
              "Date" => "Tue, 17 Jan 2023 15:09:31 +0100",
              "Message-ID" => "<167F5862-BB98-447E-8B8E-C5D8B29A66A8@dipasquale.fr>",
              "MIME-Version" => "1.0",
              "Content-Type" => "multipart/alternative"
            },
            "SpamScore" => 1.699999,
            "ExtractedMarkdownMessage" => "Ceci est un gros test de testeur \n\n[voila](https://collectifobjets.gouv.fr) \n",
            "ExtractedMarkdownSignature" => "Merci  \nAdrien Di Pasquale  \n06 40 40 40 04",
            "RawHtmlBody" => "<!DOCTYPE html>\n<html>\n<head>\n<meta http-equiv=\"Content-Type\" content=\"text/xhtml; charset=utf-8\">\n</head>\n<body><div style=\"font-family: sans-serif;\"><div class=\"markdown\" style=\"white-space: normal;\">\n<p dir=\"auto\">Ceci est un gros test de testeur</p>\n<p dir=\"auto\"><a href=\"https://collectifobjets.gouv.fr\">voila</a></p>\n<p dir=\"auto\">Merci<br>\nAdrien Di Pasquale<br>\n06 40 40 40 04</p>\n\n</div>\n</div>\n</body>\n\n</html>\n",
            "RawTextBody" => "Ceci est un gros test de testeur\n\n[voila](https://collectifobjets.gouv.fr)\n\nMerci\nAdrien Di Pasquale\n06 40 40 40 04"
          }
        ]
      }
    end

    let(:params) { ActionController::Parameters.new(raw_params) }
    let(:permitted) { params.permit(Api::V1::InboundEmailsController::PERMITTED_PARAMS) }
    it "should permit" do
      expect(permitted["items"][0]["Uuid"]).to eq(["7c4642e5-4351-4fa7-b284-1ea1b06c89a6"])
      expect(permitted["items"][0]["MessageId"]).to eq("<167F5862-BB98-447E-8B8E-C5D8B29A66A8@dipasquale.fr>")
      expect(permitted["items"][0]["InReplyTo"]).to eq(nil)
      expect(permitted["items"][0]["From"]["Name"]).to eq("Adrien Di Pasquale")
      expect(permitted["items"][0]["From"]["Address"]).to eq("adrien@dipasquale.fr")
      expect(permitted["items"][0]["To"][0]["Name"]).to eq(nil)
      expect(permitted["items"][0]["To"][0]["Address"]).to eq("mairie-51662-417966acb8cd5e98748e@reponse-loophole.collectifobjets.org")
      expect(permitted["items"][0]["Cc"]).to eq([])
      expect(permitted["items"][0]["ReplyTo"]).to eq(nil)
      expect(permitted["items"][0]["SentAtDate"]).to eq("Tue, 17 Jan 2023 15:09:31 +0100")
      expect(permitted["items"][0]["Subject"]).to eq("bonjour")
      expect(permitted["items"][0]["Attachments"]).to eq([])
      expect(permitted["items"][0]["Headers"]["DKIM-Signature"]).to eq("v=1; a=rsa-sha256; c=relaxed/relaxed; d=dipasquale.fr; s=key1; t=1673964632;")
      expect(permitted["items"][0]["Headers"]["From"]).to eq("Adrien Di Pasquale <adrien@dipasquale.fr>")
      expect(permitted["items"][0]["Headers"]["To"]).to eq("mairie-51662-417966acb8cd5e98748e@reponse-loophole.collectifobjets.org")
      expect(permitted["items"][0]["Headers"]["Subject"]).to eq("bonjour")
      expect(permitted["items"][0]["Headers"]["Date"]).to eq("Tue, 17 Jan 2023 15:09:31 +0100")
      expect(permitted["items"][0]["Headers"]["Message-ID"]).to eq("<167F5862-BB98-447E-8B8E-C5D8B29A66A8@dipasquale.fr>")
      expect(permitted["items"][0]["Headers"]["MIME-Version"]).to eq("1.0")
      expect(permitted["items"][0]["Headers"]["Content-Type"]).to eq("multipart/alternative")
      expect(permitted["items"][0]["SpamScore"]).to eq(1.699999)
      expect(permitted["items"][0]["ExtractedMarkdownMessage"]).to eq("Ceci est un gros test de testeur \n\n[voila](https://collectifobjets.gouv.fr) \n")
      expect(permitted["items"][0]["ExtractedMarkdownSignature"]).to eq("Merci  \nAdrien Di Pasquale  \n06 40 40 40 04")
      expect(permitted["items"][0]["RawHtmlBody"]).to eq("<!DOCTYPE html>\n<html>\n<head>\n<meta http-equiv=\"Content-Type\" content=\"text/xhtml; charset=utf-8\">\n</head>\n<body><div style=\"font-family: sans-serif;\"><div class=\"markdown\" style=\"white-space: normal;\">\n<p dir=\"auto\">Ceci est un gros test de testeur</p>\n<p dir=\"auto\"><a href=\"https://collectifobjets.gouv.fr\">voila</a></p>\n<p dir=\"auto\">Merci<br>\nAdrien Di Pasquale<br>\n06 40 40 40 04</p>\n\n</div>\n</div>\n</body>\n\n</html>\n")
      expect(permitted["items"][0]["RawTextBody"]).to eq("Ceci est un gros test de testeur\n\n[voila](https://collectifobjets.gouv.fr)\n\nMerci\nAdrien Di Pasquale\n06 40 40 40 04")
    end
  end
end
# rubocop:enable Layout/LineLength
